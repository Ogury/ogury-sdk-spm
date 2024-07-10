//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAMraidBaseWebView.h"
#import <OCMock/OCMock.h>
#import <WebKit/WebKit.h>
#import "OGAMetricsService.h"
#import "OGAOMIDService.h"
#import "OGALog.h"
#import "OGAMonitoringDispatcher.h"

@interface OGAMraidBaseWebViewTests : XCTestCase
@property(nonatomic, retain) OGAMraidBaseWebView *webView;
@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong) OGAOMIDService *omidService;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAAd *ad;
@end

@interface OGAMraidBaseWebView ()
- (instancetype)initWithAd:(OGAAd *)ad
            metricsService:(OGAMetricsService *)metricsService
               omidService:(OGAOMIDService *)omidService
      monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                       log:(OGALog *)log;

- (void)sendPrecachingFailEvent;
@end

@implementation OGAMraidBaseWebViewTests

- (void)setUp {
    self.metricsService = OCMClassMock([OGAMetricsService class]);
    self.omidService = OCMClassMock([OGAOMIDService class]);
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    self.log = OCMClassMock([OGALog class]);
    self.ad = OCMClassMock([OGAAd class]);
    self.webView = OCMPartialMock([[OGAMraidBaseWebView alloc] initWithAd:self.ad
                                                           metricsService:self.metricsService
                                                              omidService:self.omidService
                                                     monitoringDispatcher:self.monitoringDispatcher
                                                                      log:self.log]);
}

- (void)testWhenWebkitNavigationErrorIsCalledThenPrecachingMethodIsCalled {
    [(id<WKNavigationDelegate>)self.webView webView:self.webView.wkWebView didFailNavigation:[OCMArg any] withError:[OCMArg any]];
    OCMVerify([self.webView sendPrecachingFailEvent]);
}

- (void)testWhenWebkitProvisionnalNavigationErrorIsCalledThenPrecachingMethodIsCalled {
    [(id<WKNavigationDelegate>)self.webView webView:self.webView.wkWebView didFailProvisionalNavigation:[OCMArg any] withError:[OCMArg any]];
    OCMVerify([self.webView sendPrecachingFailEvent]);
}

- (void)testWhenSendPrecachingMethodIsCalledFromMainWebviewThenEventIsDispatched {
    OCMStub(self.webView.webViewId).andReturn(OGANameMainWebView);
    [self.webView sendPrecachingFailEvent];
    OCMVerify([self.monitoringDispatcher sendLoadErrorEventPrecacheFail:OGAMonitoringPrecacheErrorHtmlLoadFailed adConfiguration:[OCMArg any]]);
}

- (void)testWhenSendPrecachingMethodIsCalledFromNotMainWebviewThenEventIsNotDispatched {
    OCMStub(self.webView.webViewId).andReturn(@"OtherId");
    [self.webView sendPrecachingFailEvent];
    OCMReject([self.monitoringDispatcher sendLoadErrorEventPrecacheFail:OGAMonitoringPrecacheErrorHtmlLoadFailed adConfiguration:[OCMArg any]]);
}

@end
