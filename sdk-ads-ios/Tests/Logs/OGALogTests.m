//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGALog.h"
#import <OguryCore/OguryLog.h>
#import <OguryCore/OguryOSLogger.h>
#import "OGAAdConfiguration.h"
#import "OguryLog+Ads.h"

@import OguryAds.Private;

@interface OGALog ()

@property(nonatomic, strong) OguryLog *oguryLog;

- (NSString *)formatError:(NSError *)error;
@property(nonatomic, copy, nullable) void (^testCompletionBlock)(NSString *, OguryLogLevel);

@end

@interface OGALogTests : XCTestCase

@property(nonatomic, strong) NSError *expectedError;
@property(nonatomic, strong) OGAAdConfiguration *adConfig;
@property(nonatomic, strong) NSString *webviewId;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OguryLog *oguryLog;
@property(nonatomic, strong) OGADelegateDispatcher *delegateDispatcher;

@end

@implementation OGALogTests

- (void)setUp {
    self.expectedError = [NSError errorWithDomain:@"domain.test" code:404 userInfo:nil];
    self.delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    self.adConfig = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                    adUnitId:@"test"
                                          delegateDispatcher:self.delegateDispatcher
                                      viewControllerProvider:^UIViewController *_Nonnull {
                                          return OCMClassMock([UIViewController class]);
                                          ;
                                      }];
    self.webviewId = @"webviewId";
    self.log = OCMPartialMock([[OGALog alloc] init]);
    self.oguryLog = OCMClassMock([OguryLog class]);
    OCMStub(self.log.oguryLog).andReturn(self.oguryLog);
}

- (void)testInit {
    XCTAssertNotNil(self.log);
}

- (void)testShared {
    XCTAssertNotNil([OGALog shared]);
    XCTAssertNotNil([OGALog shared].oguryLog);
}

- (void)testSetLogLevel {
    [self.log setLogLevel:OguryLogLevelAll];
    OCMVerify([self.log setLogLevel:OguryLogLevelAll]);
}

- (void)testLog {
    [self.log log:OguryLogLevelDebug message:@"Hello"];
    OCMVerify([self.oguryLog logMessage:@"Hello" level:OguryLogLevelDebug]);
}

- (void)testLogFormat {
    // this hidden completion block serves only because variadic parameters Mocking with NSInvocation crashes on M1 chips
    // it is only used in [logFormat:format:] method without mocking it
    OGALog *log = [[OGALog alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"waiter"];
    [log setTestCompletionBlock:^(NSString *message, OguryLogLevel level) {
        if ([message isEqualToString:@"testtest1"]) {
            [expectation fulfill];
        }
    }];
    [log logFormat:OguryLogLevelError format:@"test%@", @"test1"];
    [self waitForExpectations:@[ expectation ] timeout:1];
}

- (void)testError {
    OCMStub([self.log formatError:[OCMArg any]]).andReturn(@"Formated error");
    [self.log logError:self.expectedError message:@"expected error"];
    OCMVerify([self.log log:OguryLogLevelError message:@"expected error - Error: Formated error"]);
}

- (void)testAdLog {
    [self.log logAd:OguryLogLevelError forAdConfiguration:self.adConfig message:@"my message"];
    OCMVerify([self.oguryLog ogaLogAdMessage:OguryLogLevelError adConfiguration:self.adConfig message:@"my message"]);
}

- (void)testMraidLog {
    [self.log logMraid:OguryLogLevelError forAdConfiguration:self.adConfig webViewId:self.webviewId message:@"my message"];
    OCMVerify([self.oguryLog ogaLogMraidMessage:OguryLogLevelError adConfiguration:self.adConfig webViewId:self.webviewId message:@"my message"]);
}

@end
