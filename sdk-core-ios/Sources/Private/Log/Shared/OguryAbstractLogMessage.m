//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OguryAbstractLogMessage.h"
#import "OGCLogFormatter.h"

@implementation OguryAbstractLogMessage

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level logType:(OguryLogType)logType message:(NSString *)message {
    if (self = [super init]) {
        _level = level;
        _logType = logType;
        _message = message;
        _logFormatter = [[OGCLogFormatter alloc] init];
    }

    return self;
}

- (NSString *)formattedMessage {
    return [self.logFormatter formatLogMessage:self];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [[[self class] alloc] initWithLevel:self.level logType:self.logType message:self.message];
}

@end
