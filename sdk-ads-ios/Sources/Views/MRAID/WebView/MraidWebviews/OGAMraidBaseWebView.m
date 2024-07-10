//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGAMraidBaseWebView.h"
#import "OGAMraidEnviromentBuilder.h"
#import "OGAMraidCommandsHandler.h"
#import "OGALog.h"
#import "OGAMraidCreateWebViewCommand.h"
#import "OGAMRAIDUrlChangeHandler.h"
#import "OGAMetricsService.h"
#import "OGAAdHistoryEvent.h"
#import "OGAOMIDService.h"
#import "OGAWKWebView.h"
#import "OGAUserDefaultsStore.h"
#import "OGAMraidCommand.h"
#import "OGAMraidInitializationOperation.h"
#import "OGAMraidLoadHTMLOperation.h"
#import "OGAMraidVerificationOperation.h"
#import "OGAEXTScope.h"
#import "OGACallEventListenersConstants.h"
#import "OGAAdDisplayerCallEventListenersInformation.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAAdConfiguration.h"

#pragma mark - Constants

NSString *const OGANameMainWebView = @"Main";
NSString *const OGANameBrowserWebView = @"browser";
NSString *const OGANameBrowserLandingPageWebView = @"browser-landing-page";
NSString *const OGANameRecommendedLinksWebView = @"browser-recommended-links";
NSString *const OGAMraidBaseViewErrorDomain = @"OGAMraidBaseView";
NSString *const OGAMraidBaseWebViewBaseURL = @"ogy://ads-test.st.ogury.com/";
NSString *const OGAScriptMessageHandlerName = @"handler";
NSInteger const OGAMraidBaseViewErrorFailedToLoadMRAIDFile = 0;
NSString *const OGAFinishedEvent = @"finished";

static NSString *const OGAGoogleAnalyticsResponseURLKey = @"responseURL";
static int const maximumNumberOfMRAIDVerifications = 8;

@interface OGAMraidBaseWebView () <OGAMRAIDWebViewUrlChangeHandlerDelegate, OGAMraidCommandsHandlerDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong) OGAOMIDService *omidService;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;

@property(nonatomic, strong) OGAMRAIDUrlChangeHandler *urlChangeHandler;
@property(nonatomic, strong) OGAMraidBaseWebView *fakeWebView;
@property(nonatomic, strong) OGALog *log;

@property(nonatomic, strong) NSOperationQueue *mraidInitializationQueue;
@property(nonatomic, assign) BOOL isPerformingMRAIDInitialization;
@property(nonatomic, assign) BOOL hasFinishedMRAIDInitialization;

@end

@implementation OGAMraidBaseWebView

#pragma mark - Initialization

- (instancetype)initWithCommand:(OGAMraidCreateWebViewCommand *)command ad:(OGAAd *)ad {
    NSNumber *height = command.size[@"height"];
    NSNumber *width = command.size[@"width"];
    NSNumber *x = command.position[@"x"];
    NSNumber *y = command.position[@"y"];

    if (self = [self initWithAd:ad]) {
        self.frame = CGRectMake(x.floatValue, y.floatValue + 50, width.floatValue, height.floatValue);
        _createCommand = command;
    }

    return self;
}

- (instancetype)initWithAd:(OGAAd *)ad {
    return [self initWithAd:ad
              metricsService:[OGAMetricsService shared]
                 omidService:[OGAOMIDService shared]
        monitoringDispatcher:[OGAMonitoringDispatcher shared]
                         log:[OGALog shared]];
}

- (instancetype)initWithAd:(OGAAd *)ad
            metricsService:(OGAMetricsService *)metricsService
               omidService:(OGAOMIDService *)omidService
      monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                       log:(OGALog *)log {
    if ([super initWithFrame:CGRectMake(0, 0, 100, 100)]) {
        _ad = ad;
        _webViewId = OGANameMainWebView;
        _metricsService = metricsService;
        _omidService = omidService;
        _monitoringDispatcher = monitoringDispatcher;
        _mraidInitializationQueue = [[NSOperationQueue alloc] init];
        _mraidInitializationQueue.maxConcurrentOperationCount = 1;
        _mraidInitializationQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        _log = log;
    }

    return self;
}

