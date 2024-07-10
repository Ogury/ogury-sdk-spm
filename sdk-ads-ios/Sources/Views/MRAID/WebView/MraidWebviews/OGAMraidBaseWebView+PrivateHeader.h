//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGAMraidBaseWebView.h"
#import "OGAMraidEnviromentBuilder.h"
#import "OGALog.h"
#import "OGAMRAIDUrlChangeHandler.h"
#import "OGAMetricsService.h"
#import "OGAAdHistoryEvent.h"
#import "OGAOMIDService.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAMraidBaseWebView (PrivateHeader)

@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong) OGAOMIDService *omidService;

@property(nonatomic, strong) OGAMRAIDUrlChangeHandler *urlChangeHandler;
@property(nonatomic, strong) OGAMraidBaseWebView *fakeWebView;
@property(nonatomic, strong) OGALog *log;

@property(nonatomic, strong) NSOperationQueue *mraidInitializationQueue;
@property(nonatomic, assign) BOOL isPerformingMRAIDInitialization;
@property(nonatomic, assign) BOOL hasFinishedMRAIDInitialization;

#pragma mark - Private Methods

- (void)startMRAIDProcessForContent:(NSString *)content;

- (void)setupMKWebView;

- (void)setupConstraintsForWebView;

- (void)sendNavigationEvent:(NSString *)event webViewIdentifier:(NSString *)webViewIdentifier wkWebView:(WKWebView *)wkWebView;

- (void)sendNavigationEvent:(NSString *)event webViewIdentifier:(NSString *)webViewIdentifier wkWebView:(WKWebView *)wkWebView pageTitle:(NSString *_Nullable)pageTitle;

- (void)startOMIDSessionOnShow;

- (void)startOMIDSession;

- (void)mraidAction:(OGAMraidCommand *)action;

- (void)mraidUnknownCommand:(NSString *)url;

- (void)webViewReady;

@end

NS_ASSUME_NONNULL_END
