//
//  OguryShowErrorCode.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 01/10/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

typedef NS_ENUM(NSInteger, OguryShowErrorCode) {
    OguryShowErrorCodeSDKNotStarted = 3000,
    OguryShowErrorCodeSDKNotProperlyInitialized = 3001,
    OguryShowErrorCodeNoActiveInternetConnection = 3002,
    OguryShowErrorCodeInvalidConfiguration = 3100,
    OguryShowErrorCodeAdDisabledCountryNotOpened = 3101,
    OguryShowErrorCodeAdDisabledConsentDenied = 3102,
    OguryShowErrorCodeAdDisabledConsentMissing = 3103,
    OguryShowErrorCodeAdDisabledUnspecifiedReason = 3104,
    OguryShowErrorCodeAdExpired = 3200,
    OguryShowErrorCodeNoAdLoaded = 3201,
    OguryShowErrorCodeViewInBackground = 3202,
    OguryShowErrorCodeAnotherAdAlreadyDisplayed = 3203,
    OguryShowErrorCodeWebviewTerminatedBySystem = 3204,
    OguryShowErrorCodeViewControllerPreventsAdFromBeingDisplayed = 3205
};
