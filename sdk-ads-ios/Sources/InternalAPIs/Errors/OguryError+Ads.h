//
//  OguryError(Ads).h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 26/08/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <OguryCore/OguryError.h>

NS_ASSUME_NONNULL_BEGIN

@interface OguryError (Ads)

typedef NS_ENUM(NSInteger, OGAInternalError) {
    OGAInternalUnknownError = 100000
};

typedef NS_ENUM(NSInteger, OguryInternalAdsErrorOrigin) {
    OguryInternalAdsErrorOriginLoad = 0,
    OguryInternalAdsErrorOriginShow
};

typedef NS_ENUM(NSInteger, OguryAdsIntegrationType) {
    OguryAdsIntegrationTypeDirect = 0,
    OguryAdsIntegrationTypeHeaderBidding
};

@end

NS_ASSUME_NONNULL_END
