//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAMRAIDAdDisplayer.h"
#import <MediaPlayer/MPVolumeView.h>
#import <WebKit/WebKit.h>
#import "OGAAd+ImpressionSource.h"
#import "OGAAd.h"
#import "OGAAdConfiguration+AdSync.h"
#import "OGAAdDisplayerInformation.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAAdDisplayerUpdateStateInformation.h"
#import "OGAAdDisplayerUpdateViewabilityInformation.h"
#import "OGAAdDisplayerUserCloseSKOverlayInformation.h"
#import "OGAAdDisplayerUserCloseStoreKitInformation.h"
#import "OGAAdExposure.h"
#import "OGAAdImpressionManager.h"
#import "OGAAdLandingPagePrefetcher.h"
#import "OGAAdLoadStateManager.h"
#import "OGAAdSyncManager.h"
#import "OGACloseAdAction.h"
#import "OGACloseSKAction.h"
#import "OGAEXTScope.h"
#import "OGAExpandAdAction.h"
#import "OGAForceCloseAdAction.h"
#import "OGAInternetConnectionChecker.h"
#import "OGAJavascriptCommandExecutor.h"
#import "OGALog.h"
#import "OGAMRAIDAdDisplayer+Volume.h"
#import "OGAMRAIDWebView.h"
#import "OGAMetricsService.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAMraidBrowserWebView.h"
#import "OGAMraidCommand.h"
#import "OGAMraidCommandsHandler.h"
#import "OGAMraidCreateWebViewCommand.h"
#import "OGAMraidSetOrientationPropertiesCommand.h"
#import "OGAMraidUtils.h"
#import "OGAOMIDSession.h"
#import "OGAOpenSKOverlayAction.h"
#import "OGAOpenStoreKitAction.h"
#import "OGAProfigManager.h"
#import "OGASKAdNetworkManager.h"
#import "OGATrackEvent.h"
#import "OGAUnloadAdAction.h"
#import "OGAUserDefaultsStore.h"
#import "OGAWKWebView.h"
#import "OGAWebViewCleanupManager.h"
#import "OGAAdController.h"
#import "OguryAdError+Internal.h"
#import "OGAMraidLogMessage.h"
#import "OGAAdQualityController.h"

#pragma mark - Constants

static NSTimeInterval const OGACloseButtonDelay = 2;
static int const OGACloseButtonTopPadding = 10;
static int const OGACloseButtonTrailingPadding = 10;
static int const OGACloseButtonSize = 40;
static NSUInteger const OGADefaultMaxNumberWebviewReload = 3;

@interface OGAMRAIDAdDisplayer () <OGAMraidCommandsHandlerDelegate, OGAMRAIDWebViewDelegate, OGAAdLoadStateManagerErrorDelegate>

#pragma mark - Properties

@property(nonatomic, strong) OGAUserDefaultsStore *userDefaultsStore;
@property(nonatomic, strong) UIApplication *application;
@property(nonatomic, strong) OGAAdSyncManager *adSyncManager;
@property(nonatomic, strong, readwrite) UIView *view;
@property(nonatomic, strong) OGAMRAIDWebView *containerWebView;
@property(nonatomic, strong) NSMutableArray<OGAMraidBaseWebView *> *webviews;
@property(nonatomic, strong) OGAAdLandingPagePrefetcher *prefetcher;
@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong) UIButton *closeButton;
@property(nonatomic, assign) BOOL isCloseButtonHidden;
@property(nonatomic, assign) OGAAdMraidDisplayerState mraidDisplayerState;
@property(nonatomic, assign) OGAWebViewCleanupManager *webViewCleanupManager;
@property(nonatomic, strong) MPVolumeView *mpVolumeView;
@property(nonatomic, strong) UISlider *volumeSlider;
@property(nonatomic, strong) OGAAdImpressionManager *adImpressionManager;
@property(nonatomic, strong) OGAMraidAdWebView *landingPage;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAProfigManager *profigManager;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAAdQualityController *adQualityController;
@property(nonatomic, assign) NSUInteger numberOfReloadAttempts;

@end

@implementation OGAMRAIDAdDisplayer

static NSString *const OGAMonitoringEventDetailMaxReloadAttemptsReached = @"max_reload_attempts_reached";

#pragma mark - Properties

- (BOOL)hasKeepAlive {
    if (self.ad.adKeepAlive) {
        return YES;
    }

    for (OGAMraidAdWebView *webView in self.webviews) {
        if (webView.createCommand.keepAlive) {
            return YES;
        }
    }

    return NO;
}

#pragma mark - Initialization

