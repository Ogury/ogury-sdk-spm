//
//  OguryAdErrorCode.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 01/10/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

typedef NS_ENUM(NSInteger, OguryAdErrorCode) {
    OguryAdErrorCodeSDKStartNotCalled = 2000,
    OguryAdErrorCodeSDKNotProperlyInitialized = 2001,
    OguryAdErrorCodeNoActiveInternetConnection = 2002,
    OguryAdErrorCodeInvalidConfiguration = 2100,
    OguryAdErrorCodeAdDisabledCountryNotOpened = 2101,
    OguryAdErrorCodeAdDisabledConsentDenied = 2102,
    OguryAdErrorCodeAdDisabledConsentMissing = 2103,
    OguryAdErrorCodeAdDisabledUnspecifiedReason = 2104,
    OguryAdErrorCodeAdRequestFailed = 2200,
    OguryAdErrorCodeNoFill = 2201,
    OguryAdErrorCodeAdParsingFailed = 2202,
    OguryAdErrorCodeAdPrecachingFailed = 2300,
    OguryAdErrorCodeAdPrecachingTimeout = 2301,
    OguryAdErrorCodeAdExpired = 2400,
    OguryAdErrorCodeNoAdLoaded = 2401,
    OguryAdErrorCodeViewInBackground = 2402,
    OguryAdErrorCodeAnotherAdAlreadyDisplayed = 2403,
    OguryAdErrorCodeWebviewTerminatedBySystem = 2404,
    OguryAdErrorCodeViewControllerPreventsAdFromBeingDisplayed = 2405
};
