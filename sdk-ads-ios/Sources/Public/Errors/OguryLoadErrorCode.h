//
//  OguryLoadErrorCode.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 01/10/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

typedef NS_ENUM(NSInteger, OguryLoadErrorCode) {
    OguryLoadErrorCodeSDKNotStarted = 2000,
    OguryLoadErrorCodeSDKNotProperlyInitialized = 2001,
    OguryLoadErrorCodeNoActiveInternetConnection = 2002,
    OguryLoadErrorCodeInvalidConfiguration = 2100,
    OguryLoadErrorCodeAdDisabledCountryNotOpened = 2101,
    OguryLoadErrorCodeAdDisabledConsentDenied = 2102,
    OguryLoadErrorCodeAdDisabledConsentMissing = 2103,
    OguryLoadErrorCodeAdDisabledUnspecifiedReason = 2104,
    OguryLoadErrorCodeAdRequestFailed = 2200,
    OguryLoadErrorCodeNoFill = 2201,
    OguryLoadErrorCodeAdParsingFailed = 2202,
    OguryLoadErrorCodeAdPrecachingFailed = 2300,
    OguryLoadErrorCodeAdPrecachingTimeout = 2301
};
