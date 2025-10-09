//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <WebKit/WebKit.h>
#import <XCTest/XCTest.h>
#import "OGAWebViewUserAgentService.h"
#import "OGAWebViewUserAgentServiceDelegate.h"

@interface OGAWebViewUserAgentServiceTests : XCTestCase

@property(nonatomic, retain) OGAWebViewUserAgentService *webViewUserAgentService;
@property(nonatomic, retain) id<OGAWebViewUserAgentServiceDelegate> delegate;

@end

@interface OGAWebViewUserAgentService ()

@property(nonatomic, copy, readwrite, nullable) NSString *webViewUserAgent;
@property(nonatomic, strong) WKWebView *webViewForUserAgent;
@property(nonatomic) NSInteger webviewUserAgentRetry;
@property(nonatomic) BOOL delegateFired;

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;

@end

@implementation OGAWebViewUserAgentServiceTests

- (void)setUp {
    self.delegate = OCMProtocolMock(@protocol(OGAWebViewUserAgentServiceDelegate));
    self.webViewUserAgentService = OCMPartialMock([[OGAWebViewUserAgentService alloc] init]);
    self.webViewUserAgentService.delegate = self.delegate;
}

- (void)testShared {
    XCTAssertNotNil([OGAWebViewUserAgentService shared]);
}

- (void)testInit {
    XCTAssertEqual(self.webViewUserAgentService.webviewUserAgentRetry, 0);
    XCTAssertEqual(self.webViewUserAgentService.delegateFired, NO);
    XCTAssertEqualObjects(self.webViewUserAgentService.webViewForUserAgent, nil);
}

- (void)testSyncWebViewUserAgent {
    [self.webViewUserAgentService syncWebViewUserAgent];
    [OCMStub([self.webViewUserAgentService webView:[OCMArg any] didFinishNavigation:[OCMArg any]]) andDo:^(NSInvocation *invocation) {
        XCTAssertNotNil(self.webViewUserAgentService.webViewForUserAgent);
        XCTAssertEqual(self.webViewUserAgentService.delegate, self.delegate);
        OCMVerify([self.webViewUserAgentService.webViewForUserAgent loadRequest:[OCMArg any]]);
    }];
}

- (void)testWebViewDidFinishNavigationFirstTimeSuccess {
    WKWebView *webview = OCMClassMock([WKWebView class]);
    WKNavigation *navigation = OCMClassMock([WKNavigation class]);
    [self.webViewUserAgentService webView:webview didFinishNavigation:navigation];
    [OCMStub([webview evaluateJavaScript:[OCMArg any] completionHandler:[OCMArg any]]) andDo:^(NSInvocation *invocation) {
        void (^completionHandler)(id _Nullable result, NSError *_Nullable error);
        [invocation getArgument:&completionHandler atIndex:3];
        if (completionHandler) {
            completionHandler(@"USER_AGENT", nil);
        }
        XCTAssertEqualObjects(self.webViewUserAgentService.webViewUserAgent, @"USER_AGENT");
        XCTAssertEqual(self.webViewUserAgentService.delegateFired, YES);
        OCMVerify([self.webViewUserAgentService.delegate receivedWebViewUserAgent:@"USER_AGENT"]);
    }];
}

- (void)testWebViewDidFinishNavigationFirstTimeFail {
    WKWebView *webview = OCMClassMock([WKWebView class]);
    WKNavigation *navigation = OCMClassMock([WKNavigation class]);
    OCMStub([self.webViewUserAgentService syncWebViewUserAgent]);
    [self.webViewUserAgentService webView:webview didFinishNavigation:navigation];
    [OCMStub([webview evaluateJavaScript:[OCMArg any] completionHandler:[OCMArg any]]) andDo:^(NSInvocation *invocation) {
        void (^completionHandler)(id _Nullable result, NSError *_Nullable error);
        [invocation getArgument:&completionHandler atIndex:3];
        NSError *error = [[NSError alloc] init];
        if (completionHandler) {
            completionHandler(@"USER_AGENT", error);
        }
        XCTAssertNil(self.webViewUserAgentService.webViewUserAgent);
        XCTAssertEqual(self.webViewUserAgentService.delegateFired, NO);
        XCTAssertEqual(self.webViewUserAgentService.webviewUserAgentRetry, 1);
        OCMVerify([self.webViewUserAgentService syncWebViewUserAgent]);
    }];
}

- (void)testWebViewDidFinishNavigationFirstAllTimeFail {
    WKWebView *webview = OCMClassMock([WKWebView class]);
    WKNavigation *navigation = OCMClassMock([WKNavigation class]);
    self.webViewUserAgentService.webviewUserAgentRetry = 10;
    [self.webViewUserAgentService webView:webview didFinishNavigation:navigation];
    [OCMStub([webview evaluateJavaScript:[OCMArg any] completionHandler:[OCMArg any]]) andDo:^(NSInvocation *invocation) {
        void (^completionHandler)(id _Nullable result, NSError *_Nullable error);
        [invocation getArgument:&completionHandler atIndex:3];
        NSError *error = [[NSError alloc] init];
        if (completionHandler) {
            completionHandler(@"USER_AGENT", error);
        }
        XCTAssertNil(self.webViewUserAgentService.webViewUserAgent);
        XCTAssertEqual(self.webViewUserAgentService.delegateFired, YES);
        OCMVerify([self.webViewUserAgentService.delegate maxWebViewUserAgentRetryReached]);
    }];
}

- (void)testWhenServiceIsResetedAfterReceivingUserAgentThenNextCallWillTriggerDelegate {
    self.webViewUserAgentService.webViewUserAgent = @"received";
    self.webViewUserAgentService.delegateFired = YES;
    [self.webViewUserAgentService reset];
    [self.webViewUserAgentService syncWebViewUserAgent];
    OCMReject([self.webViewUserAgentService webView:[OCMArg any] didFinishNavigation:[OCMArg any]]);
    OCMVerify([self.delegate receivedWebViewUserAgent:@"received"]);
    XCTAssertTrue(self.webViewUserAgentService.delegateFired);
}

#warning Temporarly deactivated to avoid jenkins random build failure
- (void)testWhenServiceIsResetedBeforeReceivingUserAgentThenWebviewDelegateIsCalled {
    id<OGAWebViewUserAgentServiceDelegate> delegate = OCMProtocolMock(@protocol(OGAWebViewUserAgentServiceDelegate));
    OGAWebViewUserAgentService *webViewUserAgentService = OCMPartialMock([[OGAWebViewUserAgentService alloc] init]);
    webViewUserAgentService.delegate = delegate;
    webViewUserAgentService.webViewUserAgent = nil;
    webViewUserAgentService.delegateFired = NO;
    [webViewUserAgentService reset];
    XCTestExpectation *ex = [self expectationWithDescription:@"webview didFinishNavigation must be called"];
    [OCMStub([webViewUserAgentService webView:[OCMArg any] didFinishNavigation:[OCMArg any]]) andDo:^(NSInvocation *invocation) {
        [ex fulfill];
    }];
    [webViewUserAgentService syncWebViewUserAgent];
    [self waitForExpectations:@[ ex ] timeout:10];
}

@end
