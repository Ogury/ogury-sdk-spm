#import <Foundation/Foundation.h>

#import "OguryInterstitialAd.h"
#import "OguryRewardedAd.h"
#import "OguryBannerAd.h"
#import "OguryThumbnailAd.h"
#import "OguryRewardItem.h"
#import "OguryTokenService.h"
#import "OguryAdError.h"

typedef void (^SetupCompletionBlock)(BOOL success, NSError *error);

@interface OguryAds : NSObject

+ (instancetype)shared;

@end
