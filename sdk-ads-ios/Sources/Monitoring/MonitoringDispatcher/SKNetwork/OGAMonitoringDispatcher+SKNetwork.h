//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGAMonitoringConstants.h"
#import "OGAMonitoringDispatcher.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark SKNetwork flow enums

@interface OGAMonitoringDispatcher (SKNetwork)

- (void)sendSKNetworkLoadStoreControllerEvent:(OGAMonitoringEvent)event
                                        nonce:(NSString *_Nullable)nonce
                                 itunesItemId:(NSNumber *_Nullable)itunesItemId
                              adConfiguration:(OGAAdConfiguration *)adConfiguration;

- (void)sendSKNetworkImpressionEvent:(OGAMonitoringEvent)event
    advertisedAppStoreItemIdentifier:(NSNumber *_Nullable)advertisedAppStoreItemIdentifier
                     adConfiguration:(OGAAdConfiguration *)adConfiguration;

- (void)sendSKNetworkFailedLoadStoreControllerEvent:(OGAMonitoringEvent)event
                                              nonce:(NSString *_Nullable)nonce
                                       itunesItemId:(NSNumber *_Nullable)itunesItemId
                                    adConfiguration:(OGAAdConfiguration *)adConfiguration;

- (void)sendSKNetworkFailedImpressionEvent:(OGAMonitoringEvent)event
          advertisedAppStoreItemIdentifier:(NSNumber *_Nullable)advertisedAppStoreItemIdentifier
                           adConfiguration:(OGAAdConfiguration *)adConfiguration;

@end

NS_ASSUME_NONNULL_END
