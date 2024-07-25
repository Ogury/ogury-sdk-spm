//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGABroadcastEventBus.h"
#import <OguryCore/OguryPersistentEventBus.h>

@implementation OGABroadcastEventBus

#pragma mark - Constants

NSString *const OGAChoiceManagerEventBusCMChange = @"cm-consent-change";

#pragma mark - init

- (instancetype)init {
    if (self = [super init]) {
        // Use default broadcast eventBus to allow start Ads without Wrapper. Should be overridden by Wrapper SDK
        _coreBroadcastEventBus = [[OguryEventBus alloc] init];
    }
    return self;
}

#pragma mark - Methods

- (BOOL)shouldResetProfig:(OguryEventEntry *)eventEntry {
    if ([eventEntry.message isEqualToString:OGAChoiceManagerEventBusCMChange]) {
        return YES;
    }

    return NO;
}

- (void)registerOguryEventSubscriber:(id<OguryEventSubscriber>)oguryEventSubscriber {
    [self performOperationWithBroadcastEventBus:^(OguryEventBus *broadcastEventBus) {
        [broadcastEventBus registerOguryEventSubscriber:oguryEventSubscriber];
    }];
}

- (void)performOperationWithBroadcastEventBus:(void (^)(OguryEventBus *broadcastEventBus))completionHandler {
    if (self.coreBroadcastEventBus) {
        completionHandler(self.coreBroadcastEventBus);
    }
}

- (void)unregisterOguryEventSubscriber:(id<OguryEventSubscriber>)oguryEventSubscriber {
    [self performOperationWithBroadcastEventBus:^(OguryEventBus *broadcastEventBus) {
        [broadcastEventBus unregisterOguryEventSubscriber:oguryEventSubscriber];
    }];
}

@end
