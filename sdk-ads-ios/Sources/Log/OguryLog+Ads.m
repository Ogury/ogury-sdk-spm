//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OguryLog+Ads.h"
#import "OGAAdLogMessage.h"
#import "OGAMraidLogMessage.h"
#import "OGAEventBusLogMessage.h"
#import <OguryCore/OguryLogger.h>

@implementation OguryLog (Ads)

- (void)ogaLogAdMessage:(OguryLogLevel)level adConfiguration:(OGAAdConfiguration *)adConfiguration message:(NSString *)message {
    @synchronized(self.loggers) {
        for (id<OguryLogger> currentLogger in self.loggers) {
            [currentLogger logMessage:[[OGAAdLogMessage alloc] initWithLevel:level adConfiguration:adConfiguration message:message]];
        }
    }
}

- (void)ogaLogMraidMessage:(OguryLogLevel)level adConfiguration:(OGAAdConfiguration *)adConfiguration webViewId:(NSString *)webViewId message:(NSString *)message {
    @synchronized(self.loggers) {
        for (id<OguryLogger> currentLogger in self.loggers) {
            [currentLogger logMessage:[[OGAMraidLogMessage alloc] initWithLevel:level adConfiguration:adConfiguration webviewId:webViewId message:message]];
        }
    }
}

- (void)ogaLogEventBusMessage:(OguryLogLevel)level eventEntry:(OguryEventEntry *)eventEntry message:(NSString *)message {
    @synchronized(self.loggers) {
        for (id<OguryLogger> currentLogger in self.loggers) {
            [currentLogger logMessage:[[OGAEventBusLogMessage alloc] initWithLevel:level eventEntry:eventEntry message:message]];
        }
    }
}

@end
