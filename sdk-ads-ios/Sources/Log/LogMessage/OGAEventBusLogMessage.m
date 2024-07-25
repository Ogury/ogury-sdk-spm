//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGAEventBusLogMessage.h"

@implementation OGAEventBusLogMessage

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level eventEntry:(OguryEventEntry *)eventEntry message:(NSString *)message {
    if (self = [super initWithLevel:level message:message]) {
        _eventEntry = eventEntry;
    }

    return self;
}

#pragma mark - OguryStringFormattable

- (NSString *)formattedString {
    return [NSString stringWithFormat:@"[EventBus][%@] %@ - %@",
                                      self.eventEntry.event,
                                      self.eventEntry.message,
                                      self.message];
}

@end
