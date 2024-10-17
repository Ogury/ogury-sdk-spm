//
//  OGAMonitoringLogMessage.m
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 19/09/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import "OGAMonitoringLogMessage.h"
#import "OGAMonitoringConstants.h"
#import "OGMEventMonitorable.h"
#import "OGALog.h"

@implementation OGAMonitoringLogMessage

- (instancetype)initWithLevel:(OguryLogLevel)level
                      message:(NSString *)message
                        event:(id<OGMEventMonitorable>)event {
    if (self = [super initWithLevel:level
                    adConfiguration:nil
                            logType:OguryLogTypeMonitoring
                            message:message
                               tags:nil]) {
        NSDictionary *eventAsDict = event.asDisctionary;
        self.tags = @[
            [OguryLogTag tagWithKey:@"Code"
                              value:eventAsDict[OGAMonitorEventBodyEventCode]],
            [OguryLogTag tagWithKey:@"Name"
                              value:eventAsDict[OGAMonitorEventBodyEventName]],
            [OguryLogTag tagWithKey:@"Units"
                              value:eventAsDict[OGAAdMonitorEventBodyAdUnit]]
        ];
    }
    return self;
}

- (instancetype)initWithLevel:(OguryLogLevel)level
                        error:(NSError *)error
                      message:(NSString *_Nullable)message
                        event:(id<OGMEventMonitorable>)event {
    return [self initWithLevel:level
                       message:message == nil ? logErrorMessage(error) : [logErrorMessage(error) stringByAppendingFormat:@" - %@", message]
                         event:event];
}
@end
