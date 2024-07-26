//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGCLog.h"
#import "OguryOSLogger.h"
#import "OguryLogLevel.h"

@interface OGCLog ()

@property (nonatomic, strong) OguryLog *oguryLog;

@end

@interface OguryLog (Core)

- (void)ogcLogEventBusMessage:(OguryLogLevel)level message:(NSString *)message eventEntry:(OguryEventEntry *)eventEntry;

- (void)ogcLogRequestMessage:(OguryLogLevel)level message:(NSString *)message request:(NSURLRequest *)request;

@end

@interface OGCLogTests : XCTestCase

@property (nonatomic, strong) OGCLog *log;
@property (nonatomic, strong) OguryLog *oguryLog;

@end

@implementation OGCLogTests

static NSString * const DefaultRawURL = @"https://www.github.com";

- (void)setUp {
    self.log = OCMPartialMock([[OGCLog alloc] init]);
    self.oguryLog = OCMClassMock([OguryLog class]);
    self.log.oguryLog = self.oguryLog;
}

- (void)testInit {
    XCTAssertNotNil(self.log);
}

- (void)testShared {
    XCTAssertNotNil([OGCLog shared]);
    XCTAssertNotNil([OGCLog shared].oguryLog);
}

- (void)testSetLogLevel {

    [self.log setLogLevel:OguryLogLevelAll];

    OCMVerify([self.log setLogLevel:OguryLogLevelAll]);
}

- (void)testLogMessage {

    [self.log logMessage:OguryLogLevelDebug message:@"Hello"];
    OCMVerify([self.log.oguryLog logMessage:@"Hello" level:OguryLogLevelDebug]);
}

- (void)testLogMessageRequest {
    NSURL *testURL = [NSURL URLWithString:DefaultRawURL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:testURL];

    [self.log logRequestMessage:OguryLogLevelDebug message:@"Hello" request:request];

    OCMVerify([self.log.oguryLog ogcLogRequestMessage:OguryLogLevelDebug message:@"Hello" request:[OCMArg checkWithBlock:^BOOL(NSURLRequest *obj) {
        return obj == request; //test the pointer adress is equal
    }]]);
}

- (void)testLogMessageEvent {
    OguryEventEntry *entry = [[OguryEventEntry alloc] initWithEvent:@"event" andMessage:@"test"];

    [self.log logEventBusMessage:OguryLogLevelDebug message:@"hello" eventEntry:entry];

    OCMVerify([self.log.oguryLog ogcLogEventBusMessage:OguryLogLevelDebug message:@"hello" eventEntry:[OCMArg checkWithBlock:^BOOL(OguryEventEntry *obj) {
        return obj == entry; //test the pointer adress is equal
    }]]);
}

@end
