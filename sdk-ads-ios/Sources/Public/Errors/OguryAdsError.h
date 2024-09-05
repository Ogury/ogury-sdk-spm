//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <OguryCore/OguryError.h>

typedef NS_ENUM(NSInteger, OguryInternalAdsErrorOrigin) {
    OguryInternalAdsErrorOriginLoad = 0,
    OguryInternalAdsErrorOriginShow
};

@interface OguryAdsError : OguryError
@property(nonatomic) OguryInternalAdsErrorOrigin origin;
@end

typedef NS_ENUM(NSInteger, OguryAdsErrorType) {
    OguryAdsErrorTypeSDKNotInitialized = 2000,
    OguryAdsErrorTypeSDKNotProperlyInitialized = 2001,
    OguryAdsErrorTypeNoInternetConnection = 2002,
    OguryAdsErrorTypeInvalidConfiguration = 2100,
    OguryAdsErrorTypeAdDisabledUnopenedCountry = 2101,
    OguryAdsErrorTypeAdDisabledConsentDenied = 2102,
    OguryAdsErrorTypeAdDisabledConsentMissing = 2103,
    OguryAdsErrorTypeAdDisabledOtherReason = 2104,
    OguryAdsErrorTypeAdRequestFailed = 2200,
    OguryAdsErrorTypeNoFill = 2201,
    OguryAdsErrorTypeAdParsingFailed = 2202,
    OguryAdsErrorTypeAdPrecachingFailed = 2300,
    OguryAdsErrorTypeAdPrecachingTimeout = 2301,
    OguryAdsErrorTypeAdExpired = 2302,
    OguryAdsErrorTypeNoAdLoaded = 2303,
    OguryAdsErrorTypeViewInBackground = 2400,
    OguryAdsErrorTypeAnotherAdIsAlreadyDisplayed = 2401,
    OguryAdsErrorTypeWebviewTerminatedBySystem = 2402,
    OguryAdsErrorTypeViewControllerPreventsAdFromBeingDisplayed = 2403,
    OguryAdsErrorTypeHeaderBidding = 2500
};
