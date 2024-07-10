//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGCEventLogMessage.h"

@implementation OGCEventLogMessage

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level message:(NSString *)message eventEntry:(OguryEventEntry *)eventEntry {
    if (self = [super initWithLevel:level message:message]) {
        _eventEntry = eventEntry;
    }

    return self;
}

#pragma mark - OguryStringFormattable

- (NSString *)formattedString {
    return [NSString stringWithFormat:@"[EventBus][%@] %@ - %@", self.eventEntry.event, self.message, self.eventEntry.message];
}

@end
