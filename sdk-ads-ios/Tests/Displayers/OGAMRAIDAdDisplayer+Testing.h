//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAMRAIDAdDisplayer.h"
#import "OGAMRAIDWebView.h"
#import "OGAMraidUtils.h"
#import "OGAUserDefaultsStore.h"
#import "OGAAdSyncManager.h"
#import "OGAAdLandingPagePrefetcher.h"
#import "OGAMetricsService.h"
#import "OGAWebViewCleanupManager.h"
#import "OGAAdImpressionManager.h"
#import "OGAProfigManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAMRAIDAdDisplayer (Tests) <OGAMRAIDWebViewDelegate>

#pragma mark - Properties

@property(nonatomic, strong, readwrite) UIView *view;
@property(nonatomic, strong) OGAMRAIDWebView *containerWebView;
@property(nonatomic, assign) OGAAdMraidDisplayerState mraidDisplayerState;
@property(nonatomic, strong) NSMutableArray<OGAMraidAdWebView *> *webviews;
@property(nonatomic, strong) UIButton *closeButton;
@property(nonatomic, strong) NSTimer *closeButtonTimer;

#pragma mark - Methods

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
                       log:(OGALog *)log;

- (void)cleanUp;

- (OGAMraidAdWebView *)mraidViewForId:(NSString *)webViewId;

- (void)createWebView:(OGAMraidCommand *)command;

- (void)setupWebView:(OGAMraidAdWebView *)webView withCommand:(OGAMraidCreateWebViewCommand *_Nullable)command;

- (CGSize)sizeForWebViewWithConfiguration:(OGAAdConfiguration *)configuration
                                  command:(OGAMraidCreateWebViewCommand *)command
                                     view:(UIView *)view
                         containerWebView:(OGAMRAIDWebView *)containerWebView;

- (void)expand;

- (void)forceClose:(OGAMraidCommand *)command;

- (void)pressedSDKCloseButton;

- (void)closeFullAd:(OGAMraidCommand *)command;

- (void)unloadAd:(OGAMraidCommand *)command origin:(UnloadOrigin)origin;

- (nonnull OGAMraidAdWebView *)closeWebView:(nonnull OGAMraidCommand *)command;

- (void)executeBackActionForWebViewId:(NSString *)webViewId;

- (void)executeForwardActionForWebViewId:(NSString *)webViewId;

- (void)resizeProps:(nonnull OGAMraidCommand *)command;

- (void)updateWebView:(nonnull OGAMraidCommand *)command;

- (void)handleResizeCommand:(OGAMraidCommand *)command;

- (void)bunaZiua;

- (void)formatDidLoadAd;

- (void)setOrientationProperties:(OGAMraidCommand *)command;

- (void)loadTimedOut;

@end

NS_ASSUME_NONNULL_END
