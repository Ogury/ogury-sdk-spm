#import "OGARewardItem.h"
#import <UIKit/UIKit.h>

@class OguryAdsBanner;

typedef NS_ENUM(NSInteger, OguryAdsLegacyErrorType) {
    OguryAdsErrorTypeLoadFailed = 0,
    OguryAdsErrorTypeNoInternetConnection = 1,
    OguryAdsErrorTypeAdDisable = 2,
    OguryAdsErrorTypeProfigNotSynced = 3,
    OguryAdsErrorTypeAdExpired = 4,
    OguryAdsErrorTypeSdkInitNotCalled = 5,
    OguryAdsErrorTypeAnotherAdAlreadyDisplayed = 6,
    OguryAdsErrorTypeCantShowAdsInPresentingViewController = 7,
    OguryAdsErrorTypeUnknown = 8
};
