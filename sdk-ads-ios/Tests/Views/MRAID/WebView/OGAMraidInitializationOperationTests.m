//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAMraidInitializationOperation.h"
#import "OCMock.h"

@interface OGAMraidInitializationOperation (Test)

@property(nonatomic, assign) BOOL isRunning;
@property(nonatomic, assign) BOOL hasFinished;

@end

@interface OGAMraidInitializationOperationTests : XCTestCase

@property(nonatomic, strong) OGAMraidInitializationOperation *initializationOperation;
@property(nonatomic, strong) OGAMraidBaseView *baseView;
@property(nonatomic, strong) WKWebView *wkWebView;
@property(nonatomic, copy) NSString *initializationScript;

@end

@implementation OGAMraidInitializationOperationTests

- (void)setUp {
    self.baseView = OCMClassMock(OGAMraidBaseView.class);
    self.initializationScript = OCMClassMock(NSString.class);
    self.wkWebView = OCMClassMock(WKWebView.class);
    OCMStub(self.baseView.wkWebView).andReturn(self.wkWebView);
    self.initializationOperation = OCMPartialMock([[OGAMraidInitializationOperation alloc] initWithBaseView:self.baseView initializationScript:self.initializationScript]);
}

- (void)testMain {
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait to remove webview"];

    OCMStub([self.wkWebView evaluateJavaScript:self.initializationScript completionHandler:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        [expectation fulfill];
    });

    [self.initializationOperation main];

    [self waitForExpectations:@[ expectation ] timeout:1];
}

- (void)testIsExecutingTrue {
    [self.initializationOperation setIsRunning:YES];
    XCTAssertTrue([self.initializationOperation isExecuting]);
}

- (void)testIsExecutingFalse {
    [self.initializationOperation setIsRunning:NO];
    XCTAssertFalse([self.initializationOperation isExecuting]);
}

- (void)testIsFinishedTrue {
    [self.initializationOperation setHasFinished:YES];
    XCTAssertTrue([self.initializationOperation isFinished]);
}

- (void)tesIsFinishedFalse {
    [self.initializationOperation setHasFinished:NO];
    XCTAssertFalse([self.initializationOperation isFinished]);
}

@end
