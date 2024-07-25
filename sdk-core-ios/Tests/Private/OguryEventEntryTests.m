//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OguryEventEntry.h"

@interface OguryEventTests : XCTestCase

@end

@implementation OguryEventTests : XCTestCase

#pragma mark - Constants

static NSString *const DefaultEvent = @"Name";
static NSString *const DefaultEventMessage = @"Message";

#pragma mark - Methods

- (void)testShouldInstantiate {
    OguryEventEntry *event = [[OguryEventEntry alloc] initWithEvent:DefaultEvent andMessage:DefaultEventMessage];

    XCTAssertEqual(event.event, DefaultEvent);
    XCTAssertEqual(event.message, DefaultEventMessage);
}

- (void)testShouldInstantiateWithUnknownMessage {
    OguryEventEntry *event = [OguryEventEntry unknownEventEntryWithEvent:DefaultEvent];

    XCTAssertEqual(event.event, DefaultEvent);
    XCTAssertEqual(event.message, OGCEventEntryMessageUnknown);
}

@end
