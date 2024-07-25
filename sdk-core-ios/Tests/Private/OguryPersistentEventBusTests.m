//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OguryPersistentEventBus.h"
#import "OguryEventSubscriberMock.h"
#import "OguryEventEntry.h"

@interface OguryPersistentEventBusTests : XCTestCase

@end

@implementation OguryPersistentEventBusTests

#pragma mark - Constants

static NSString *const DefaultEvent = @"Name";
static NSString *const DefaultEventMessage = @"Message";

#pragma mark - Methods

- (void)testShouldRegisterSubscriber {
    OguryPersistentEventBus *eventBus = [OguryPersistentEventBus new];

    OguryEventSubscriberMock *subscriber = [[OguryEventSubscriberMock alloc] initWithEvent:DefaultEvent andHandler:nil];

    [eventBus registerOguryEventSubscriber:subscriber];

    XCTAssertEqual(eventBus.subscribers.count, 1);
}

- (void)testShouldUnregisterSubscriber {
    OguryPersistentEventBus *eventBus = [OguryPersistentEventBus new];

    OguryEventSubscriberMock *subscriber = [[OguryEventSubscriberMock alloc] initWithEvent:DefaultEvent andHandler:nil];

    [eventBus registerOguryEventSubscriber:subscriber];
    [eventBus unregisterOguryEventSubscriber:subscriber];

    XCTAssertEqual(eventBus.subscribers.count, 0);
}

- (void)testShouldDispatchLastEvent {
    OguryPersistentEventBus *eventBus = [OguryPersistentEventBus new];

    [eventBus dispatchOguryEvent:[[OguryEventEntry alloc] initWithEvent:DefaultEvent andMessage:DefaultEventMessage]];

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should handle previously dispatched event"];

    OguryEventSubscriberMock *subscriber = [[OguryEventSubscriberMock alloc] initWithEvent:DefaultEvent
                                                                                andHandler:^(OguryEventEntry * _Nonnull event) {
        XCTAssertEqual(event.event, DefaultEvent);
        XCTAssertEqual(event.message, DefaultEventMessage);
        [testExpectation fulfill];
    }];

    [eventBus registerOguryEventSubscriber:subscriber];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
