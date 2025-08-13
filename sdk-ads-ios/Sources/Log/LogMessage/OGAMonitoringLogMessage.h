//
//  OGAMonitoringLogMessage.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 19/09/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import "OGAAdLogMessage.h"

@protocol OGMEventMonitorable;

NS_ASSUME_NONNULL_BEGIN

@interface OGAMonitoringLogMessage : OGAAdLogMessage

- (instancetype)initWithLevel:(OguryLogLevel)level
              adConfiguration:(OGAAdConfiguration *_Nullable)adConfiguration
                      message:(NSString *)message
                        event:(id<OGMEventMonitorable>)event;

- (instancetype)initWithLevel:(OguryLogLevel)level
              adConfiguration:(OGAAdConfiguration *_Nullable)adConfiguration
                        error:(NSError *)error
                      message:(NSString *_Nullable)message
                        event:(id<OGMEventMonitorable>)event;
@end

NS_ASSUME_NONNULL_END
