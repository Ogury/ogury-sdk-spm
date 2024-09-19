//
//  Copyright © 2024 Ogury. All rights reserved.
//

#import "OguryNSLogger.h"

@implementation OguryNSLogger

- (instancetype)initWithLevel:(OguryLogLevel)level {
    if (self = [super init]) {
        _logLevel = level;
        _allowedLogTypes = @[OguryLogTypePublisher];
        _logFormatter = [[OguryLogFormatter alloc] init];
    }
    return self;
}

- (void)logMessage:(OguryLogMessage *)message { 
    NSLog(@"💻 %@", [self.logFormatter formatLogMessage:message]);
}

@end
