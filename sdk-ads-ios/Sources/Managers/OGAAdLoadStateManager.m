//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGAAdLoadStateManager.h"
#import "OGAAd.h"
#import "OGAMraidAdWebView.h"
#import "OGAMraidCommand.h"
#import "OguryAdError+Internal.h"
#import "OGAMonitoringDispatcher.h"

#pragma mark - Enums and constants

static NSInteger const defaultDelayForSendingLoaded = 1;

#pragma mark - Private interface
@interface OGAAdLoadStateManager ()

@property(nonatomic, retain) OGAAd *ad;
@property(nonatomic) AdLoadingState adLoadingState;
@property(nonatomic, retain) NSTimer *timeoutTimer;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) NSMutableArray<NSString *> *accomplishedSteps;
@property(nonatomic, strong) NSDate *precachingStartDate;

- (BOOL)adLoaded;
- (void)webViewIsReadyForSDKBehavior:(NSString *)webViewId;
- (void)triggerStateDelegateIfPossible;

@end

NSString *const OGAAccomplishedMraid = @"mraid";
NSString *const OGAAccomplishedHtmlReady = @"html";
NSString *const OGAAccomplishedOnAdLoaded = @"format";

#pragma mark - Implementation
@implementation OGAAdLoadStateManager
#pragma mark - Initialisation

- (instancetype)initWithAd:(OGAAd *)ad
                   timeout:(NSNumber *)timeOut
               webDelegate:(id<OGAMRAIDWebViewDelegate>)webDelegate
             errorDelegate:(id<OGAAdLoadStateManagerErrorDelegate>)commandDelegate {
    return [self init:ad
                     timeout:timeOut
                 webDelegate:webDelegate
               errorDelegate:commandDelegate
        monitoringDispatcher:[OGAMonitoringDispatcher shared]];
}

- (instancetype)init:(OGAAd *)ad
                 timeout:(NSNumber *)timeOut
             webDelegate:(id<OGAMRAIDWebViewDelegate>)webDelegate
           errorDelegate:(id<OGAAdLoadStateManagerErrorDelegate>)commandDelegate
    monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher {
    if (self = [super init]) {
        _ad = ad;
        _webViewDelegate = webDelegate;
        _adLoadingState = AdLoadingStateIdle;
        _commandDelegate = commandDelegate;
        _monitoringDispatcher = monitoringDispatcher;
        _accomplishedSteps = [@[] mutableCopy];
        _precachingStartDate = [NSDate date];
        // start a global timer to invalidate everything if something went wrong
        [self handleFormatTimer:timeOut];
    }
    return self;
}

- (void)dealloc {
    [self invalidateTimer];
}

- (void)reset {
    self.adLoadingState = AdLoadingStateIdle;
}

- (void)setMraidEnvironmentIsUp:(BOOL)mraidEnvironmentIsUp {
    if (mraidEnvironmentIsUp) {
        [self.accomplishedSteps addObject:OGAAccomplishedMraid];
        self.adLoadingState |= AdLoadingStateConnect;
    } else {
        [self.accomplishedSteps removeObject:OGAAccomplishedMraid];
        self.adLoadingState &= ~AdLoadingStateConnect;
    }
    [self triggerStateDelegateIfPossible];
}

- (BOOL)mraidEnvironmentIsUp {
    return self.adLoadingState & AdLoadingStateConnect;
}

- (void)setWebviewReadyToLoad:(BOOL)webViewLoaded {
    if (webViewLoaded) {
        self.adLoadingState |= AdLoadingStateWebviewReady;

        [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdPrecachedInWebview
                                 adConfiguration:self.ad.adConfiguration];
    } else {
        self.adLoadingState &= ~AdLoadingStateWebviewReady;
    }
    [self triggerStateDelegateIfPossible];
}

- (BOOL)webviewReadyToLoad {
    return self.adLoadingState & AdLoadingStateWebviewReady;
}

