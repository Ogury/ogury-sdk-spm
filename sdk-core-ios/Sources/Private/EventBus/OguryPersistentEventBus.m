//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OguryPersistentEventBus.h"
#import "OguryEventSubscriber.h"
#import "OguryEventEntry.h"
#import "OGCLog.h"
#import "OguryLogLevel.h"

@interface OguryPersistentEventBus ()

@property (nonatomic, retain) NSMutableDictionary<NSString *, OguryEventEntry *> *lastEvents;
@property (nonatomic, strong, readonly) OGCLog *log;

@end

@implementation OguryPersistentEventBus

#pragma mark - Constants

static NSString * const DefaultEventMessage = @"UNKNOWN";

#pragma mark - Initialization

- (instancetype)init {
    return [self init:[OGCLog shared]];
}

- (instancetype)init:(OGCLog *)log {
    if (self = [super init]) {
        _lastEvents = [[NSMutableDictionary alloc] init];
        _log = log;
    }

    return self;
}

#pragma mark - Methods

- (void)registerOguryEventSubscriber:(id<OguryEventSubscriber>)oguryEventSubscriber {
    [super registerOguryEventSubscriber:oguryEventSubscriber];

    // Replay last event or an empty event
    OguryEventEntry *lastEvent = self.lastEvents[oguryEventSubscriber.event] ?: [OguryEventEntry unknownEventEntryWithEvent:oguryEventSubscriber.event];

    [self.log logEventBusMessage:OguryLogLevelDebug message:@"New eventbus subscriber, dispatching last event" eventEntry:lastEvent];
    if (oguryEventSubscriber.eventHandler) {
        oguryEventSubscriber.eventHandler(lastEvent);
    }
}

- (void)dispatchOguryEvent:(OguryEventEntry *)oguryEventEntry {
    [super dispatchOguryEvent:oguryEventEntry];

    [self.log logEventBusMessage:OguryLogLevelDebug message:@"New event dispached" eventEntry:oguryEventEntry];
    [self.lastEvents setValue:oguryEventEntry forKey:oguryEventEntry.event];
}

@end