- (instancetype)initWithAd:(OGAAd *)ad adConfiguration:(OGAAdConfiguration *)configuration {
    return [self initWithAd:ad
              adConfiguration:configuration
                adSyncManager:[OGAAdSyncManager shared]
        landingPagePrefetcher:OGAAdLandingPagePrefetcher.shared
               metricsService:OGAMetricsService.shared
            userDefaultsStore:[OGAUserDefaultsStore shared]
                  application:UIApplication.sharedApplication
          adImpressionManager:[OGAAdImpressionManager shared]
        webViewCleanupManager:[OGAWebViewCleanupManager shared]
         monitoringDispatcher:[OGAMonitoringDispatcher shared]
                profigManager:[OGAProfigManager shared]
                          log:[OGALog shared]];
}

- (instancetype)initWithAd:(OGAAd *)ad
           adConfiguration:(OGAAdConfiguration *)configuration
             adSyncManager:(OGAAdSyncManager *)adSyncManager
     landingPagePrefetcher:(OGAAdLandingPagePrefetcher *)prefetcher
            metricsService:(OGAMetricsService *)metricsService
         userDefaultsStore:(OGAUserDefaultsStore *)userDefaultsStore
               application:(UIApplication *)application
       adImpressionManager:(OGAAdImpressionManager *)adImpressionManager
     webViewCleanupManager:(OGAWebViewCleanupManager *)webViewCleanupManager
      monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
             profigManager:(OGAProfigManager *)profigManager
                       log:(OGALog *)log {
    if (self = [super init]) {
        _ad = ad;
        _configuration = configuration;
        _adSyncManager = adSyncManager;
        _prefetcher = prefetcher;
        _metricsService = metricsService;
        _userDefaultsStore = userDefaultsStore;
        _application = application;
        _mraidDisplayerState = OGAAdMraidDisplayerStateLoading;
        _webviews = [[NSMutableArray alloc] init];
        _webViewCleanupManager = webViewCleanupManager;
        _adImpressionManager = adImpressionManager;
        _monitoringDispatcher = monitoringDispatcher;
        _log = log;
        _profigManager = profigManager;
        // I had to do this because the OCMock test failed with real OGAMRAIDAdDisplayer launching a timer during tests
        self.stateManager = [OGAMRAIDAdDisplayer stateManagerForTimeout:configuration.webviewLoadTimeout
                                                                     ad:self.ad
                                                            webDelegate:self
                                                          errorDelegate:self];

        [self setupViews];
        [self setupLayout];
        [self setupWebView:self.containerWebView withCommand:nil];
    }

    return self;
}

- (NSUInteger)numberOfReloadAttempts {
    return self.ad.adConfiguration.numberOfWebviewTerminatedReloadAttempts;
}
- (void)setNumberOfReloadAttempts:(NSUInteger)numberOfReloadAttempts {
    self.ad.adConfiguration.numberOfWebviewTerminatedReloadAttempts = numberOfReloadAttempts;
}

+ (OGAAdLoadStateManager *)stateManagerForTimeout:(NSNumber *)timeout
                                               ad:(OGAAd *)ad
                                      webDelegate:(id<OGAMRAIDWebViewDelegate>)webDelegate
                                    errorDelegate:(id<OGAAdLoadStateManagerErrorDelegate>)commandDelegate {
    return [[OGAAdLoadStateManager alloc] initWithAd:ad
                                             timeout:timeout
                                         webDelegate:webDelegate
                                       errorDelegate:commandDelegate];
}

#pragma mark - Methods
- (void)webkitProcessDidTerminate {
    if (self.mraidDisplayerState == OGAAdMraidDisplayerStateBrowserOpened || self.mraidDisplayerState == OGAAdMraidDisplayerStateDefault) {
        OGAMraidCommand *close = [[OGAMraidCommand alloc] init];
        [self closeFullAd:close];
        [self.monitoringDispatcher sendShowEvent:OGAShowEventWebviewTerminatedByOS adConfiguration:self.ad.adConfiguration];
        return;
    }
    NSUInteger maxNumberOfReloadWebView = OGADefaultMaxNumberWebviewReload;
    if (self.ad.maxNumberOfReloadWebView != NULL) {
        maxNumberOfReloadWebView = [self.ad.maxNumberOfReloadWebView intValue];
    }

    BOOL maxReloadAttemptsReached = self.numberOfReloadAttempts >= maxNumberOfReloadWebView;
    [self.monitoringDispatcher sendLoadEvent:OGALoadEventWebviewTerminatedByOS
                             adConfiguration:self.ad.adConfiguration
                                     details:@{
                                         OGAMonitoringEventDetailMaxReloadAttemptsReached : @(maxReloadAttemptsReached),
                                         OGAMonitoringEventDetailWebviewTermination : @(self.numberOfReloadAttempts + 1)
                                     }];
    if (self.mraidDisplayerState == OGAAdMraidDisplayerStateLoading) {
        self.mraidDisplayerState = OGAAdMraidDisplayerStateKilled;
        [self.delegate webkitProcessDidTerminate];
        [self.stateManager invalidateTimer];
        [self.stateManager reset];
        return;
    }
    if (self.mraidDisplayerState == OGAAdMraidDisplayerStateEnded) {
        return;
    }

    [self cleanWebView];
    // if the max is reached then we set the ad as killed
    if (maxReloadAttemptsReached) {
        self.mraidDisplayerState = OGAAdMraidDisplayerStateKilled;
        return;
    }
    // if no internet then we set the ad as killed to avoid failed reload
    [OGAInternetConnectionChecker shared].type = OguryAdErrorTypeLoad;
    if (![[OGAInternetConnectionChecker shared] checkForSequence:NULL error:NULL]) {
        self.mraidDisplayerState = OGAAdMraidDisplayerStateKilled;
        return;
    }
    self.numberOfReloadAttempts++;
    [self setupViews];
    [self setupWebView:self.containerWebView withCommand:nil];
}

