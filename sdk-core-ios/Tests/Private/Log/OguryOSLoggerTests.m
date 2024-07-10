//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OguryLog.h"
#import "OguryOSLogger.h"
#import "OguryLogFormatter.h"
#import "OguryLogMessage.h"
#import "OCMock.h"
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
    self.oguryOSLogger = [OguryOSLoggerWrapper new];

}

- (void)testDefaultLogLevel {
    OguryLogLevel defaultLevel = OguryLogLevelError;
    OguryOSLogger *logger = [[OguryOSLogger alloc] initWithSubSystem:@"" category:@""];
    
    XCTAssertEqual(logger.logLevel, defaultLevel);
}

/*
    OguryLogLevelOff tests
    All logs should be ignored
*/

- (void)testOguryLogLevelOffWithErrorMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelOff;

    id mock = OCMPartialMock(self.oguryOSLogger);
    /*
        using ignoringNonObjectArgs to ignore forType argument, so this reject logToOsLevel in all cases
            OS_LOG_TYPE_ERROR here is working like [OCMArg any]
     */
    OCMReject([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]).ignoringNonObjectArgs();

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelError message:@"Lorem ipsum dolor sit amet"]];
}

- (void)testOguryLogLevelOffWithWarningMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelOff;

    id mock = OCMPartialMock(self.oguryOSLogger);
    OCMReject([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]).ignoringNonObjectArgs();

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelWarning message:@"Lorem ipsum dolor sit amet"]];
}

- (void)testOguryLogLevelOffWithInfoMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelOff;

    id mock = OCMPartialMock(self.oguryOSLogger);
    OCMReject([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]).ignoringNonObjectArgs();

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelInfo message:@"Lorem ipsum dolor sit amet"]];
}

- (void)testOguryLogLevelOffWithDebugMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelOff;

    id mock = OCMPartialMock(self.oguryOSLogger);
    OCMReject([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]).ignoringNonObjectArgs();

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelDebug message:@"Lorem ipsum dolor sit amet"]];
}

/*
    OguryLogLevelError tests
    only errors should be logged
*/

- (void)testOguryLogLevelErrorWithErrorMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelError;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelError message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]);
}

- (void)testOguryLogLevelErrorWithWarningMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelError;

    id mock = OCMPartialMock(self.oguryOSLogger);
    OCMReject([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]).ignoringNonObjectArgs();

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelWarning message:@"Lorem ipsum dolor sit amet"]];
}

- (void)testOguryLogLevelErrorWithInfoMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelError;

    id mock = OCMPartialMock(self.oguryOSLogger);
    OCMReject([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]).ignoringNonObjectArgs();

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelInfo message:@"Lorem ipsum dolor sit amet"]];
}

- (void)testOguryLogLevelErrorWithDebugMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelError;

    id mock = OCMPartialMock(self.oguryOSLogger);
    OCMReject([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]).ignoringNonObjectArgs();

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelDebug message:@"Lorem ipsum dolor sit amet"]];
}

/*
    OguryLogLevelWarning tests
    errors and warnings should be logged
*/

- (void)testOguryLogLevelWarningWithErrorMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelWarning;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelError message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]);
}

- (void)testOguryLogLevelWarningWithWarningMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelWarning;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelWarning message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_INFO]);
}

- (void)testOguryLogLevelWarningWithInfoMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelWarning;

    id mock = OCMPartialMock(self.oguryOSLogger);
    OCMReject([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]).ignoringNonObjectArgs();

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelInfo message:@"Lorem ipsum dolor sit amet"]];
}

- (void)testOguryLogLevelWarningWithDebugMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelWarning;

    id mock = OCMPartialMock(self.oguryOSLogger);
    OCMReject([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]).ignoringNonObjectArgs();

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelDebug message:@"Lorem ipsum dolor sit amet"]];
}

/*
    OguryLogLevelInfo tests
    errors, warnings and infos should be logged
*/

- (void)testOguryLogLevelInfoWithErrorMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelInfo;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelError message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]);
}

- (void)testOguryLogLevelInfoWithWarningMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelInfo;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelWarning message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_INFO]);
}

- (void)testOguryLogLevelInfoWithInfoMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelInfo;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelInfo message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_INFO]);
}

- (void)testOguryLogLevelInfoWithDebugMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelInfo;

    id mock = OCMPartialMock(self.oguryOSLogger);
    OCMReject([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]).ignoringNonObjectArgs();

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelDebug message:@"Lorem ipsum dolor sit amet"]];
}

/*
    OguryLogLevelDebug tests
    errors, warnings, infos, and debugs should be logged
*/

- (void)testOguryLogLevelDebugWithErrorMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelDebug;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelError message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]);
}

- (void)testOguryLogLevelDebugWithWarningMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelDebug;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelWarning message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType: OS_LOG_TYPE_INFO]);
}

- (void)testOguryLogLevelDebugWithInfoMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelDebug;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelInfo message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType: OS_LOG_TYPE_INFO]);
}

- (void)testOguryLogLevelDebugWithDebugMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelDebug;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelDebug message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_DEBUG]);
}

/*
    OguryLogLevelAll tests
    all logs should be logged
*/

- (void)testOguryLogLevelAllWithErrorMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelAll;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelError message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_ERROR]);
}

- (void)testOguryLogLevelAllWithWarningMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelAll;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelWarning message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_INFO]);
}

- (void)testOguryLogLevelAllWithInfoMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelAll;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelInfo message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_INFO]);
}

- (void)testOguryLogLevelAllWithDebugMessage {
    self.oguryOSLogger.logLevel = OguryLogLevelAll;
    id mock = OCMPartialMock(self.oguryOSLogger);

    [mock logMessage:[[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelDebug message:@"Lorem ipsum dolor sit amet"]];

    OCMVerify([mock logToOSLevel:[OCMArg any] forType:OS_LOG_TYPE_DEBUG]);
}

@end

