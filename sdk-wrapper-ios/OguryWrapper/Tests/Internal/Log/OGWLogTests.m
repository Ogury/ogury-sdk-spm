//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <OguryCore/OguryLog.h>
#import <OguryCore/OguryOSLogger.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGWLog.h"
#import "OguryLog+Wrapper.h"

@interface OGWLog (OGWLogTest)

@property(nonatomic, strong) OguryLog *oguryLog;

@property(nonatomic, copy, nullable) void (^testCompletionBlock)(NSString *, OguryLogLevel);

- (instancetype)init;

@end

@interface OGWLogTests : XCTestCase

@property(nonatomic, strong) NSError *expectedError;
@property(nonatomic, strong) NSString *assetKey;
@property(nonatomic, strong) OGWLog *log;
@property(nonatomic, strong) OguryLog *oguryLog;

@end

@implementation OGWLogTests

- (void)setUp {
    self.expectedError = [NSError errorWithDomain:@"domain.test" code:404 userInfo:nil];
    self.assetKey = @"OGY-XXXXXX";
    self.log = OCMPartialMock([[OGWLog alloc] init]);
    self.oguryLog = OCMClassMock([OguryLog class]);
    OCMStub(self.log.oguryLog).andReturn(self.oguryLog);
}

- (void)testSetLogLevel {
   [self.log setLogLevel:OguryLogLevelAll];
   OCMVerify([self.oguryLog setLogLevel:OguryLogLevelAll]);
}

- (void)testLog {
   [self.log log:OguryLogLevelError message:@"my message"];
   OCMVerify([self.oguryLog logMessage:@"my message" level:OguryLogLevelError]);
}

- (void)testLogFormat {
   // this hidden completion block serves only because variadic parameters Mocking with NSInvocation crashes on M1 chips
   // it is only used in [logFormat:format:] method without mocking it
   OGWLog *log = [[OGWLog alloc] init];
   XCTestExpectation *expectation = [self expectationWithDescription:@"waiter"];
   [log setTestCompletionBlock:^(NSString *message, OguryLogLevel level) {
     if ([message isEqualToString:@"testtest1"]) {
        [expectation fulfill];
     }
   }];
   [log logFormat:OguryLogLevelError format:@"test%@", @"test1"];
   [self waitForExpectations:@[ expectation ] timeout:1];
}

- (void)testErrorFormat {
   OGWLog *log = [[OGWLog alloc] init];
   XCTestExpectation *expectation = [self expectationWithDescription:@"waiter"];
   [log setTestCompletionBlock:^(NSString *message, OguryLogLevel level) {
     if ([message isEqualToString:@"error expected"]) {
        [expectation fulfill];
     }
   }];
   [log logErrorFormat:self.expectedError format:@"error %@", @"expected"];
   [self waitForExpectations:@[ expectation ] timeout:1];
}
/*
 
 Deactivated as CI, does not allow, should investigate after release 4.2.0
- (void)testassetKeyLog {
   [self.log logAssetKey:OguryLogLevelDebug assetKey:self.assetKey message:@"message"];
   OCMVerify([self.oguryLog ogwlogAssetKeyMessage:OguryLogLevelDebug assetKey:self.assetKey message:@"message"]);
}
*/

- (void)testassetKeyLogFormat {
   id mock = OCMPartialMock([[OGWLog alloc] init]);

   [[mock expect] logAssetKey:OguryLogLevelError assetKey:self.assetKey message:@"test"];

   [mock logAssetKeyFormat:OguryLogLevelError assetKey:self.assetKey format:@"test"];

   [mock verify];
}

- (void)testassetKeyError {
   id mock = OCMPartialMock([[OGWLog alloc] init]);

   [[mock expect] logAssetKey:OguryLogLevelError
                     assetKey:self.assetKey
                      message:[OCMArg checkWithBlock:^BOOL(NSString *obj) {
                        return [obj hasPrefix:@"expected error"];
                      }]];

   [mock logAssetKeyError:self.expectedError assetKey:self.assetKey message:@"expected error"];

   [mock verify];
}

- (void)testassetKeyErrorFormat {
   id mock = OCMPartialMock([[OGWLog alloc] init]);

   [[mock expect] logAssetKey:OguryLogLevelError
                     assetKey:self.assetKey
                      message:[OCMArg checkWithBlock:^BOOL(NSString *obj) {
                        return [obj hasPrefix:@"expected error"];
                      }]];

   [mock logAssetKeyErrorFormat:self.expectedError assetKey:self.assetKey format:@"expected error"];

   [mock verify];
}

@end
