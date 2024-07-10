//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGABroadcastEventBus.h"
#import <OguryCore/OguryEventEntry.h>
#import <OguryCore/OguryEventBus.h>
#import "OGALog.h"
#import "OguryEventSubscriberMock.h"

@interface OGABroadcastEventBus ()

- (void)performOperationWithBroadcastEventBus:(void (^)(OguryEventBus *broadcastEventBus))completionHandler;
- (BOOL)shouldResetProfig:(OguryEventEntry *)eventEntry;

@end

@interface OGABroadcastEventBusTests : XCTestCase

@property(nonatomic, strong) OGABroadcastEventBus *broadcastEventBus;
@property(nonatomic, strong) OguryEventBus *coreEventBus;

@end

@implementation OGABroadcastEventBusTests

#pragma mark - Constants

static NSString *const DefaultEventMessage = @"cm-consent-change";
static NSString *const OGAAvengersLost = @"I am inevitable";
static NSString *const DefaultChoiceManagerEventBusCMChange = @"cm-consent-change ";

#pragma mark - methods

- (void)setUp {
    self.broadcastEventBus = OCMPartialMock([[OGABroadcastEventBus alloc] init]);
    self.coreEventBus = OCMClassMock([OguryEventBus class]);
    self.broadcastEventBus.coreBroadcastEventBus = self.coreEventBus;
}

- (void)testShouldResetProfigOK {
    OguryEventEntry *entry = OCMClassMock([OguryEventEntry class]);
    OCMStub(entry.message).andReturn(DefaultEventMessage);
    XCTAssertTrue([self.broadcastEventBus shouldResetProfig:entry]);
}

- (void)testShouldResetProfigKO {
    OguryEventEntry *entry = OCMClassMock([OguryEventEntry class]);
    OCMStub(entry.message).andReturn(OGAAvengersLost);
    XCTAssertFalse([self.broadcastEventBus shouldResetProfig:entry]);
}

- (void)testShouldRegisterSubscriber {
    self.broadcastEventBus.coreBroadcastEventBus = [[OguryEventBus alloc] init];
    OguryEventSubscriberMock *subscriber = [[OguryEventSubscriberMock alloc] initWithEvent:DefaultChoiceManagerEventBusCMChange andHandler:nil];
    [self.broadcastEventBus registerOguryEventSubscriber:subscriber];
    XCTAssertEqual(self.broadcastEventBus.coreBroadcastEventBus.subscribers.count, 1);
}

- (void)testShouldUnregisterSubscriber {
    self.broadcastEventBus.coreBroadcastEventBus = [[OguryEventBus alloc] init];
    OguryEventSubscriberMock *subscriber = [[OguryEventSubscriberMock alloc] initWithEvent:DefaultChoiceManagerEventBusCMChange andHandler:nil];
    [self.broadcastEventBus registerOguryEventSubscriber:subscriber];
    [self.broadcastEventBus unregisterOguryEventSubscriber:subscriber];
    XCTAssertEqual(self.broadcastEventBus.coreBroadcastEventBus.subscribers.count, 0);
}

- (void)testPerformOperationWithEventBus {
    [self.broadcastEventBus performOperationWithBroadcastEventBus:^(OguryEventBus *eventBus) {
        XCTAssertEqual(eventBus, self.coreEventBus);
    }];
}

@end
