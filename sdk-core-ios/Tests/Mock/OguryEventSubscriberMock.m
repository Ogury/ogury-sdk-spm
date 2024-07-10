//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OguryEventSubscriberMock.h"

@implementation OguryEventSubscriberMock

#pragma mark - Initialization

- (instancetype)initWithEvent:(NSString *)event {
    if (self = [super init]) {
        _event = event;
    }

    return self;
}

- (instancetype)initWithEvent:(NSString *)event andHandler:(eventHandlerBlock)eventHandler {
    if (self = [self initWithEvent:event]) {
        _eventHandler = eventHandler;
    }

    return self;
}

#pragma mark - Methods

- (void)handleOguryEvent:(nonnull OguryEventEntry *)event {
    if (self.eventHandler != nil) {
        self.eventHandler(event);
    } else {
        self.hasHandledEvent = YES;
    }
}

@end
