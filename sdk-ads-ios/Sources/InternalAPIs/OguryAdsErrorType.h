#import "OGARewardItem.h"
#import <UIKit/UIKit.h>

@class OguryAdsBanner;

typedef NS_ENUM(NSInteger, OguryAdsErrorType) {
    OguryAdsErrorLoadFailed = 0,
    OguryAdsErrorNoInternetConnection = 1,
    OguryAdsErrorAdDisable = 2,
    OguryAdsErrorProfigNotSynced = 3,
    OguryAdsErrorAdExpired = 4,
    OguryAdsErrorSdkInitNotCalled = 5,
    OguryAdsErrorAnotherAdAlreadyDisplayed = 6,
    OguryAdsErrorCantShowAdsInPresentingViewController = 7,
    OguryAdsErrorUnknown = 8
};