#pragma mark - Methods

- (void)setupWithCommand:(OGAMraidCreateWebViewCommand *)command {
    self.webViewId = command.webViewId;
    [self setupMKWebView];
    if (command.content) {
        [self loadWithContent:command.content];
    } else if (command.url) {
        [self loadWithURL:command.url];
    }
}

- (void)loadWebViewWithCommandforBrowser:(OGAMraidCreateWebViewCommand *)command {
    if (self.ad.adUnit) {
        [self startMRAIDProcessForContent:command.content];
    }
}

- (void)loadWithContent:(NSString *)content {
    if (self.ad.adUnit) {
        [self startMRAIDProcessForContent:content];
    }
}

/// Start the MRAID initialisation process for the WKWebView
- (void)startMRAIDProcessForContent:(NSString *)content {
    if (self.isPerformingMRAIDInitialization) {
        [self.log logMraid:OguryLogLevelWarning forAdConfiguration:self.ad.adConfiguration webViewId:self.webViewId message:@"Trying to perform a dual MRAID initialization"];
        return;
    }

    NSString *baseURLString = self.ad.webViewBaseUrl ? self.ad.webViewBaseUrl : OGAMraidBaseWebViewBaseURL;
    NSURL *baseURL = [NSURL URLWithString:baseURLString];

    NSString *mraidEnv = [OGAMraidEnviromentBuilder generateMraidEnviroment:self.ad.adUnit];

    NSString *mraidFile = [[OGAUserDefaultsStore shared] stringForKey:self.ad.mraidDownloadUrl];
    if (!mraidFile) {
        return;
    }

    NSMutableArray<NSOperation *> *operations = [[NSMutableArray alloc] init];

    self.isPerformingMRAIDInitialization = YES;
    self.hasFinishedMRAIDInitialization = NO;

    [self.mraidInitializationQueue cancelAllOperations];

    OGAMraidInitializationOperation *initializationOperation = [[OGAMraidInitializationOperation alloc] initWithBaseView:self initializationScript:mraidFile];
    [operations addObject:initializationOperation];

    for (int index = 0; index < maximumNumberOfMRAIDVerifications; index++) {
        @weakify(self)
            OGAMraidVerificationOperation *verificationOperation = [[OGAMraidVerificationOperation alloc] initWithBaseView:self
                                                                                                         completionHandler:^(BOOL isCommunicatingViewMRAID) {
                                                                                                             @strongify(self) if (self && isCommunicatingViewMRAID && !self.hasFinishedMRAIDInitialization) {
                                                                                                                 self.isPerformingMRAIDInitialization = NO;
                                                                                                                 self.hasFinishedMRAIDInitialization = YES;

                                                                                                                 [self.mraidInitializationQueue cancelAllOperations];
                                                                                                                 [self.mraidInitializationQueue addOperation:[[OGAMraidLoadHTMLOperation alloc] initWithBaseView:self
                                                                                                                                                                                                         content:content
                                                                                                                                                                                                         baseURL:baseURL
                                                                                                                                                                                               environmentScript:mraidEnv
                                                                                                                                                                                                 executionScript:mraidFile]];
                                                                                                             }
                                                                                                         }];

        // Enforce dependencies between verification operations
        NSOperation *lastOperationInQueue = operations.lastObject;
        if (lastOperationInQueue) {
            [verificationOperation addDependency:lastOperationInQueue];
        }

        [operations addObject:verificationOperation];
    }

    [self.mraidInitializationQueue addOperations:operations waitUntilFinished:NO];
}

