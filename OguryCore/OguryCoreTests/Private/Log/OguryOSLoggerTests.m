//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <os/log.h>
#import "OguryLog.h"
#import "OguryOSLogger.h"
#import "OguryLogFormatter.h"
#import "OguryLogMessage.h"
#import <OCMock/OCMock.h>
#import "OguryAbstractLogMessage.h"
#import "OguryLogLevel.h"

@interface OguryOSLoggerWrapper: OguryOSLogger

- (void)logToOSLevel:(NSString *)formattedMessage forType:(os_log_type_t)logType;

@end

@implementation OguryOSLoggerWrapper

- (void)logToOSLevel:(NSString *)formattedMessage forType:(os_log_type_t)logType {
}

@end

@interface OguryOSLoggerTests : XCTestCase

#pragma mark - Properties

@property (nonatomic, strong) OguryOSLoggerWrapper *oguryOSLogger;

@end

@implementation OguryOSLoggerTests

- (void)setUp {
    self.oguryOSLogger = [[OguryOSLoggerWrapper alloc] initWithSubSystem:@"Sub" category:@"cat"];
}

- (void)testDefaultLogLevel {
    OguryLogLevel defaultLevel = OguryLogLevelError;
    OguryOSLogger *logger = [[OguryOSLogger alloc] initWithSubSystem:@"" category:@""];
    
    XCTAssertEqual(logger.logLevel, defaultLevel);
}


- (void)testOguryLogLevelErrorWithErrorMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelError;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryLogMessage alloc] initWithLevel:OguryLogLevelError logType:OguryLogTypeInternal sdk:OguryLogSDKCore message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]);
}


- (void)testOguryLogLevelWarningWithErrorMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelWarning;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelError logType:OguryLogTypeInternal sdk:OguryLogSDKCore message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]);
}

- (void)testOguryLogLevelWarningWithWarningMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelWarning;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelWarning logType:OguryLogTypeInternal sdk:OguryLogSDKCore message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_INFO]);
}

- (void)testOguryLogLevelInfoWithErrorMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelInfo;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelError logType:OguryLogTypeInternal sdk:OguryLogSDKCore message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]);
}

- (void)testOguryLogLevelInfoWithWarningMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelInfo;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelWarning logType:OguryLogTypeInternal sdk:OguryLogSDKCore message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_INFO]);
}

- (void)testOguryLogLevelInfoWithInfoMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelInfo;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelInfo logType:OguryLogTypeInternal sdk:OguryLogSDKCore message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_INFO]);
}


- (void)testOguryLogLevelDebugWithErrorMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelDebug;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelError logType:OguryLogTypeInternal sdk:OguryLogSDKCore message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]);
}

- (void)testOguryLogLevelDebugWithWarningMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelDebug;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelWarning logType:OguryLogTypeInternal sdk:OguryLogSDKCore message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType: OS_LOG_TYPE_INFO]);
}

- (void)testOguryLogLevelDebugWithInfoMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelDebug;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelInfo logType:OguryLogTypeInternal sdk:OguryLogSDKCore message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType: OS_LOG_TYPE_INFO]);
}

- (void)testOguryLogLevelDebugWithDebugMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelDebug;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelDebug logType:OguryLogTypeInternal sdk:OguryLogSDKCore message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_DEBUG]);
}

/*
    OguryLogLevelAll tests
    all logs should be logged
*/

- (void)testOguryLogLevelAllWithErrorMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelAll;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelError logType:OguryLogTypeInternal sdk:OguryLogSDKCore message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]);
}

- (void)testOguryLogLevelAllWithWarningMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelAll;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelWarning logType:OguryLogTypeInternal sdk:OguryLogSDKCore message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_INFO]);
}

- (void)testOguryLogLevelAllWithInfoMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelAll;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelInfo logType:OguryLogTypeInternal sdk:OguryLogSDKCore message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_INFO]);
}

- (void)testOguryLogLevelAllWithDebugMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelAll;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelDebug logType:OguryLogTypeInternal sdk:OguryLogSDKCore message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_DEBUG]);
}

@end

