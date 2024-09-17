//
//  Copyright © 2024 Ogury. All rights reserved.
//

#import "OguryNSLogger.h"

@implementation OguryNSLogger

- (instancetype)initWithLevel:(OguryLogLevel)level {
    if (self = [super init]) {
        _logLevel = level;
        _allowedLogTypes = @[OguryLogTypePublisher];
    }
    return self;
}

- (void)logMessage:(OguryLogMessage *)message { 
    NSLog(@"💻 %@", message.formattedMessage);
}

@end