- (void)loadWithURL:(NSString *)urlAsString {
    NSURL *url = [NSURL URLWithString:urlAsString] ?: [NSURL new];
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)removeScriptMessageHandler {
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:OGAScriptMessageHandlerName];
}

#pragma mark - Private methods

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (void)setupMKWebView {
    self.wkWebView.scrollView.bounces = NO;

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];

    if ([self.webViewId isEqualToString:OGANameBrowserLandingPageWebView]) {
        config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeVideo;
    } else {
        config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    }

    config.allowsInlineMediaPlayback = YES;
    config.allowsPictureInPictureMediaPlayback = YES;

    WKUserScript *userScriptForInterceptURL = [[WKUserScript alloc] initWithSource:@"var observer = new PerformanceObserver(list =>{ list.getEntries().forEach(entry => { var messagePerfs = {\"responseURL\": entry.name }; webkit.messageHandlers.handler.postMessage(messagePerfs); })}); observer.observe({entryTypes: ['resource']});"
                                                                     injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                                  forMainFrameOnly:NO];
    [config.userContentController addUserScript:userScriptForInterceptURL];
    [config.userContentController addScriptMessageHandler:self name:OGAScriptMessageHandlerName];

    self.urlChangeHandler = [[OGAMRAIDUrlChangeHandler alloc] init];
    self.urlChangeHandler.urlChangeHandlerDelegate = self;

    CGRect wkFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

    self.wkWebView = [[OGAWKWebView alloc] initWithFrame:wkFrame configuration:config];

    self.wkWebView.navigationDelegate = self;
    self.wkWebView.UIDelegate = self;
    self.wkWebView.scrollView.bounces = NO;
    [self addSubview:self.wkWebView];

    if (@available(iOS 16.4, *)) {
        self.wkWebView.inspectable = YES;
    }

    [self setupConstraintsForWebView];
}

#pragma GCC diagnostic pop

- (void)setupConstraintsForWebView {
    self.wkWebView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addConstraints:@[
        [self.wkWebView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.wkWebView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.wkWebView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.wkWebView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]
    ]];
}

- (void)sendNavigationEvent:(NSString *)event webViewIdentifier:(NSString *)webViewIdentifier wkWebView:(WKWebView *)wkWebView {
    [self sendNavigationEvent:event webViewIdentifier:webViewIdentifier wkWebView:wkWebView pageTitle:nil];
}

- (void)sendNavigationEvent:(NSString *)event webViewIdentifier:(NSString *)webViewIdentifier wkWebView:(WKWebView *)wkWebView pageTitle:(NSString *_Nullable)pageTitle {
    NSMutableDictionary<NSString *, NSString *> *parameters = [[NSMutableDictionary alloc] init];
    parameters[OGACallEventListenersEvent] = event;
    parameters[OGACallEventListenersCanGoBack] = wkWebView.canGoBack ? @"true" : @"false";
    parameters[OGACallEventListenersCanGoForward] = wkWebView.canGoForward ? @"true" : @"false";
    parameters[OGACallEventListenersWebviewId] = webViewIdentifier;
    parameters[OGACallEventListenersURL] = wkWebView.URL.absoluteString;
    if (pageTitle && ![pageTitle isEqualToString:@""]) {
        parameters[OGACallEventListenersPageTitle] = pageTitle;
    }
    OGAAdDisplayerCallEventListenersInformation *callEventListenersInformation = [[OGAAdDisplayerCallEventListenersInformation alloc] initWithEvent:OGACallEventListenersOnNavigation parameters:parameters];
    [self.displayer executeCommandForOguryBrowser:callEventListenersInformation];
}

- (void)startOMIDSessionOnShow {
    if (!self.ad.launchOmidSessionAtLoad) {
        [self startOMIDSession];
    }
}

- (void)startOMIDSession {
    if (!self.omidSession && self.omidService.isOMIDActive && [self.webViewId isEqualToString:OGANameMainWebView] && self.ad.omidEnabled) {
        self.omidSession = [self.omidService createSessionForAd:self.ad webView:self];
        [self.omidSession startOMIDSession];
    }
}

