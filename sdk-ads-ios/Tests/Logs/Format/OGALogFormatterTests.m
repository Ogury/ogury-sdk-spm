//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGALogFormatter.h"
#import "OGAAdLogMessage.h"

@interface OGALogFormatter ()

- (NSString *)logLevelToString:(OguryLogLevel)logLevel;
- (NSString *)getAssetKey;

@end

@interface OGALogFormatterTests : XCTestCase

@end

@implementation OGALogFormatterTests

NSString *const OGALogFormatterTestsLogMessage = @"testMessage";
NSString *const OGALogFormatterTestsAssetKey = @"OGALogFormatterTestsAssetKey";
NSString *const OGALogFormatterTestsErrorLogLevelString = @"error";
NSString *const OGALogFormatterTestsformattedLogMessage = @"myFormattedMessage";

- (void)testLogLevelToString {
    OGALogFormatter *formatter = [[OGALogFormatter alloc] init];

    XCTAssertTrue([[formatter logLevelToString:OguryLogLevelError] isEqualToString:@"error"]);
    XCTAssertTrue([[formatter logLevelToString:OguryLogLevelAll] isEqualToString:@"all"]);
    XCTAssertTrue([[formatter logLevelToString:OguryLogLevelWarning] isEqualToString:@"warning"]);
    XCTAssertTrue([[formatter logLevelToString:OguryLogLevelInfo] isEqualToString:@"info"]);
    XCTAssertTrue([[formatter logLevelToString:OguryLogLevelOff] isEqualToString:@"off"]);
    XCTAssertTrue([[formatter logLevelToString:OguryLogLevelDebug] isEqualToString:@"debug"]);
}

- (void)testFormatPlainMessage {
    OguryAbstractLogMessage *logMessage = [[OguryAbstractLogMessage alloc] initWithLevel:OguryLogLevelError message:OGALogFormatterTestsLogMessage];

    OGALogFormatter *formatterMock = OCMPartialMock([[OGALogFormatter alloc] init]);
    OCMStub([formatterMock getAssetKey]).andReturn(OGALogFormatterTestsAssetKey);

    NSString *expected = [NSString stringWithFormat:@"[%@][%@][Ads]%@", OGALogFormatterTestsErrorLogLevelString, OGALogFormatterTestsAssetKey, OGALogFormatterTestsLogMessage];

    XCTAssertTrue([[formatterMock formatLogMessage:logMessage] isEqualToString:expected]);
    OCMVerify([formatterMock logLevelToString:OguryLogLevelError]);
}

- (void)testFormatFormattableMessage {
    id messageMock = OCMClassMock([OGAAdLogMessage self]);
    OCMStub([messageMock formattedString]).andReturn(OGALogFormatterTestsformattedLogMessage);

    OGALogFormatter *formatterMock = OCMPartialMock([[OGALogFormatter alloc] init]);
    OCMStub([formatterMock getAssetKey]).andReturn(OGALogFormatterTestsAssetKey);

    NSString *expected = [NSString stringWithFormat:@"[%@][%@][Ads]%@", OGALogFormatterTestsErrorLogLevelString, OGALogFormatterTestsAssetKey, [messageMock formattedString]];

    XCTAssertTrue([[formatterMock formatLogMessage:messageMock] isEqualToString:expected]);
    OCMVerify([formatterMock logLevelToString:OguryLogLevelError]);
}

@end
