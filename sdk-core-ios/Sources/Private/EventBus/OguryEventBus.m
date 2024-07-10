//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OguryEventBus.h"
#import "OguryEventSubscriber.h"
#import "OguryEventEntry.h"

@implementation OguryEventBus

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        // Using a NSHashTable with weak pointers will prevent strong references to subscribers, which must be strongly retained on the client-side.
        _subscribers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsOpaquePersonality];
    }

    return self;
}

#pragma mark - Methods

- (void)registerOguryEventSubscriber:(id<OguryEventSubscriber>)oguryEventSubscriber {
    @synchronized (self.subscribers) {
        [self.subscribers addObject:oguryEventSubscriber];
    }
}

- (void)unregisterOguryEventSubscriber:(id<OguryEventSubscriber>)oguryEventSubscriber {
    id __unsafe_unretained unretainedSubscriber = oguryEventSubscriber;

    @synchronized (self.subscribers) {
        [self.subscribers removeObject:unretainedSubscriber];
    }
}

- (void)dispatchOguryEvent:(OguryEventEntry *)oguryEventEntry {
    @synchronized (self.subscribers) {
        for (id <OguryEventSubscriber> currentSubscriber in self.subscribers) {
            if (currentSubscriber.eventHandler != nil && [currentSubscriber.event isEqualToString:oguryEventEntry.event]) {
                currentSubscriber.eventHandler(oguryEventEntry);
            }
        }
    }
}

@end
