//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGWLogFormatter.h"
#import <OguryCore/OguryStringFormattable.h>
#import <OguryCore/OguryLogLevel.h>

@implementation OGWLogFormatter

#pragma mark - Methods

- (NSString *)logLevelToString:(OguryLogLevel) logLevel {
    NSString *result;

     switch(logLevel) {
         case OguryLogLevelError:
             result = @"error";
             break;
         case OguryLogLevelWarning:
             result = @"warning";
             break;
         case OguryLogLevelInfo:
             result = @"info";
             break;
         case OguryLogLevelDebug:
             result = @"debug";
             break;
         case OguryLogLevelAll:
             result = @"all";
             break;
         case OguryLogLevelOff:
             result = @"off";
         break;
     }
     return result;
}

- (nullable NSString *)formatLogMessage:(OguryAbstractLogMessage *)logMessage {
    NSString *common = [NSString stringWithFormat:@"[%@]", [self logLevelToString:logMessage.level]];

    if ([logMessage conformsToProtocol:@protocol(OguryStringFormattable)]) {
        return [NSString stringWithFormat:@"%@%@", common, ((id<OguryStringFormattable>)logMessage).formattedString];
    } else {
        return [NSString stringWithFormat:@"%@[][Wrapper] %@", common, logMessage.message];
    }
}

@end
