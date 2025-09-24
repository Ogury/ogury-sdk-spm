//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "NSDate+OGAFormatter.h"
#import "OGAAdMonitorEvent.h"
#import "OGAAdServerMonitorRequestBuilder.h"
#import "OGAEnvironmentManager.h"
#import "OGAMetricsService.h"
#import "OGAMonitoringDispatcher+SKNetwork.h"
#import "OGAOrderedDictionary.h"
#import "OGAProfigManager.h"
#import "OGMEventPersistanceStore.h"
#import "OGMMonitorManager.h"
#import "OGMOSLogMonitor.h"
#import "OGMServerMonitor.h"

@interface OGAMonitoringDispatcher ()

/// This method creates an event from the permissions of OGAMonitorEventConfigurationFactory,
/// it adds the OGAMonitoringErrorEventContentReason to errorContent if it is an error,
/// cheks if the event is not blacklisted
/// and finally sends the event to all Monitorables
/// - Parameters:
///   - event: the event to handle
///   - adConfiguration: the associated ad configuration
///   - sessionId: custom sessions Id to use. It will use ``adConfiguration.sessionId`` if nil
///   - details: the details dictionary if any
///   - errorContent: the error content dictionary if any
///
/// - Warning it adds the OGAMonitoringErrorEventContentReason to errorContent if it is an error
- (void)prepareAndSend:(OGAMonitoringEvent)event
       adConfiguration:(OGAAdConfiguration *)adConfiguration
       customSessionId:(NSString *_Nullable)sessionId
               details:(OGAOrderedDictionary *_Nullable)details
          errorContent:(OGAOrderedDictionary *_Nullable)errorContent;

@end

@implementation OGAMonitoringDispatcher (SKNetwork)

- (void)sendSKNetworkLoadStoreControllerEvent:(OGAMonitoringEvent)event
                                        nonce:(NSString *_Nullable)nonce
                                 itunesItemId:(NSNumber *_Nullable)itunesItemId
                              adConfiguration:(OGAAdConfiguration *)adConfiguration {
    OGAMutableOrderedDictionary *details = [OGAMutableOrderedDictionary dictionary];
    if (nonce) {
        [details setObject:nonce forKey:OGAMonitoringEventDetailNonce];
    }
    if (itunesItemId) {
        [details setObject:itunesItemId forKey:OGAMonitoringEventDetailItunesItemId];
    }

    [self prepareAndSend:event
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:details
            errorContent:nil];
}

- (void)sendSKNetworkImpressionEvent:(OGAMonitoringEvent)event
    advertisedAppStoreItemIdentifier:(NSNumber *_Nullable)advertisedAppStoreItemIdentifier
                     adConfiguration:(OGAAdConfiguration *)adConfiguration {
    [self prepareAndSend:event
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:[[OGAOrderedDictionary alloc]
                             initWithDictionary:@{OGAMonitoringEventDetailAdvertisedAppStoreItemIdentifier : advertisedAppStoreItemIdentifier}]
            errorContent:nil];
}

- (void)sendSKNetworkFailedLoadStoreControllerEvent:(OGAMonitoringEvent)event
                                              nonce:(NSString *_Nullable)nonce
                                       itunesItemId:(NSNumber *_Nullable)itunesItemId
                                    adConfiguration:(OGAAdConfiguration *)adConfiguration {
    OGAMutableOrderedDictionary *errorContent = [OGAMutableOrderedDictionary dictionary];
    if (nonce) {
        [errorContent setObject:nonce forKey:OGAMonitoringEventDetailNonce];
    }
    if (itunesItemId) {
        [errorContent setObject:itunesItemId forKey:OGAMonitoringEventDetailItunesItemId];
    }
    [self prepareAndSend:event
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:nil
            errorContent:errorContent];
}

- (void)sendSKNetworkFailedImpressionEvent:(OGAMonitoringEvent)event
          advertisedAppStoreItemIdentifier:(NSNumber *_Nullable)advertisedAppStoreItemIdentifier
                           adConfiguration:(OGAAdConfiguration *)adConfiguration {
    OGAMutableOrderedDictionary *errorContent = [OGAMutableOrderedDictionary dictionary];
    if (advertisedAppStoreItemIdentifier) {
        [errorContent setObject:advertisedAppStoreItemIdentifier forKey:OGAMonitoringEventDetailAdvertisedAppStoreItemIdentifier];
    }
    [self prepareAndSend:event
         adConfiguration:adConfiguration
         customSessionId:nil
                 details:nil
            errorContent:errorContent];
}

@end
