//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OguryLog.h"
#import "OguryOSLogger.h"
#import "OguryLogFormatter.h"
#import "OguryLogMessage.h"
#import <OCMock/OCMock.h>
#import "OguryLogLevel.h"

@interface OguryLog ()

- (instancetype)init:(NSMutableArray *)loggers;

@end

@interface OguryLogTests : XCTestCase

#pragma mark - Properties

@property (nonatomic, strong) OguryLog *oguryLog;
@property (nonatomic, strong) OguryOSLogger *oguryOSLoggerMock;

@end

@implementation OguryLogTests

- (void)setUp {
    self.oguryLog = [[OguryLog alloc] init];
    self.oguryOSLoggerMock = OCMClassMock([OguryOSLogger class]);
    [self.oguryLog clearLoggers];
    [self.oguryLog addLogger:self.oguryOSLoggerMock];
}

- (void)testShouldAddLogger {
    [self.oguryLog clearLoggers];

    [self.oguryLog addLogger:[[OguryOSLogger alloc] initWithSubSystem:@"" category:@""]];

    XCTAssertEqual(self.oguryLog.loggers.count, 1);
}

- (void)testChangeLogLevel {
    [self.oguryLog clearLoggers];
    OguryOSLogger *logger = [[OguryOSLogger alloc] initWithSubSystem:@"" category:@""];
    [self.oguryLog addLogger:logger];
    //default log level
    XCTAssertEqual(logger.logLevel, OguryLogLevelError);

    [self.oguryLog setLogLevel:OguryLogLevelAll];

    XCTAssertEqual(logger.logLevel, OguryLogLevelAll);
}

- (void)testShouldClearLogger {
    [self.oguryLog clearLoggers];

    [self.oguryLog addLogger:[[OguryOSLogger alloc] initWithSubSystem:@"" category:@""]];

    [self.oguryLog clearLoggers];

    XCTAssertEqual(self.oguryLog.loggers.count, 0);
}

- (void)testShouldLogDebug {
    [self.oguryLog logMessage:[OCMArg any]];
    OCMVerify([self.oguryOSLoggerMock logMessage:[OCMArg any]]);
}

- (void)testShouldLogInfo {
    [self.oguryLog logMessage:[OCMArg any]];
    OCMVerify([self.oguryOSLoggerMock logMessage:[OCMArg any]]);
}

- (void)testShouldLogWarning {
    [self.oguryLog logMessage:[OCMArg any]];
    OCMVerify([self.oguryOSLoggerMock logMessage:[OCMArg any]]);
}

- (void)testShouldLogError {
    [self.oguryLog logMessage:[OCMArg any]];
    OCMVerify([self.oguryOSLoggerMock logMessage:[OCMArg any]]);
}

@end

