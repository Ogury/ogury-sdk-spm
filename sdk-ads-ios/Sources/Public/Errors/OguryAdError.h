//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <OguryCore/OguryError.h>

typedef NS_ENUM(NSInteger, OguryAdErrorType) {
    OguryAdErrorTypeLoad = 0,
    OguryAdErrorTypeShow
};

@interface OguryAdError : OguryError
@property(nonatomic) OguryAdErrorType type;
@end

typedef NS_ENUM(NSInteger, OguryAdErrorCode) {
    OguryAdErrorCodeSDKNotInitialized = 2000,
    OguryAdErrorCodeSDKNotProperlyInitialized = 2001,
    OguryAdErrorCodeNoInternetConnection = 2002,
    OguryAdErrorCodeInvalidConfiguration = 2100,
    OguryAdErrorCodeAdDisabledUnopenedCountry = 2101,
    OguryAdErrorCodeAdDisabledConsentDenied = 2102,
    OguryAdErrorCodeAdDisabledConsentMissing = 2103,
    OguryAdErrorCodeAdDisabledOtherReason = 2104,
    OguryAdErrorCodeAdRequestFailed = 2200,
    OguryAdErrorCodeNoFill = 2201,
    OguryAdErrorCodeAdParsingFailed = 2202,
    OguryAdErrorCodeAdPrecachingFailed = 2300,
    OguryAdErrorCodeAdPrecachingTimeout = 2301,
    OguryAdErrorCodeAdExpired = 2400,
    OguryAdErrorCodeNoAdLoaded = 2401,
    OguryAdErrorCodeViewInBackground = 2402,
    OguryAdErrorCodeAnotherAdIsAlreadyDisplayed = 2403,
    OguryAdErrorCodeWebviewTerminatedBySystem = 2404,
    OguryAdErrorCodeViewControllerPreventsAdFromBeingDisplayed = 2405,
    OguryAdErrorCodeHeaderBidding = 2500
};
