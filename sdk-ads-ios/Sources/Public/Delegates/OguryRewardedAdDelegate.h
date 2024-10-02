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
- (void)oguryRewardedAdDidLoad:(OguryRewardedAd *)rewardedAd;
- (void)oguryRewardedAdDidClick:(OguryRewardedAd *)rewardedAd;
- (void)oguryRewardedAdDidClose:(OguryRewardedAd *)rewardedAd;
- (void)oguryRewardedAd:(OguryRewardedAd *)rewardedAd didReceiveReward:(OguryRewardItem *)item;
- (void)oguryRewardedAd:(OguryRewardedAd *)rewardedAd didFailWithError:(OguryAdError *)error;
- (void)oguryRewardedAdDidTriggerImpression:(OguryRewardedAd *)rewardedAd;
@end

NS_ASSUME_NONNULL_END
