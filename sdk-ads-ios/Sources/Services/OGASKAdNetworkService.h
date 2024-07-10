//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGASKAdNetworkResponse.h"

#if __has_include(<StoreKit/StoreKit.h>) || __has_include("StoreKit.h")
#define OGAStoreKitInstalled
#endif

#ifdef OGAStoreKitInstalled
#import <StoreKit/StoreKit.h>
#endif

@class OGAMonitoringDispatcher;
@class OGAAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface OGASKAdNetworkService : NSObject

+ (NSString *_Nullable)getSKAdNetworkVersion;

+ (BOOL)sdkIsCompatibleWithSKAdNetwork;

+ (NSArray<NSString *> *)getInfoAdNetworkItems;

+ (SKAdImpression *)createImpression:(NSString *)signature
        sourceAppStoreItemIdentifier:(NSNumber *)sourceAppStoreItemIdentifier
    advertisedAppStoreItemIdentifier:(NSNumber *)advertisedAppStoreItemIdentifier
                adCampaignIdentifier:(NSNumber *_Nullable)adCampaignIdentifier
                    sourceIdentifier:(NSNumber *_Nullable)sourceIdentifier
                 adNetworkIdentifier:(NSString *)adNetworkIdentifier
                             version:(NSString *)version
              adImpressionIdentifier:(NSString *)adImpressionIdentifier
                           timestamp:(NSNumber *)timestamp API_AVAILABLE(ios(14.5));

+ (void)startImpression:(SKAdImpression *)impression
    monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
         adConfiguration:(OGAAdConfiguration *)adConfiguration API_AVAILABLE(ios(14.5));

+ (void)endImpression:(SKAdImpression *)impression monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher adConfiguration:(OGAAdConfiguration *)adConfiguration API_AVAILABLE(ios(14.5));

+ (NSDictionary<NSString *, NSString *> *)getSKParameterFrom:(OGASKAdNetworkResponse *)skanResponse API_AVAILABLE(ios(14.0));

@end

NS_ASSUME_NONNULL_END
