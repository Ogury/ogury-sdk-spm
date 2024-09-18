#import <Foundation/Foundation.h>

#import "OguryInterstitialAd.h"
#import "OguryRewardedAd.h"
#import "OguryBannerAd.h"
#import "OguryThumbnailAd.h"
#import "OGARewardItem.h"
#import "OguryTokenService.h"
#import "OguryAdsError.h"

typedef void (^SetupCompletionBlock)(BOOL success, NSError *error);

@interface OguryAds : NSObject

+ (instancetype)shared;

@end