- (void)cleanWebView {
    [self.containerWebView removeScriptMessageHandler];
    [self.stateManager reset];
    self.mraidDisplayerState = OGAAdMraidDisplayerStateLoaded;
    [self.containerWebView removeFromSuperview];
    self.containerWebView = nil;
    [self.webviews removeAllObjects];
}

- (void)setupViews {
    if (![NSThread isMainThread]) {
        [NSException raise:@"NotOnMainThread" format:@"Instantiation of MRAID ad displayer must happen on main thread."];
    }

    self.view = [[UIView alloc] init];

    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 50, 50, 50)];

    if (self.configuration.adType != OguryAdsTypeBanner) {
        NSString *imageBase64 = [OGAMraidUtils closeButtonBase64];
        UIImage *closeBtnImage = [OGAMraidUtils decodeBase64ToImage:imageBase64];

        [self.closeButton setImage:closeBtnImage forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(pressedSDKCloseButton) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.closeButton];
        self.closeButton.hidden = YES;
        self.isCloseButtonHidden = NO;
    }

    self.containerWebView = [[OGAMRAIDWebView alloc] initWithAd:self.ad stateManager:self.stateManager];
    self.containerWebView.displayer = self;
    self.containerWebView.mraidCommandsHandler = [[OGAMraidCommandsHandler alloc] initWithDelegate:self mraidWebView:self.containerWebView];
    self.containerWebView.commandExecutor = [[OGAJavascriptCommandExecutor alloc] initWithWebView:self.containerWebView];
    self.stateManager.stateDelegate = (id<OGAAdLoadStateManagerDelegate>)self.containerWebView;

    // TODO : to remove properly
    /*if (self.ad.landingPagePrefetchURL.length > 0) {
        [self.metricsService holdEventsForAd:self.ad];

        [self.prefetcher prefetchLandingPageForAd:self.ad];
    }*/

    [self.view insertSubview:self.containerWebView atIndex:0];
    [self.webviews addObject:self.containerWebView];
    [self setupVolumeView];
}

- (void)prefetchLandingPageIfNecessary {
    // TODO : to remove properly
    /*if (self.ad.landingPagePrefetchURL.length > 0) {
        // If landing page URL is present, we should pre-load the landing page
        self.landingPage = [[OGAMraidBaseView alloc] initWithAd:self.ad];
    }*/
}

- (void)setupLayout {
    self.containerWebView.translatesAutoresizingMaskIntoConstraints = NO;

    if (self.configuration.adType != OguryAdsTypeBanner) {
        self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;

        [NSLayoutConstraint activateConstraints:@[
            [self.closeButton.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                                       constant:OGACloseButtonTopPadding],
            [self.closeButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                                            constant:-OGACloseButtonTrailingPadding],
            [self.closeButton.widthAnchor constraintEqualToConstant:OGACloseButtonSize],
            [self.closeButton.heightAnchor constraintEqualToConstant:OGACloseButtonSize]
        ]];
    }
}

- (BOOL)isDisplayed:(id<OGAAdDisplayerInformation> _Nonnull)information {
    return self.mraidDisplayerState != OGAAdMraidDisplayerStateBrowserOpened && [information isKindOfClass:[OGAAdDisplayerUpdateStateInformation class]] &&
        ((OGAAdDisplayerUpdateStateInformation *)information).rawMraidState == OGAMRAIDStateDefault;
}

- (void)dispatchInformation:(id<OGAAdDisplayerInformation>)information {
    if (self.mraidDisplayerState == OGAAdMraidDisplayerStateBrowserOpened && [information isKindOfClass:[OGAAdDisplayerUpdateExposureInformation class]]) {
        [self.containerWebView.commandExecutor evaluateJS:[[[OGAAdDisplayerUpdateExposureInformation alloc] initWithExposure:[OGAAdExposure zeroExposure]] toJavascriptCommand]];
        return;
    }
    if ([self isDisplayed:information]) {
        if (self.mraidDisplayerState == OGAAdMraidDisplayerStateKilled) {
            OGAMraidCommand *close = [[OGAMraidCommand alloc] init];
            [self closeFullAd:close];
        }
        self.mraidDisplayerState = OGAAdMraidDisplayerStateDefault;
    }
    if ([information isKindOfClass:[OGAAdDisplayerUserCloseStoreKitInformation class]] || [information isKindOfClass:[OGAAdDisplayerUserCloseSKOverlayInformation class]]) {
        [self.delegate performAction:[[OGACloseSKAction alloc] init] error:nil];
    }
    [self.containerWebView.commandExecutor evaluateJS:[information toJavascriptCommand]];
}

