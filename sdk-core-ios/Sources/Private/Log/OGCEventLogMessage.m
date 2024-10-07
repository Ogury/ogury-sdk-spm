//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGCEventLogMessage.h"

@implementation OGCEventLogMessage

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level message:(NSString *)message {
    if (self = [super initWithLevel:level message:message]) {
    }

    return self;
}

#pragma mark - OguryStringFormattable

- (NSString *)formattedString {
    return [NSString stringWithFormat:@"%@", self.message];
}

@end