- (void)setFormatLoaded:(BOOL)formatLoaded {
    if (formatLoaded) {
        [self.accomplishedSteps addObject:OGAAccomplishedOnAdLoaded];
        self.adLoadingState |= AdLoadingStateFormatReady;
    } else {
        [self.accomplishedSteps removeObject:OGAAccomplishedOnAdLoaded];
        self.adLoadingState &= ~AdLoadingStateFormatReady;
    }
    [self triggerStateDelegateIfPossible];
}

- (BOOL)formatLoaded {
    return self.adLoadingState & AdLoadingStateFormatReady;
}

- (BOOL)adLoaded {
    // for both types, communication should be up and webView should have loaded the content
    BOOL baseComponentsLoaded = self.adLoadingState & AdLoadingStateConnect && self.adLoadingState & AdLoadingStateWebviewReady;
    if (self.ad.loadedSource == LoadedSourceSDK) {
        return baseComponentsLoaded && self.webViewLoaded;
    } else {
        // for the format type, we should have received the callback from Mraid ogyOnAdLoaded too
        return baseComponentsLoaded && self.adLoadingState & AdLoadingStateFormatReady;
    }
}

- (void)triggerStateDelegateIfPossible {
    if (self.adLoadingState & AdLoadingStateTimeOut) {
        return;
    }
    if (self.ad.loadedSource == LoadedSourceFormat &&
        self.adLoadingState & AdLoadingStateConnect &&
        self.adLoadingState & AdLoadingStateWebviewReady &&
        self.adLoadingState & AdLoadingStateFormatReady) {
        [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdPrecachedOnFormat
                                 adConfiguration:self.ad.adConfiguration];

        [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdPrecached
                                 adConfiguration:self.ad.adConfiguration];
    }
    if ([self adLoaded]) {
        [self.webViewDelegate webViewReady:self.ad.localIdentifier];  // This is only for ad webview (request ad from server)
        [self.stateDelegate adIsFullyLoaded];
        [self invalidateTimer];
    }
}

- (void)invalidateTimer {
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

- (void)handleFormatTimer:(NSNumber *)timeout {
    __weak OGAAdLoadStateManager *weakSelf = self;
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout.intValue
                                                        repeats:NO
                                                          block:^(NSTimer *_Nonnull timer) {
                                                              [weakSelf triggerFormatLoadedTimeoutError:timeout];
                                                          }];
    [[NSRunLoop mainRunLoop] addTimer:self.timeoutTimer forMode:NSDefaultRunLoopMode];
}

- (void)triggerFormatLoadedTimeoutError:(NSNumber *)timeout {
    self.adLoadingState |= AdLoadingStateTimeOut;
    [self.commandDelegate loadTimedOut];
    NSArray *args = @[ self.accomplishedSteps,
                       @(@([[NSDate date] timeIntervalSinceDate:self.precachingStartDate]).intValue),
                       @(timeout.intValue) ];
    [self.monitoringDispatcher sendLoadErrorEventPrecacheFail:OGAMonitoringPrecacheErrorTimeOut
                                              adConfiguration:self.ad.adConfiguration
                                                    arguments:args];
    // JTO uncomment if needed
    //    [self.ad.adConfiguration.delegateDispatcher failedWithError:[OguryAdError adPrecachingTimeout]];
}

- (BOOL)webViewLoaded:(NSString *)webViewId {
    [self.accomplishedSteps addObject:OGAAccomplishedHtmlReady];

    if (([webViewId isEqualToString:OGANameMainWebView] && self.mraidEnvironmentIsUp == NO) || self.adLoadingState & AdLoadingStateTimeOut) {
        [self.webViewDelegate webViewNotReady:self.ad.localIdentifier];
        return NO;
    }

    self.webViewLoaded = YES;
    if (self.ad.loadedSource == LoadedSourceSDK) {
        if (self.adLoadingState & AdLoadingStateConnect) {
            [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdPrecached adConfiguration:self.ad.adConfiguration];
        }
        [self webViewIsReadyForSDKBehavior:webViewId];
    }
    return YES;
}

- (void)webViewIsReadyForSDKBehavior:(NSString *)webViewId {
    NSInteger delay = self.ad.delayForSendingLoaded != 0 ? self.ad.delayForSendingLoaded : defaultDelayForSendingLoaded;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self triggerStateDelegateIfPossible];
    });
}

@end