- (void)dispatchNoViewabilityAndZeroExposure {
    [self dispatchInformation:[[OGAAdDisplayerUpdateExposureInformation alloc] initWithExposure:[OGAAdExposure zeroExposure]]];
    [self dispatchInformation:[[OGAAdDisplayerUpdateViewabilityInformation alloc] initWithViewability:NO]];
}

- (BOOL)isLoaded {
    return (self.mraidDisplayerState == OGAAdMraidDisplayerStateLoaded || self.mraidDisplayerState == OGAAdMraidDisplayerStateBrowserOpened);
}

- (BOOL)isKilled {
    return self.mraidDisplayerState == OGAAdMraidDisplayerStateKilled;
}

- (void)cleanUp {
    [[OGASKAdNetworkManager shared] stopImpressionWithAd:self.ad];
    [self dispatchNoViewabilityAndZeroExposure];

    self.mraidDisplayerState = OGAAdMraidDisplayerStateEnded;

    [self unregisterFromVolumeChange];
    [self.stateManager invalidateTimer];
    [self.webViewCleanupManager cleanUpObject:self.containerWebView];

    if (self.containerWebView.omidSession) {
        [self.containerWebView.omidSession stopOMIDSession];
    }
    [self.adQualityController cleanUp];
    self.adQualityController = nil;
}

- (OGAMraidAdWebView *)mraidViewForId:(NSString *)webViewId {
    for (OGAMraidAdWebView *webView in self.webviews) {
        if ([webView.webViewId isEqualToString:webViewId]) {
            return webView;
        }
    }

    return nil;
}

- (void)setCloseButtonAsHidden:(BOOL)hidden withDelay:(NSTimeInterval)delay {
    if (hidden == self.isCloseButtonHidden) {
        return;
    }

    // Update the local variable as this method can be called multiple times but only the last value must be applied
    self.isCloseButtonHidden = hidden;

    dispatch_async(dispatch_get_main_queue(), ^{
        self.closeButton.hidden = self.isCloseButtonHidden;
    });
}

- (void)setupCloseButtonTimer {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(OGACloseButtonDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.closeButton.hidden = self.isCloseButtonHidden;
    });
}

- (void)registerForVolumeChange {
    [self registerForVolumeChangeFromVolumeSlider];
}

- (void)setUseCustomCloseButton:(BOOL)useCustomCloseButton {
    [self setCloseButtonAsHidden:useCustomCloseButton withDelay:OGACloseButtonDelay];
}

- (void)createWebView:(OGAMraidCommand *)command {
    [OGAInternetConnectionChecker shared].type = OguryAdErrorTypeLoad;
    if (![[OGAInternetConnectionChecker shared] checkForSequence:NULL error:NULL]) {
        [self forceClose:[OGAMraidCommand MraidCloseCommandWithNextAdFalse]];
        return;
    }

    // Thumbnail and Banner needs to be expanded right away for landing page
    if (self.configuration.adType == OguryAdsTypeThumbnailAd || self.configuration.adType == OguryAdsTypeBanner) {
        [self dispatchNoViewabilityAndZeroExposure];
        [self expand];
    }

    self.mraidDisplayerState = OGAAdMraidDisplayerStateBrowserOpened;

    OGAMraidCreateWebViewCommand *browserCommand = [[OGAMraidCreateWebViewCommand alloc] initWithDictionary:command.args error:nil];

    OGAMraidBrowserWebView *webView = [[OGAMraidBrowserWebView alloc] initWithCommand:browserCommand ad:self.containerWebView.ad];

    [webView setupWithCommand:browserCommand];
    webView.createCommand = browserCommand;
    webView.mraidCommandsHandler = [[OGAMraidCommandsHandler alloc] initWithDelegate:self mraidWebView:webView];
    webView.commandExecutor = [[OGAJavascriptCommandExecutor alloc] initWithWebView:webView];
    webView.displayer = self;

    if ([webView.webViewId isEqualToString:OGANameBrowserLandingPageWebView]) {
        [self.monitoringDispatcher sendShowEvent:OGAShowEventOpenLandingPage adConfiguration:self.ad.adConfiguration];
    }

    if ([browserCommand.webViewId isEqualToString:OGANameBrowserWebView]) {
        [webView loadWebViewWithCommandforBrowser:browserCommand];
    }

    if ([@[ OGANameMainWebView, OGANameBrowserWebView ] containsObject:webView.webViewId]) {
        [self setCloseButtonAsHidden:self.isCloseButtonHidden withDelay:OGACloseButtonDelay];
    }

    [self.webviews addObject:webView];
    [self.view addSubview:webView];

    // Place close button on top
    [self.view bringSubviewToFront:self.closeButton];

    [self setupWebView:webView withCommand:browserCommand];

    if ([webView.webViewId isEqualToString:OGANameBrowserLandingPageWebView]) {
        [self.monitoringDispatcher sendShowEvent:OGAShowEventLandingPageOpened adConfiguration:self.ad.adConfiguration];
    }
}

