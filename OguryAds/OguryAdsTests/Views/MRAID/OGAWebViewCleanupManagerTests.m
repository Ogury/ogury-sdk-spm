//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAWebViewCleanupManager.h"
#import <OCMock/OCMock.h>
#import "OGALog.h"

@interface OGAWebViewCleanupManager (Test)

@property(nonatomic, strong) NSMutableDictionary *keepAliveDict;

- (instancetype)initWithKeepAliveTime:(NSTimeInterval)keepAliveTime log:(OGALog *)log;

@end

@interface OGAWebViewCleanupManagerTests : XCTestCase

@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAWebViewCleanupManagerTests

- (void)testKeepLiveObject {
    OGAMraidAdWebView *webView = OCMClassMock([OGAMraidAdWebView class]);

    OGAWebViewCleanupManager *webViewCleanupManager = [[OGAWebViewCleanupManager alloc] initWithKeepAliveTime:0.1 log:self.log];

    [webViewCleanupManager cleanUpObject:webView];
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait to remove webview"];

    NSTimeInterval waitingTime = 0.1;
    XCTAssertEqual([webViewCleanupManager.keepAliveDict count], 1);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitingTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectations:@[ expectation ] timeout:waitingTime + 3];
    XCTAssertEqual([webViewCleanupManager.keepAliveDict count], 0);
}

- (void)testWhenCleanUpObject_ThenRemoveScriptIsCalled {
    OGAWebViewCleanupManager *webViewCleanupManager = [[OGAWebViewCleanupManager alloc] initWithKeepAliveTime:0.1 log:self.log];
    OGAMraidAdWebView *webView = OCMPartialMock([OGAMraidAdWebView new]);
    [webViewCleanupManager cleanUpObject:webView];
    OCMVerify([webView removeScriptMessageHandler]);
}

@end
