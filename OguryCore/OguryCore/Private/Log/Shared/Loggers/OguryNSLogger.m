//
//  Copyright © 2024 Ogury. All rights reserved.
//

#import "OguryNSLogger.h"

@implementation OguryNSLogger

- (instancetype)initWithLevel:(OguryLogLevel)level {
    if (self = [super init]) {
        _logLevel = level;
        _allowedLogTypes = @[OguryLogTypePublisher, @"SDK Callbacks"];
        _logFormatter = [[OguryLogFormatter alloc] init];
        _logFormatter.displayOptions = OguryLogDisplaySDK | OguryLogDisplayOrigin | OguryLogDisplayType | OguryLogDisplayLevel | OguryLogDisplayTags | OguryLogDisplayDate;
    }
    return self;
}

- (void)logMessage:(OguryLogMessage *)message { 
    NSLog(@"💻 %@", [self.logFormatter formatLogMessage:message]);
}

@end
