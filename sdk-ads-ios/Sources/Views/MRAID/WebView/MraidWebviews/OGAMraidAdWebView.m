//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGAMraidAdWebView.h"
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
#import "OGAEXTScope.h"
#import "OGACallEventListenersConstants.h"
#import "OGAAdDisplayerCallEventListenersInformation.h"
#import "OGAMraidInitializationOperation.h"
#import "OGAMraidLoadHTMLOperation.h"
#import "OGAMraidVerificationOperation.h"
#import "OGAMRAIDWebViewDelegate.h"
#import "OGAMraidBaseWebView+PrivateHeader.h"
#import "OGAMraidLogMessage.h"
#import "OGAMonitoringDispatcher.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#pragma mark - Constants

NSInteger const OGAConditionLockWaiting = 0;
NSInteger const OGAConditionLockShouldProceedLoadHTML = 1;
NSInteger const OGAConditionLockShouldProceedCommand = 2;

static NSString *const OGAGoogleAnalyticsResponseURLKey = @"responseURL";
static int const OGATimeAllowedToLoadMRAID = 10;
static NSString *const OGAadLoadingStateKey = @"adLoadingState";

@interface OGAMraidAdWebView () <OGAAdLoadStateManagerDelegate>

@property(nonatomic, strong) NSConditionLock *conditionLock;

@end

@implementation OGAMraidAdWebView

#pragma mark - Initialization

- (void)setDisplayer:(id<OGAAdDisplayer>)displayer {
    [super setDisplayer:displayer];
    [self.displayer.stateManager addObserver:self forKeyPath:OGAadLoadingStateKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)dealloc {
    [self.displayer.stateManager removeObserver:self forKeyPath:OGAadLoadingStateKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:OGAadLoadingStateKey]) {
        if (self.displayer.stateManager.mraidEnvironmentIsUp) {
            [self.conditionLock unlockWithCondition:OGAConditionLockShouldProceedCommand];
            return;
        }
        if (self.displayer.stateManager.webviewReadyToLoad) {
            [self.conditionLock unlockWithCondition:OGAConditionLockShouldProceedLoadHTML];
        }
    }
}

#pragma mark - Methods
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [self.log logMraid:OguryLogLevelWarning forAdConfiguration:self.ad.adConfiguration webViewId:self.webViewId message:@"webViewWebContentProcessDidTerminate ☣️"];
    [self.displayer webkitProcessDidTerminate];
}

- (BOOL)isCommunicatingWithMraid {
    return self.displayer.stateManager.mraidEnvironmentIsUp;
}

- (void)loadWithContent:(NSString *)content {
    if (self.ad.adUnit) {
        [self startMRAIDProcessForContent:content];
    }
}

/// Start the MRAID initialisation process for the WKWebView
- (void)startMRAIDProcessForContent:(NSString *)content {
    if (self.isPerformingMRAIDInitialization) {
        [self.log logMraid:OguryLogLevelWarning
            forAdConfiguration:self.ad.adConfiguration
                     webViewId:self.webViewId
                       message:@"Trying to perform a dual MRAID initialization"];
        return;
    }

    self.conditionLock = [[NSConditionLock alloc] initWithCondition:OGAConditionLockWaiting];

    NSString *baseURLString = self.ad.webViewBaseUrl ? self.ad.webViewBaseUrl : OGAMraidBaseWebViewBaseURL;
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    NSString *mraidEnv = [OGAMraidEnviromentBuilder generateMraidEnviroment:self.ad.adUnit];
    NSString *mraidFile = [[OGAUserDefaultsStore shared] stringForKey:self.ad.mraidDownloadUrl];
    if (!mraidFile) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.wkWebView evaluateJavaScript:mraidFile
                         completionHandler:^(id _Nullable result, NSError *_Nullable error) {
                             if (error) {
                                 [self.log logMraidError:error
                                      forAdConfiguration:self.ad.adConfiguration
                                               webViewId:self.webViewId
                                                 message:@"An error occurred during MRAID evaluation in webview"];
                             }
                         }];
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.conditionLock lockWhenCondition:OGAConditionLockShouldProceedLoadHTML
                                   beforeDate:[[NSDate date] dateByAddingTimeInterval:OGATimeAllowedToLoadMRAID]];

        dispatch_async(dispatch_get_main_queue(), ^{
            WKUserContentController *userContentController = self.wkWebView.configuration.userContentController;
            [userContentController addUserScript:[[WKUserScript alloc] initWithSource:mraidEnv
                                                                        injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                                     forMainFrameOnly:NO]];
            [userContentController addUserScript:[[WKUserScript alloc] initWithSource:mraidFile
                                                                        injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                                     forMainFrameOnly:YES]];
            [self.wkWebView loadHTMLString:content baseURL:baseURL];
            if (SYSTEM_VERSION_LESS_THAN(@"15.0")) {
                [self.displayer.stateManager setMraidEnvironmentIsUp:YES];
            }
        });
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.conditionLock lockWhenCondition:OGAConditionLockShouldProceedCommand
                                   beforeDate:[[NSDate date] dateByAddingTimeInterval:OGATimeAllowedToLoadMRAID]];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isCommunicatingWithMraid) {
                [self.mraidCommandsHandler sendLoadCommands];
            } else {
                [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelError
                                                        adConfiguration:self.ad.adConfiguration
                                                              webviewId:self.webViewId
                                                                message:@"MRAID has not been initialized for webview"
                                                                   tags:nil]];
                [self.mraidCommandsHandler handleMraidCommand:[OGAMraidCommand mraidTimeoutUnloadCommand]];
            }
        });
    });
}

#pragma mark - WeView protocols implementation

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ([self.displayer webViewLoaded:self.webViewId] == NO) {
        [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelError
                                                adConfiguration:self.ad.adConfiguration
                                                      webviewId:self.webViewId
                                                        message:@"BunaZiua not received before ad finishes to load."
                                                           tags:nil]];
        return;
    }
}

#pragma mark - OGAAdLoadStateManagerDelegate
- (void)adIsFullyLoaded {
    if (self.ad.launchOmidSessionAtLoad) {
        [self startOMIDSession];
    }

    [self sendNavigationEvent:OGAFinishedEvent
            webViewIdentifier:self.webViewId
                    wkWebView:self.wkWebView
                    pageTitle:self.wkWebView.title];

    [self webViewReady];
}

@end