#pragma mark - MRAIDWebViewSchemeHandlerDelegate

- (void)mraidAction:(OGAMraidCommand *)action {
    if (self.isWebviewClosed && ![action.method isEqual:@"close"]) {
        [self.log logMraidFormat:OguryLogLevelWarning forAdConfiguration:self.ad.adConfiguration webViewId:self.webViewId format:@"Failed to perform %@ sent to closed webview", action.method];
        return;
    }

    [self.log logMraidFormat:OguryLogLevelDebug forAdConfiguration:self.ad.adConfiguration webViewId:self.webViewId format:@"Received mraid action: [%@]", action.method];

    // Pre-cache?
    if (!self.mraidCommandsHandler) {
        self.mraidCommandsHandler = [[OGAMraidCommandsHandler alloc] initWithDelegate:self mraidWebView:self];
    }

    [self.mraidCommandsHandler handleMraidCommand:action];
}

- (void)mraidUnknownCommand:(NSString *)url {
    [self.log logMraidFormat:OguryLogLevelWarning forAdConfiguration:self.ad.adConfiguration webViewId:self.webViewId format:@"Received unknown MRAID action: %@", url];
}

#pragma mark - WeView protocols implementation
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    // start loading
    [self sendNavigationEvent:@"started" webViewIdentifier:self.webViewId wkWebView:self.wkWebView];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.log logMraid:OguryLogLevelError forAdConfiguration:self.ad.adConfiguration webViewId:self.webViewId message:@"Failed to navigate"];
    [self sendNavigationEvent:OGAFinishedEvent webViewIdentifier:self.webViewId wkWebView:self.wkWebView];
    [self sendPrecachingFailEvent];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.log logMraidError:error forAdConfiguration:self.ad.adConfiguration webViewId:self.webViewId message:@"fail navigation with error"];
    [self sendNavigationEvent:OGAFinishedEvent webViewIdentifier:self.webViewId wkWebView:self.wkWebView];
    [self sendPrecachingFailEvent];
}

