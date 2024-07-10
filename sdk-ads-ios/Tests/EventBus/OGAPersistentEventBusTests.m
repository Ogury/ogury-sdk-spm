//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAPersistentEventBus.h"
#import <OguryCore/OguryEventEntry.h>
#import <OguryCore/OguryEventBus.h>
#import <OguryCore/OguryPersistentEventBus.h>
#import "OGALog.h"
#import "OguryEventSubscriberMock.h"

@interface OGAPersistentEventBus ()

- (void)performOperationWithPersistentEventBus:(void (^)(OguryPersistentEventBus *persistentEventBus))completionHandler;

- (BOOL)shouldContinueLoadingAdWith:(OguryEventEntry *)eventEntry;

- (BOOL)hasExpired:(OguryEventEntry *)eventEntry;

@end

@interface OGAPersistentEventBusTests : XCTestCase

@property(nonatomic, strong) OGAPersistentEventBus *persistentEventBus;
@property(nonatomic, strong) OguryPersistentEventBus *corePersistentEventBus;

@end

@implementation OGAPersistentEventBusTests

#pragma mark - Constants

static NSString *const DefaultEvent = @"CM-status";
static NSString *const DefaultEventMessage = @"UNKNOWN";
static NSString *const OGAAvengersLost = @"I am inevitable";

#pragma mark - Methods

- (void)setUp {
    self.persistentEventBus = OCMPartialMock([[OGAPersistentEventBus alloc] init]);
    self.corePersistentEventBus = OCMClassMock([OguryEventBus class]);
    self.persistentEventBus.corePersistentEventBus = self.corePersistentEventBus;
}

- (void)testShouldRegisterSubscriber {
    OGAPersistentEventBus *consentEventBus = [[OGAPersistentEventBus alloc] init];
    consentEventBus.corePersistentEventBus = [[OguryPersistentEventBus alloc] init];

    OguryEventSubscriberMock *subscriber = [[OguryEventSubscriberMock alloc] initWithEvent:DefaultEvent andHandler:nil];

    [consentEventBus registerOguryEventSubscriber:subscriber];

    XCTAssertEqual(consentEventBus.corePersistentEventBus.subscribers.count, 1);
}

- (void)testShouldUnregisterSubscriber {
    OGAPersistentEventBus *consentEventBus = [[OGAPersistentEventBus alloc] init];
    consentEventBus.corePersistentEventBus = [[OguryPersistentEventBus alloc] init];

    OguryEventSubscriberMock *subscriber = [[OguryEventSubscriberMock alloc] initWithEvent:DefaultEvent andHandler:nil];

    [consentEventBus registerOguryEventSubscriber:subscriber];
    [consentEventBus unregisterOguryEventSubscriber:subscriber];

    XCTAssertEqual(consentEventBus.corePersistentEventBus.subscribers.count, 0);
}

- (void)testShouldContinueLoadingAdYES {
    OguryEventEntry *eventEntry = OCMClassMock([OguryEventEntry class]);
    OCMStub(eventEntry.message).andReturn(OGCEventEntryMessageUnknown);
    XCTAssertTrue([self.persistentEventBus shouldContinueLoadingAdWith:eventEntry]);
}

- (void)testShouldContinueLoadingAdNO {
    OguryEventEntry *eventEntry = OCMClassMock([OguryEventEntry class]);
    OCMStub(eventEntry.message).andReturn(OGAAvengersLost);
    OCMStub([self.persistentEventBus hasExpired:[OCMArg any]]).andReturn(NO);
    XCTAssertFalse([self.persistentEventBus shouldContinueLoadingAdWith:eventEntry]);
}

- (void)testHasExpiredYES {
    OguryEventEntry *eventEntry = OCMClassMock([OguryEventEntry class]);
    OCMStub(eventEntry.timestamp).andReturn([NSDate dateWithTimeIntervalSinceNow:-30]);
    XCTAssertTrue([self.persistentEventBus hasExpired:eventEntry]);
}

- (void)testHasExpiredNO {
    OguryEventEntry *eventEntry = OCMClassMock([OguryEventEntry class]);
    OCMStub(eventEntry.timestamp).andReturn([NSDate new]);
    XCTAssertFalse([self.persistentEventBus hasExpired:eventEntry]);
}

@end
