//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OguryEventBus.h"
#import "OguryEventSubscriberMock.h"
#import "OguryEventEntry.h"

@interface OguryEventBusTests : XCTestCase

@end

@implementation OguryEventBusTests

#pragma mark - Constants

static NSString *const DefaultEvent = @"Name";
static NSString *const DefaultEventMessage = @"Message";

#pragma mark - Methods

- (void)testShouldRegisterSubscriber {
    OguryEventBus *eventBus = [[OguryEventBus alloc] init];

    OguryEventSubscriberMock *subscriber = [[OguryEventSubscriberMock alloc] initWithEvent:DefaultEvent andHandler:nil];

    [eventBus registerOguryEventSubscriber:subscriber];

    XCTAssertEqual(eventBus.subscribers.count, 1);
}

- (void)testShouldUnregisterSubscriber {
    OguryEventBus *eventBus = [[OguryEventBus alloc] init];

    OguryEventSubscriberMock *subscriber = [[OguryEventSubscriberMock alloc] initWithEvent:DefaultEvent andHandler:nil];

    [eventBus registerOguryEventSubscriber:subscriber];
    [eventBus unregisterOguryEventSubscriber:subscriber];

    XCTAssertEqual(eventBus.subscribers.count, 0);
}

- (void)testShouldDispatchEvent {
    OguryEventBus *eventBus = [[OguryEventBus alloc] init];

    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should handle event"];

    OguryEventSubscriberMock *subscriber = [[OguryEventSubscriberMock alloc] initWithEvent:DefaultEvent andHandler:^(OguryEventEntry * _Nonnull event) {
        [testExpectation fulfill];
    }];

    [eventBus registerOguryEventSubscriber:subscriber];
    [eventBus dispatchOguryEvent:[[OguryEventEntry alloc] initWithEvent:DefaultEvent andMessage:DefaultEventMessage]];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