- (void)sendPrecachingFailEvent {
    if ([self.webViewId isEqualToString:OGANameMainWebView]) {
        [self.monitoringDispatcher sendLoadErrorEventPrecacheFail:OGAMonitoringPrecacheErrorHtmlLoadFailed
                                                  adConfiguration:self.ad.adConfiguration];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;

    BOOL canLoad = url != nil ? [self.urlChangeHandler shouldLoadUrl:url] : NO;

    decisionHandler(canLoad);

    if (canLoad) {
        if (navigationAction.navigationType == WKNavigationTypeLinkActivated && [self.webViewId isEqualToString:OGANameMainWebView]) {
            OGAAdDisplayerCallEventListenersInformation *callEventListenersInformation = [[OGAAdDisplayerCallEventListenersInformation alloc] initWithEvent:OGACallEventListenersOnOpenedURL parameters:@{OGACallEventListenersURL : navigationAction.request.URL.absoluteString}];
            [self.displayer dispatchInformation:callEventListenersInformation];
        } else {
            [self updateWebviewWithNavigationAction:navigationAction];
        }
    }

    [self.log logMraidFormat:OguryLogLevelDebug forAdConfiguration:self.ad.adConfiguration webViewId:self.webViewId format:@"decide policy navigation for %@ --> %@", url.absoluteString, canLoad ? @"true" : @"false"];

    [self interceptRequest:url];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    [self.log logMraidFormat:OguryLogLevelDebug forAdConfiguration:self.ad.adConfiguration webViewId:self.webViewId format:@"decide policy response for %@", (NSHTTPURLResponse *)navigationResponse.response.URL.absoluteString];

    if (((NSHTTPURLResponse *)navigationResponse.response).statusCode != 200) {
        decisionHandler(WKNavigationResponsePolicyCancel);
        return;
    }

    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary<NSString *, id> *body = (NSDictionary<NSString *, id> *)message.body;

    if (!body && !body[OGAGoogleAnalyticsResponseURLKey]) {
        return;
    }

    NSString *responseURL = (NSString *)body[OGAGoogleAnalyticsResponseURLKey];

    if (responseURL != NULL && ![responseURL isKindOfClass:[NSNull class]]) {
        [self.log logMraidFormat:OguryLogLevelDebug forAdConfiguration:self.ad.adConfiguration webViewId:self.webViewId format:@"received url script message for %@ ", responseURL];

        [self interceptRequest:[[NSURL alloc] initWithString:responseURL]];
    }
}

#pragma mark - KPI

- (void)webViewReady {
    BOOL shouldTrack = (!self.createCommand.isUrlLoaded || self.createCommand.url != nil);

    if (self.createCommand.enableTracking && shouldTrack && self.ad.clientTrackerPattern == nil) {
        [self.metricsService enqueueEvent:[[OGAAdHistoryEvent alloc] initWithAd:self.ad url:self.wkWebView.URL.absoluteString source:@"format" pattern:nil interceptURL:nil]];
    }
    self.createCommand.isUrlLoaded = true;
}

- (void)interceptRequest:(NSURL *)url {
    if (self.createCommand.url == nil || self.createCommand.isTrackerIntercepted) {
        return;
    }

    NSString *adClientTrackerPattern = [self.ad.clientTrackerPattern copy];

    if (adClientTrackerPattern) {
        NSError *error;
        NSRegularExpression *clientTrackerPattern = [[NSRegularExpression alloc] initWithPattern:adClientTrackerPattern options:0 error:&error];

        if (error) {
            [self.log logMraidErrorFormat:error forAdConfiguration:self.ad.adConfiguration webViewId:self.webViewId format:@"NSRegularExpression with pattern fail"];
            return;
        }

        long numberOfMatches = [clientTrackerPattern numberOfMatchesInString:url.absoluteString ?: @""
                                                                     options:0
                                                                       range:NSMakeRange(0, url.absoluteString.length ?: 0)];

        if (numberOfMatches > 0) {
            [self.metricsService enqueueEvent:[[OGAAdHistoryEvent alloc] initWithAd:self.ad
                                                                                url:self.wkWebView.URL.absoluteString
                                                                             source:@"format"
                                                                            pattern:adClientTrackerPattern
                                                                       interceptURL:url.absoluteString]];

            self.createCommand.isTrackerIntercepted = YES;
        }
    }
}

/// Check and returns YES if the event needs to be enqueued to be sent later on, NO if the event need to be handled as usual.
- (BOOL)shouldEnqueueEventForAd:(OGAAd *)ad withURL:(NSURL *)url {
    for (NSString *allowedURL in [self.ad.landingPagePrefetchWhitelist componentsSeparatedByString:@"|"]) {
        // If the URL of the request contains of the whitelisted domains, then it should be processed as usual and not enqueued
        if ([url.absoluteString containsString:allowedURL]) {
            return NO;
        }
    }

    return YES;
}

- (void)updateWebviewWithNavigationAction:(WKNavigationAction *)navigationAction {
    if (!navigationAction.targetFrame) {
        [self.wkWebView loadRequest:navigationAction.request];

        [self.log logMraidFormat:OguryLogLevelDebug forAdConfiguration:self.ad.adConfiguration webViewId:self.webViewId format:@"navigation to %@ with target='blank'", navigationAction.request.URL];
    }
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if ([self.webViewId isEqualToString:OGANameMainWebView]) {
        OGAAdDisplayerCallEventListenersInformation *callEventListenersInformation = [[OGAAdDisplayerCallEventListenersInformation alloc] initWithEvent:OGACallEventListenersOnOpenedURL parameters:@{OGACallEventListenersURL : navigationAction.request.URL.absoluteString}];
        [self.displayer dispatchInformation:callEventListenersInformation];
    }
    return nil;
}

@end
