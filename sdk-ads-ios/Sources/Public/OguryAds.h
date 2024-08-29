#import <Foundation/Foundation.h>

#import "OguryInterstitialAd.h"
#import "OguryRewardedAd.h"
#import "OguryBannerAd.h"
#import "OguryThumbnailAd.h"
#import "OGARewardItem.h"
#import "OguryTokenService.h"
#import "OguryAdsError.h"

typedef void (^SetUpCompletionBlock)(BOOL success, NSError *error);

@interface OguryAds : NSObject

+ (instancetype)shared;

- (void)setupWithAssetKey:(NSString *)assetKey;

- (void)setupWithAssetKey:(NSString *)assetKey completionHandler:(SetUpCompletionBlock)completionHandler;

@end
