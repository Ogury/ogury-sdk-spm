//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAMraidLoadHTMLOperation.h"
#import "OCMock.h"

@interface OGAMraidLoadHTMLOperation (Test)

@end

@interface OGAMraidLoadHTMLOperationTests : XCTestCase

@property(nonatomic, strong) OGAMraidLoadHTMLOperation *loadHTMLOperation;
@property(nonatomic, strong) OGAMraidBaseView *baseView;
@property(nonatomic, strong) WKWebView *wkWebView;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, copy) NSURL *baseURL;
@property(nonatomic, copy) NSString *environmentScript;
@property(nonatomic, copy) NSString *executionScript;

@end

@implementation OGAMraidLoadHTMLOperationTests

- (void)setUp {
    self.baseView = OCMClassMock(OGAMraidBaseView.class);
    self.content = OCMClassMock(NSString.class);
    self.baseURL = OCMClassMock(NSURL.class);
    self.environmentScript = OCMClassMock(NSString.class);
    self.executionScript = OCMClassMock(NSString.class);
    self.wkWebView = OCMClassMock(WKWebView.class);
    OCMStub(self.baseView.wkWebView).andReturn(self.wkWebView);

    self.loadHTMLOperation = OCMPartialMock([[OGAMraidLoadHTMLOperation alloc] initWithBaseView:self.baseView content:self.content baseURL:self.baseURL environmentScript:self.environmentScript executionScript:self.executionScript]);
}

- (void)testMain {
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait to remove webview"];

    OCMStub(self.baseView.isCommunicatingWithMraid).andReturn(YES);
    OCMStub([self.wkWebView loadHTMLString:OCMOCK_ANY baseURL:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        [expectation fulfill];
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.loadHTMLOperation main];
    });

    [self waitForExpectations:@[ expectation ] timeout:10];
}

@end
