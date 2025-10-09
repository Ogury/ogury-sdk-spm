//
//  OguryBidTokenErrorCode.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 01/10/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

typedef NS_ENUM(NSInteger, OguryBidTokenErrorCode) {
    OguryBidTokenErrorCodeSDKNotStarted = 4000,
    OguryBidTokenErrorCodeSDKNotProperlyInitialized = 4001,
    OguryBidTokenErrorCodeNoActiveInternetConnection = 4002,
    OguryBidTokenErrorCodeInvalidConfiguration = 4100,
    OguryBidTokenErrorCodeAdDisabledCountryNotOpened = 4101,
    OguryBidTokenErrorCodeAdDisabledConsentDenied = 4102,
    OguryBidTokenErrorCodeAdDisabledConsentMissing = 4103,
    OguryBidTokenErrorCodeAdDisabledUnspecifiedReason = 4104,
    OguryBidTokenErrorCodeWebviewTerminatedBySystem = 4200
};
