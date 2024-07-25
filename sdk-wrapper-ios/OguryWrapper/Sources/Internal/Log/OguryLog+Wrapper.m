//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OguryLog+Wrapper.h"
#import "OGWAssetKeyLogMessage.h"
#import <OguryCore/OguryLogger.h>

@implementation OguryLog (Wrapper)

- (void)ogwlogAssetKeyMessage:(OguryLogLevel)level assetKey:(NSString *)assetKey message:(NSString *)message {
    @synchronized (self.loggers) {
        for (id<OguryLogger> currentLogger in self.loggers) {
            [currentLogger logMessage:[[OGWAssetKeyLogMessage alloc] initWithLevel:level assetKey:assetKey message:message]];
        }
    }
}

@end