- (CGSize)sizeForWebViewWithConfiguration:(OGAAdConfiguration *)configuration command:(OGAMraidCreateWebViewCommand *)command view:(UIView *)view containerWebView:(OGAMRAIDWebView *)containerWebView {
    NSNumber *width;
    NSNumber *height;

    if ([@[ OGANameBrowserWebView, OGANameRecommendedLinksWebView, OGANameBrowserLandingPageWebView ] containsObject:command.webViewId]) {
        width = nil;
        height = nil;
    } else {
        width = command.size[@"width"];
        height = command.size[@"height"];
    }

    if (configuration.adType == OguryAdsTypeBanner && self.mraidDisplayerState != OGAAdMraidDisplayerStateBrowserOpened) {
        if (containerWebView.ad.bannerAdResponse.fullWidth != nil && [containerWebView.ad.bannerAdResponse.fullWidth boolValue]) {
            width = [NSNumber numberWithFloat:view.frame.size.width];
        } else {
            width = [NSNumber numberWithFloat:configuration.size.width];
        }
        height = [NSNumber numberWithFloat:configuration.size.height];
    }

    return CGSizeMake(width.floatValue, height.floatValue);
}

- (void)setupWebView:(OGAMraidBaseWebView *)webView withCommand:(OGAMraidCreateWebViewCommand *)command {
    if (!self.view) {
        return;
    }

    CGSize webViewSize = [self sizeForWebViewWithConfiguration:self.configuration command:command view:self.view containerWebView:self.containerWebView];

    NSNumber *horizontalOffset = command.position[@"x"];
    NSNumber *verticalOffset = command.position[@"y"];

    webView.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *widthConstraint = [webView.widthAnchor constraintEqualToConstant:@(webViewSize.width).floatValue];
    widthConstraint.identifier = [NSString stringWithFormat:@"%@%@", @"widthConstraint", webView.webViewId];

    NSLayoutConstraint *heightConstraint = [webView.heightAnchor constraintEqualToConstant:@(webViewSize.height).floatValue];
    heightConstraint.identifier = [NSString stringWithFormat:@"%@%@", @"heightConstraint", webView.webViewId];

    NSLayoutConstraint *topAnchorConstraint = [webView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:verticalOffset.floatValue];
    topAnchorConstraint.identifier = [NSString stringWithFormat:@"%@%@", @"topAnchorConstraint", webView.webViewId];

    NSLayoutConstraint *trailingAnchorConstraint = [webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor];
    trailingAnchorConstraint.identifier = [NSString stringWithFormat:@"%@%@", @"trailingAnchorConstraint", webView.webViewId];

    NSLayoutConstraint *bottomAnchorConstraint = [webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    bottomAnchorConstraint.identifier = [NSString stringWithFormat:@"%@%@", @"bottomAnchorConstraint", webView.webViewId];

    NSLayoutConstraint *leadingAnchorConstraint = [webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:horizontalOffset.floatValue];
    leadingAnchorConstraint.identifier = [NSString stringWithFormat:@"%@%@", @"leadingAnchorConstraint", webView.webViewId];

    if (webViewSize.height == 0 || webViewSize.width == 0) {
        [self deactivateConstrainIfFound:widthConstraint inView:self.view];
        [self deactivateConstrainIfFound:heightConstraint inView:self.view];
        [self replaceOrAddConstraint:bottomAnchorConstraint inView:self.view];
        [self replaceOrAddConstraint:trailingAnchorConstraint inView:self.view];
    } else {
        [self deactivateConstrainIfFound:bottomAnchorConstraint inView:self.view];
        [self deactivateConstrainIfFound:trailingAnchorConstraint inView:self.view];
        [self replaceOrAddConstraint:widthConstraint inView:self.view];
        [self replaceOrAddConstraint:heightConstraint inView:self.view];
    }

    [self replaceOrAddConstraint:topAnchorConstraint inView:self.view];
    [self replaceOrAddConstraint:leadingAnchorConstraint inView:self.view];

    if (@available(iOS 11.0, *)) {
        [self.containerWebView.wkWebView.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        self.containerWebView.wkWebView.scrollView.contentInset = UIEdgeInsetsZero;
    }
}

- (void)deactivateConstrainIfFound:(NSLayoutConstraint *)constraint inView:(UIView *)view {
    NSLayoutConstraint *existingConstraint = [self constraintForIdentifier:constraint.identifier inView:view];
    if (existingConstraint) {
        [existingConstraint setActive:NO];
    }
}

- (void)replaceOrAddConstraint:(NSLayoutConstraint *)constraint inView:(UIView *)view {
    NSLayoutConstraint *existingConstraint = [self constraintForIdentifier:constraint.identifier inView:view];
    if (existingConstraint) {
        existingConstraint.constant = constraint.constant;
    } else {
        [view addConstraint:constraint];
        [constraint setActive:YES];
    }
}

- (NSLayoutConstraint *)constraintForIdentifier:(NSString *)identifier inView:(UIView *)view {
    for (NSLayoutConstraint *constraint in view.constraints) {
        if ([constraint.identifier isEqualToString:identifier]) {
            return constraint;
        }
    }

    return nil;
}

- (void)executeCommandForOguryBrowser:(id<OGAAdDisplayerInformation>)information {
    OGAMraidAdWebView *navigationBrowser = [self mraidViewForId:OGANameBrowserWebView];
    [navigationBrowser.wkWebView goBack];
    if (navigationBrowser) {
        [navigationBrowser.commandExecutor evaluateJS:[information toJavascriptCommand]];
    }
}

- (void)expand {
    [self safeDelegateCallWithAction:[[OGAExpandAdAction alloc] init]];
}

- (void)adClicked {
    [self.monitoringDispatcher sendShowEvent:OGAShowEventAdClicked adConfiguration:self.ad.adConfiguration];

    if ([self.configuration.delegateDispatcher respondsToSelector:@selector(clicked)]) {
        [self.configuration.delegateDispatcher clicked];
    }
}

- (void)adImpressionFormat {
    if (![self.ad isImpressionSourceFormat]) {
        return;
    }
    [self.adImpressionManager sendFormatImpressionTrackFor:self.ad];

    if ([self.configuration.delegateDispatcher respondsToSelector:@selector(adImpression)] && [self.ad isImpressionSourceFormat] && ![self.adImpressionManager isImpressionDelegateSentFor:self.ad]) {
        [self.configuration.delegateDispatcher adImpression];
        [self.adImpressionManager hasSentImpressionDelegateFor:self.ad];
    }
}

- (void)forceClose:(OGAMraidCommand *)command {
    if ([command.method isEqualToString:@"close"] && self.configuration.adType == OguryAdsTypeBanner) {
        // Collapsible format must perform a forceClose when performing a "close" or "unload" on the Ogury browser
        // An exception must be made for Banner since closing an expanded banner must ONLY close the expanded ad and leave the collapsed banner ad visible
        [self closeFullAd:command];
    } else if ([self.delegate respondsToSelector:@selector(performAction:error:)]) {
        [self.prefetcher clearLandingPageForAd:self.ad];
        [self.delegate performAction:[[OGAForceCloseAdAction alloc] init] error:nil];
        [self.monitoringDispatcher sendShowEvent:OGAShowEventAdClose adConfiguration:self.ad.adConfiguration];
    }
}

- (void)pressedSDKCloseButton {
    if (self.containerWebView.ad.sdkCloseButtonUrl) {
        [self.adSyncManager fetchCustomCloseWithURL:[NSURL URLWithString:self.containerWebView.ad.sdkCloseButtonUrl]];
    }

    [self closeFullAd:[OGAMraidCommand MraidCloseCommandWithNextAdFalse]];
}

- (void)closeFullAd:(OGAMraidCommand *)command {
    [self.prefetcher clearLandingPageForAd:self.ad];
    OGANextAd *nextAd = [[OGANextAd alloc] initWithDictionary:command.args error:nil];
    [self safeDelegateCallWithAction:[[OGACloseAdAction alloc] initWithNextAd:nextAd]];
    [self.monitoringDispatcher sendShowEvent:OGAShowEventAdClose adConfiguration:self.ad.adConfiguration];
}

- (void)unloadAd:(OGAMraidCommand *)command origin:(UnloadOrigin)origin {
    [self.prefetcher clearLandingPageForAd:self.ad];

    // Ad is already displayed -> Show Information since there are no errors
    if ([self.delegate respondsToSelector:@selector(adIsDisplayed)] && [self.delegate adIsDisplayed]) {
        [self.monitoringDispatcher sendShowEvent:OGAShowEventForegroundUnload adConfiguration:self.ad.adConfiguration];
        // if the ad is already loaded, it's a Load information
    } else if ([self.delegate isKindOfClass:[OGAAdController class]] && [(OGAAdController *)self.delegate isLoaded]) {
        [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdBackgroundUnloaded adConfiguration:self.ad.adConfiguration];
        if ([self.configuration.delegateDispatcher respondsToSelector:@selector(failedWithError:)]) {
            [self.configuration.delegateDispatcher failedWithError:[OguryAdError adPrecachingFailedWithStackTrace:@"Unload"]];
        }
        // unload received while the load has not yet finish -> Load Error
    } else if (origin == UnloadOriginFormat) {
        [self.monitoringDispatcher sendLoadErrorEventPrecacheFail:OGAMonitoringPrecacheErrorUnload
                                                  adConfiguration:self.ad.adConfiguration];
        if ([self.configuration.delegateDispatcher respondsToSelector:@selector(failedWithError:)]) {
            [self.configuration.delegateDispatcher failedWithError:[OguryAdError adPrecachingFailedWithStackTrace:@"Unload"]];
        }
    }
    [self safeDelegateCallWithAction:[[OGAUnloadAdAction alloc] initWithNextAd:[OGANextAd nextAdTrue]]];
}

- (void)openStoreKit:(OGAMraidCommand *)command {
    [self safeDelegateCallWithAction:[[OGAOpenStoreKitAction alloc] init]];
}

- (void)openSKOverlay:(OGAMraidCommand *)command {
    [self safeDelegateCallWithAction:[[OGAOpenSKOverlayAction alloc] init]];
}

- (void)safeDelegateCallWithAction:(id<OGAAdAction>)action {
    if ([self.delegate respondsToSelector:@selector(performAction:error:)]) {
        [self.delegate performAction:action error:nil];
    }
}

- (void)eulaConsentStatus:(BOOL)accepted {
    [self.profigManager resetProfig];
}

- (void)closeSKOverlay:(OGAMraidCommand *)command {
    [self safeDelegateCallWithAction:[[OGACloseSKAction alloc] init]];
}

- (void)closeWebView:(nonnull OGAMraidCommand *)command {
    [self.prefetcher clearLandingPageForAd:self.ad];

    OGAMraidAdWebView *webViewToClose = [self mraidViewForId:command.args[@"webViewId"]];

    if (!webViewToClose) {
        return;
    }

    if ([webViewToClose.webViewId isEqualToString:OGANameBrowserLandingPageWebView]) {
        [self.monitoringDispatcher sendShowEvent:OGAShowEventCloseLandingPage adConfiguration:self.ad.adConfiguration];
    }

    if ([command.args[@"webViewId"] isEqualToString:OGANameBrowserWebView]) {
        self.mraidDisplayerState = OGAAdMraidDisplayerStateLoaded;
    }

    // Remove any script message handler to prevent memory leak through the WKWebView's configuration
    [webViewToClose removeScriptMessageHandler];

    [self.webviews removeObject:webViewToClose];

    [webViewToClose removeFromSuperview];

    if ([webViewToClose.webViewId isEqualToString:OGANameBrowserLandingPageWebView]) {
        [self.monitoringDispatcher sendShowEvent:OGAShowEventLandingPageClosed adConfiguration:self.ad.adConfiguration];
    }
}

- (void)executeBackActionForWebViewId:(NSString *)webViewId {
    OGAMraidAdWebView *desiredBrowser = [self mraidViewForId:webViewId];

    if (desiredBrowser) {
        [desiredBrowser.wkWebView goBack];
    }
}

- (void)executeForwardActionForWebViewId:(NSString *)webViewId {
    OGAMraidAdWebView *desiredBrowser = [self mraidViewForId:webViewId];

    if (desiredBrowser) {
        [desiredBrowser.wkWebView goForward];
    }
}

- (void)resizeProps:(nonnull OGAMraidCommand *)command {
    [self handleResizeCommand:command];
}

- (void)setOrientationProperties:(OGAMraidCommand *)command {
    OGAMraidSetOrientationPropertiesCommand *browserCommand = [[OGAMraidSetOrientationPropertiesCommand alloc] initWithDictionary:command.args error:nil];
    [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                            adConfiguration:self.ad.adConfiguration
                                                  webviewId:@""
                                                    message:@"setOrientationProperties"
                                                       tags:@[
                                                           [OguryLogTag tagWithKey:@"allowOrientationChange"
                                                                             value:browserCommand.allowOrientationChange ? @"YES" : @"NO"],
                                                           [OguryLogTag tagWithKey:@"forceOrientation"
                                                                             value:browserCommand.forceOrientation ? @"YES" : @"NO"]
                                                       ]]];

    if (browserCommand.forceOrientation != nil) {
        UIInterfaceOrientationMask newOrientation = UIInterfaceOrientationMaskAll;
        if ([browserCommand.forceOrientation isEqualToString:@"portrait"]) {
            newOrientation = UIInterfaceOrientationMaskPortrait;
        } else if ([browserCommand.forceOrientation isEqualToString:@"landscape"]) {
            newOrientation = UIInterfaceOrientationMaskLandscape;
        }
        [self.orientationDelegate forceOrientation:newOrientation];
    } else if (browserCommand.allowOrientationChange) {
        [self.orientationDelegate allowOrientationChange:browserCommand.allowOrientationChange.intValue > 0 ? YES : NO];
    }
}

- (void)rewardWasReceived {
    if ([self.configuration.delegateDispatcher respondsToSelector:@selector(rewarded:)]) {
        OguryReward *reward = [[OguryReward alloc] initWithRewardName:self.ad.adUnit.rewardName rewardValue:self.ad.adUnit.rewardValue];

        if (reward && self.configuration.adType == OguryAdsTypeRewardedAd) {
            [self.configuration.delegateDispatcher rewarded:reward];
        }
    }
}

- (void)openUrl:(NSURL *)url {
    [self.monitoringDispatcher sendShowEvent:OGAShowEventLauchBrowser adConfiguration:self.ad.adConfiguration];
}

- (void)updateWebView:(nonnull OGAMraidCommand *)command {
    OGAMraidCreateWebViewCommand *browserCommand = [[OGAMraidCreateWebViewCommand alloc] initWithDictionary:command.args error:nil];
    if (browserCommand.size) {
        [self handleResizeCommand:command];
    }

    if (browserCommand.url) {
        [[self mraidViewForId:browserCommand.webViewId] loadWithURL:browserCommand.url];
    }
}

- (void)handleResizeCommand:(OGAMraidCommand *)command {
    OGAMraidCreateWebViewCommand *browserCommand = [[OGAMraidCreateWebViewCommand alloc] initWithDictionary:command.args error:nil];

    OGAMraidAdWebView *baseView = [self mraidViewForId:browserCommand.webViewId];
    if (baseView) {
        [self setupWebView:baseView withCommand:browserCommand];
        [baseView setNeedsUpdateConstraints];
    }
}

- (void)startOMIDSessionOnShow {
    OGAMraidAdWebView *mainWebView = [self mraidViewForId:OGANameMainWebView];
    [mainWebView startOMIDSessionOnShow];
}

- (void)bunaZiua {
    if (self.mraidDisplayerState == OGAAdMraidDisplayerStateBrowserOpened) {
        return;
    } else {
        if (self.stateManager.webviewReadyToLoad) {
            [self.stateManager setMraidEnvironmentIsUp:YES];
        } else {
            [self.stateManager setWebviewReadyToLoad:YES];
        }
    }
}

- (BOOL)mraidCommunicationIsUp {
    return [self.stateManager mraidEnvironmentIsUp];
}

- (BOOL)webViewLoaded:(NSString *)webViewId {
    return [self.stateManager webViewLoaded:webViewId];
}

- (void)formatDidLoadAd {
    [self.stateManager setFormatLoaded:YES];
}

#pragma mark - OGAMRAIDWebViewDelegate

- (void)webViewNotReady:(NSString *)adID {
    [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                            adConfiguration:self.ad.adConfiguration
                                                  webviewId:@""
                                                    message:@"Webview is not ready"
                                                       tags:nil]];
}

