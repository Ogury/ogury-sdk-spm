//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OGAPersistentEventBus.h"
#import <OguryCore/OguryEventBus.h>
#import <OguryCore/OguryPersistentEventBus.h>
#import "OGALog.h"
#import "OGAEventBusConstants.h"

@implementation OGAPersistentEventBus

#pragma mark - init

- (instancetype)init {
    if (self = [super init]) {
        // Use default PersistentEventBus to allow start Ads without Wrapper. Should be overridden by Wrapper SDK
        _corePersistentEventBus = [[OguryPersistentEventBus alloc] init];
    }
    return self;
}

#pragma mark - Methods

- (void)registerOguryEventSubscriber:(id<OguryEventSubscriber>)oguryEventSubscriber {
    [self performOperationWithPersistentEventBus:^(OguryPersistentEventBus *persistentEventBus) {
        [persistentEventBus registerOguryEventSubscriber:oguryEventSubscriber];
    }];
}

- (void)unregisterOguryEventSubscriber:(id<OguryEventSubscriber>)oguryEventSubscriber {
    [self performOperationWithPersistentEventBus:^(OguryPersistentEventBus *persistentEventBus) {
        [persistentEventBus unregisterOguryEventSubscriber:oguryEventSubscriber];
    }];
}

- (void)performOperationWithPersistentEventBus:(void (^)(OguryPersistentEventBus *persistentEventBus))completionHandler {
    if (self.corePersistentEventBus) {
        completionHandler(self.corePersistentEventBus);
    }
}

- (BOOL)shouldContinueLoadingAdWith:(OguryEventEntry *)eventEntry {
    if ([eventEntry.message isEqualToString:OGAChoiceManagerEventBusStatusComplete] || [eventEntry.message isEqualToString:OGCEventEntryMessageUnknown] ||
        [eventEntry.message isEqualToString:OGAChoiceManagerEventBusStatusError] || [self hasExpired:eventEntry]) {
        return YES;
    }

    return NO;
}

- (BOOL)hasExpired:(OguryEventEntry *)eventEntry {
    if (eventEntry.timestamp.timeIntervalSince1970 < ([[NSDate new] dateByAddingTimeInterval:-OguryChoiceManagerEventBusExpirationWindow].timeIntervalSince1970)) {
        return YES;
    }

    return NO;
}

- (void)setCorePersistentEventBus:(OguryPersistentEventBus *)persistentEventBus {
    NSArray<id<OguryEventSubscriber>> *subscribers = self.corePersistentEventBus.subscribers.allObjects;
    for (int index = 0; index < subscribers.count; index++) {
        id<OguryEventSubscriber> subscriber = subscribers[index];
        [persistentEventBus registerOguryEventSubscriber:subscriber];
        [self.corePersistentEventBus unregisterOguryEventSubscriber:subscriber];
    }
    _corePersistentEventBus = persistentEventBus;
}

@end
