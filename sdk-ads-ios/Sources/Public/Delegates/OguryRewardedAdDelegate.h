//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryError.h>

#import "OGARewardItem.h"
#import "OguryAdsError.h"

NS_ASSUME_NONNULL_BEGIN

@class OguryRewardedAd;

@protocol OguryRewardedAdDelegate <NSObject>
@optional
- (void)didLoadOguryRewardedAd:(OguryRewardedAd *)optinVideo;
- (void)didClickOguryRewardedAd:(OguryRewardedAd *)optinVideo;
- (void)didCloseOguryRewardedAd:(OguryRewardedAd *)optinVideo;
- (void)didRewardOguryRewardedAdWithItem:(OGARewardItem *)item forAd:(OguryRewardedAd *)optinVideo;
- (void)didFailOguryRewardedAdWithError:(OguryError *)error forAd:(OguryRewardedAd *)optinVideo;
- (void)didTriggerImpressionOguryRewardedAd:(OguryRewardedAd *)optinVideo;
@end

NS_ASSUME_NONNULL_END