- (void)webViewReady:(NSString *)adID {
    switch (self.mraidDisplayerState) {
        case OGAAdMraidDisplayerStateLoading:
            [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                    adConfiguration:self.ad.adConfiguration
                                                          webviewId:@""
                                                            message:@"Webview is ready"
                                                               tags:nil]];

            self.mraidDisplayerState = OGAAdMraidDisplayerStateLoaded;
            if ([self.delegate respondsToSelector:@selector(didLoad)]) {
                [self.delegate didLoad];
            }
            break;

        case OGAAdMraidDisplayerStateEnded:
            [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                    adConfiguration:self.ad.adConfiguration
                                                          webviewId:@""
                                                            message:@"Webview is ready but ad was ended"
                                                               tags:nil]];

            if ([self.delegate respondsToSelector:@selector(didUnLoadFrom:)]) {
                [self.delegate didUnLoadFrom:UnloadOriginFormat];
            }
            break;

        default:
            [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                    adConfiguration:self.ad.adConfiguration
                                                          webviewId:@""
                                                            message:[NSString stringWithFormat:@"Webview is ready but state was not loading but %ld instead", self.mraidDisplayerState]
                                                               tags:nil]];

            break;
    }
}

- (void)loadTimedOut {
    [self.delegate didUnLoadFrom:UnloadOriginTimeout];
}

- (WKWebView *)adWebview {
    OGAMraidAdWebView *mainWebView = [self mraidViewForId:OGANameMainWebView];
    return mainWebView.wkWebView;
}

- (void)performQualityChecks {
    __weak OGAMRAIDAdDisplayer *wself = self;
    self.adQualityController = [[OGAAdQualityController alloc] initFrom:wself.profigManager.currentAdQualityConfiguration];
    [self.adQualityController performAdQualityChecksOn:wself.view adConfiguration:wself.configuration];
}

@end
