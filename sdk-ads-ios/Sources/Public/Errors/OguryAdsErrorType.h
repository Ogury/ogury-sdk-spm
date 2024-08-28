//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

typedef NS_ENUM(NSInteger, OguryAdsErrorType) {
    OguryAdsErrorTypeSDKNotInitialized = 2000,
    OguryAdsErrorTypeSDKNotProperlyInitialized = 2001,
    OguryAdsErrorTypeNoInternetConnection = 2002,
    OguryAdsErrorTypeInvalidConfiguration = 2003,
    OguryAdsErrorTypeAdDisabledUnopenedCountry = 2004,
    OguryAdsErrorTypeAdDisabledConsentDenied = 2005,
    OguryAdsErrorTypeAdDisabledConsentMissing = 2006,
    OguryAdsErrorTypeAdDisabledOtherReason = 2007,
    OguryAdsErrorTypeAdRequestFailed = 2008,
    OguryAdsErrorTypeNoFill = 2009,
    OguryAdsErrorTypeAdParsingFailed = 2010,
    OguryAdsErrorTypeAdPrecachingFailed = 2011,
    OguryAdsErrorTypeAdPrecachingTimeout = 2012,
    OguryAdsErrorTypeAdExpired = 2013,
    OguryAdsErrorTypeNoAdLoaded = 2014,
    OguryAdsErrorTypeViewInBackground = 2015,
    OguryAdsErrorTypeAnotherAdIsAlreadyDisplayed = 2016,
    OguryAdsErrorTypeWebviewTerminatedBySystem = 2017,
    OguryAdsErrorTypeViewControllerPreventsAdFromBeingDisplayed = 2018
};
