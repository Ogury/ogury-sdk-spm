//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OguryEventEntry.h"

@implementation OguryEventEntry

#pragma mark - Constants

NSString * const OGCEventEntryMessageUnknown = @"UNKNOWN";

#pragma mark - Initialization

- (instancetype)initWithEvent:(NSString *)event andMessage:(NSString *)message {
    if (self = [super init]) {
        _event = event;
        _message = message;
        _timestamp = [[NSDate alloc] init];
    }

    return self;
}

+ (instancetype)unknownEventEntryWithEvent:(NSString *)event {
    return [[self alloc] initWithEvent:event andMessage:OGCEventEntryMessageUnknown];
}

@end
