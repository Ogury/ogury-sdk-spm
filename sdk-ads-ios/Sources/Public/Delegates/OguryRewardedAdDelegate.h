//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryReward.h"
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@class OguryRewardedAd;

@protocol OguryRewardedAdDelegate <NSObject>
@optional
- (void)rewardedAdDidLoad:(OguryRewardedAd *)rewardedAd NS_SWIFT_NAME(rewardedAdDidLoad(_:));
- (void)rewardedAdDidClick:(OguryRewardedAd *)rewardedAd NS_SWIFT_NAME(rewardedAdDidClick(_:));
- (void)rewardedAdDidClose:(OguryRewardedAd *)rewardedAd NS_SWIFT_NAME(rewardedAdDidClose(_:));
- (void)rewardedAd:(OguryRewardedAd *)rewardedAd didReceiveReward:(OguryReward *)reward NS_SWIFT_NAME(rewardedAd(_:didReceive:));
- (void)rewardedAd:(OguryRewardedAd *)rewardedAd didFailWithError:(OguryAdError *)error NS_SWIFT_NAME(rewardedAd(_:didFailWithError:));
- (void)rewardedAdDidTriggerImpression:(OguryRewardedAd *)rewardedAd NS_SWIFT_NAME(rewardedAdDidTriggerImpression(_:));
@end

NS_ASSUME_NONNULL_END
