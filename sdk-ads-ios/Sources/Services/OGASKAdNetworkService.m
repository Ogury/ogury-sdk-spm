//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGASKAdNetworkService.h"
#import <Foundation/Foundation.h>
#import "OGALog.h"
#import "OGAMonitoringConstants.h"
#import "OGAMonitoringDispatcher+SKNetwork.h"

static NSString *_Nonnull OGASKAdNetworkItemsKey = @"SKAdNetworkItems";
static NSString *_Nonnull OGASKAdNetworkIdentifierKey = @"SKAdNetworkIdentifier";

@interface OGASKAdNetworkService ()

@end

@implementation OGASKAdNetworkService

+ (NSString *_Nullable)getSKAdNetworkVersion {
    if (@available(iOS 16.1, *)) {
        return @"4.0";
    }
    if (@available(iOS 14.6, *)) {
        return @"3.0";
    }
    if (@available(iOS 14.5, *)) {
        return @"2.2";
    }
    if (@available(iOS 14.0, *)) {
        return @"2.1";
    }
    if (@available(iOS 11.3, *)) {
        return @"1.0";
    }
    return NULL;
}

+ (NSDictionary<NSString *, NSString *> *)getSKParameterFrom:(OGASKAdNetworkResponse *)skanResponse {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    if (skanResponse.itunesItemId.stringValue) {
        parameters[SKStoreProductParameterITunesItemIdentifier] = skanResponse.itunesItemId.stringValue;
    }
    if (skanResponse.version) {
        parameters[SKStoreProductParameterAdNetworkVersion] = skanResponse.version;
    }
    if (skanResponse.sourceAppId.stringValue) {
        parameters[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] = skanResponse.sourceAppId.stringValue;
    }
    if (skanResponse.signature) {
        parameters[SKStoreProductParameterAdNetworkAttributionSignature] = skanResponse.signature;
    }
    if (skanResponse.timestamp.stringValue) {
        parameters[SKStoreProductParameterAdNetworkTimestamp] = skanResponse.timestamp.stringValue;
    }
    if (skanResponse.networkIdentifier) {
        parameters[SKStoreProductParameterAdNetworkIdentifier] = skanResponse.networkIdentifier;
    }
    if (skanResponse.nonce) {
        NSUUID *nonce = [[NSUUID alloc] initWithUUIDString:skanResponse.nonce];
        if (nonce) {
            parameters[SKStoreProductParameterAdNetworkNonce] = nonce;
        }
    }
    if (skanResponse.sourceIdentifier) {
        if (@available(iOS 16.1, *)) {
            parameters[SKStoreProductParameterAdNetworkSourceIdentifier] = skanResponse.sourceIdentifier;
        }
    }
    if (skanResponse.campaignId.stringValue) {
        parameters[SKStoreProductParameterAdNetworkCampaignIdentifier] = skanResponse.campaignId.stringValue;
    }

    return parameters;
}

+ (NSArray<NSString *> *)getInfoAdNetworkItems {
    NSArray<NSDictionary<NSString *, NSString *> *> *networkItems = [[NSBundle mainBundle] objectForInfoDictionaryKey:OGASKAdNetworkItemsKey];
    NSMutableArray<NSString *> *networkList = [NSMutableArray new];
    for (NSDictionary<NSString *, NSString *> *networkItem in networkItems) {
        if ([networkItem isKindOfClass:[NSDictionary class]]) {
            if ([networkItem count] > 0 && [networkItem.allKeys containsObject:OGASKAdNetworkIdentifierKey]) {
                [networkList addObject:networkItem[OGASKAdNetworkIdentifierKey]];
            }
        }
    }
    return networkList;
}

+ (BOOL)sdkIsCompatibleWithSKAdNetwork {
    NSString *SKAdNetworkVersion = [OGASKAdNetworkService getSKAdNetworkVersion];
    if (SKAdNetworkVersion == NULL) {
        [[OGALog shared] log:OguryLogLevelDebug message:@"[SKAdNetwork] Not compatible with SKAdNetwork due to version number"];
        return NO;
    }
    if ([SKAdNetworkVersion isEqualToString:@"adNetworkPayloadVersion"] || [SKAdNetworkVersion hasPrefix:@"1"] || [SKAdNetworkVersion hasPrefix:@"2.0"] || [SKAdNetworkVersion hasPrefix:@"2.1"]) {
        [[OGALog shared] log:OguryLogLevelDebug message:@"[SKAdNetwork] Not compatible with SKAdNetwork due to version number"];
        return NO;
    }
    return YES;
}

