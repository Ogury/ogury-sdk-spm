//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryRewardItem.h"
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@class OguryRewardedAd;

@protocol OguryRewardedAdDelegate <NSObject>
@optional
- (void)didLoadOguryRewardedAd:(OguryRewardedAd *)rewardedAd;
- (void)didClickOguryRewardedAd:(OguryRewardedAd *)rewardedAd;
- (void)didCloseOguryRewardedAd:(OguryRewardedAd *)rewardedAd;
- (void)didRewardOguryRewardedAdWithItem:(OguryRewardItem *)item forAd:(OguryRewardedAd *)rewardedAd;
- (void)didFailOguryRewardedAdWithError:(OguryAdError *)error forAd:(OguryRewardedAd *)rewardedAd;
- (void)didTriggerImpressionOguryRewardedAd:(OguryRewardedAd *)rewardedAd;
@end

NS_ASSUME_NONNULL_END
