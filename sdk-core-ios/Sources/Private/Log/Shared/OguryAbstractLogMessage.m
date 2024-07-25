//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OguryAbstractLogMessage.h"

@implementation OguryAbstractLogMessage

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level message:(NSString *)message {
    if (self = [super init]) {
        _level = level;
        _message = message;
    }

    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [[[self class] alloc] initWithLevel:self.level message:self.message];
}

@end
