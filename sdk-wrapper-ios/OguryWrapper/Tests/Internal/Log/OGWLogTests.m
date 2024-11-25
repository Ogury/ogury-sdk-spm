//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <OguryCore/OguryLog.h>
#import <OguryCore/OguryOSLogger.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGWLog.h"

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
    OCMVerify([self.oguryLog logMessage:[[OguryLogMessage alloc] initWithLevel:OguryLogLevelError
                                                                       logType:OguryLogTypeInternal
                                                                           sdk:OguryLogSDKWrapper
                                                                       message:@"my message"]]);
}

@end
