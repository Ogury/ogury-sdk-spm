//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAEventBusLogMessage.h"
#import <OguryCore/OguryLogLevel.h>

@interface OGAEventBusLogMessageTests : XCTestCase

@end

@implementation OGAEventBusLogMessageTests

NSString *const OGAEventBusLogMessageTestsEventEntry = @"OGAEventBusLogMessageTestsEventEntry";
NSString *const OGAEventBusLogMessageTestsEventMessage = @"OGAEventBusLogMessageTestseventMessage";
NSString *const OGAEventBusLogMessageTestsLogMessage = @"testMessage";

- (void)testFormatString {
    OguryEventEntry *eventEntry = [[OguryEventEntry alloc] initWithEvent:OGAEventBusLogMessageTestsEventEntry andMessage:OGAEventBusLogMessageTestsEventMessage];

    OGAEventBusLogMessage *logMessage = [[OGAEventBusLogMessage alloc] initWithLevel:OguryLogLevelError eventEntry:eventEntry message:OGAEventBusLogMessageTestsLogMessage];

    NSString *expected = [NSString stringWithFormat:@"[EventBus][%@] %@ - %@",
                                                    eventEntry.event,
                                                    eventEntry.message,
                                                    OGAEventBusLogMessageTestsLogMessage];
    XCTAssertTrue([[logMessage formattedString] isEqualToString:expected]);
}

@end
