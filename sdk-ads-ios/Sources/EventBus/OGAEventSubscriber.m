//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAEventSubscriber.h"

@implementation OGAEventSubscriber

#pragma mark - Properties

@synthesize eventHandler;
@synthesize event;

#pragma mark - Initialization

- (instancetype)initWithEvent:(NSString *)event {
    return [self initWithEvent:event
                    andHandler:^(OguryEventEntry *event) {
                        if ([self.delegate respondsToSelector:@selector(hasReceivedEventWith:)]) {
                            [self.delegate hasReceivedEventWith:event];
                        }
                    }];
}

- (instancetype)initWithEvent:(NSString *)event andHandler:(eventHandlerBlock)eventHandler {
    if (self = [super init]) {
        self.event = event;
        self.eventHandler = eventHandler;
    }

    return self;
}

@end