+ (SKAdImpression *)createImpression:(NSString *)signature
        sourceAppStoreItemIdentifier:(NSNumber *)sourceAppStoreItemIdentifier
    advertisedAppStoreItemIdentifier:(NSNumber *)advertisedAppStoreItemIdentifier
                adCampaignIdentifier:(NSNumber *_Nullable)adCampaignIdentifier
                    sourceIdentifier:(NSNumber *_Nullable)sourceIdentifier
                 adNetworkIdentifier:(NSString *)adNetworkIdentifier
                             version:(NSString *)version
              adImpressionIdentifier:(NSString *)adImpressionIdentifier
                           timestamp:(NSNumber *)timestamp API_AVAILABLE(ios(14.5)) {
    SKAdImpression *impression = [[SKAdImpression alloc] init];
    impression.sourceAppStoreItemIdentifier = sourceAppStoreItemIdentifier;
    impression.advertisedAppStoreItemIdentifier = advertisedAppStoreItemIdentifier;
    impression.adNetworkIdentifier = adNetworkIdentifier;
    impression.adCampaignIdentifier = adCampaignIdentifier;
    impression.adImpressionIdentifier = adImpressionIdentifier;
    impression.timestamp = timestamp;
    impression.signature = signature;
    impression.version = version;

    if (sourceIdentifier) {
        if (@available(iOS 16.0, *)) {
            impression.sourceIdentifier = sourceIdentifier;
        } else {
            [[OGALog shared] log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError
                                                        adConfiguration:nil
                                                                logType:OguryLogTypePublisher
                                                                message:@"[SKAdNetwork] Not compatible campaign id with version"
                                                                   tags:nil]];
        }
    }

    return impression;
}

+ (void)startImpression:(SKAdImpression *)impression
    monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
         adConfiguration:(OGAAdConfiguration *)adConfiguration API_AVAILABLE(ios(14.5)) {
    [SKAdNetwork startImpression:impression
               completionHandler:^(NSError *_Nullable error) {
                   if (error != NULL) {
                       [[OGALog shared] log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError
                                                                   adConfiguration:nil
                                                                           logType:OguryLogTypePublisher
                                                                           message:[NSString stringWithFormat:@"[SKAdNetwork] failed to start impression : %@", error.description]
                                                                              tags:nil]];
                       [monitoringDispatcher sendSKNetworkFailedImpressionEvent:OGASKNetworkShowErrorEventFailedToStartImpression
                                               advertisedAppStoreItemIdentifier:impression.advertisedAppStoreItemIdentifier
                                                                adConfiguration:adConfiguration];
                   } else {
                       [monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventStartImpression
                                         advertisedAppStoreItemIdentifier:impression.advertisedAppStoreItemIdentifier
                                                          adConfiguration:adConfiguration];
                   }
               }];
}

+ (void)endImpression:(SKAdImpression *)impression monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher adConfiguration:(OGAAdConfiguration *)adConfiguration API_AVAILABLE(ios(14.5)) {
    [SKAdNetwork endImpression:impression
             completionHandler:^(NSError *_Nullable error) {
                 if (error != NULL) {
                     [[OGALog shared] log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError
                                                                 adConfiguration:nil
                                                                         logType:OguryLogTypePublisher
                                                                         message:[NSString stringWithFormat:@"[SKAdNetwork] failed to end impression : %@", error.description]
                                                                            tags:nil]];
                     [monitoringDispatcher sendSKNetworkFailedImpressionEvent:OGASKNetworkShowErrorEventFailedToStopImpression
                                             advertisedAppStoreItemIdentifier:impression.advertisedAppStoreItemIdentifier
                                                              adConfiguration:adConfiguration];
                 } else {
                     [monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventStopImpression
                                       advertisedAppStoreItemIdentifier:impression.advertisedAppStoreItemIdentifier
                                                        adConfiguration:adConfiguration];
                 }
             }];
}

@end
