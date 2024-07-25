//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <OguryCore/OguryStringFormattable.h>
#import <OguryCore/OguryLogLevel.h>
#import "OGALogFormatter.h"
#import "OGAAssetKeyManager.h"

@implementation OGALogFormatter

#pragma mark - Methods

- (NSString *)logLevelToString:(OguryLogLevel)logLevel {
    NSString *result;

    switch (logLevel) {
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

- (NSString *)getAssetKey {
    return [[OGAAssetKeyManager shared] assetKey] ?: @"";
}

- (nullable NSString *)formatLogMessage:(OguryAbstractLogMessage *)logMessage {
    NSString *common;

    NSString *logLevelString = [self logLevelToString:logMessage.level];
    NSString *assetKeyString = [self getAssetKey];
    common = [NSString stringWithFormat:@"[%@][%@][Ads]", logLevelString, assetKeyString];

    if ([logMessage conformsToProtocol:@protocol(OguryStringFormattable)]) {
        return [NSString stringWithFormat:@"%@%@", common, ((id<OguryStringFormattable>)logMessage).formattedString];
    } else {
        return [NSString stringWithFormat:@"%@%@", common, logMessage.message];
    }
}

@end
