//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryRewardedAdDelegateDispatcher.h"
#import "OguryRewardedAd.h"
#import "OGALog.h"

@implementation OguryRewardedAdDelegateDispatcher

- (void)clicked {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad clicked called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(rewardedAdDidClick:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate rewardedAdDidClick:self.rewardedAd];
        }];
    }
}

- (void)closed {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad closed called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(rewardedAdDidClose:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate rewardedAdDidClose:self.rewardedAd];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryAdError *)error {
    [self.log logErrorFormat:error format:@"[%@][%@] callback ad failed with error called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(rewardedAd:didFailWithError:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate rewardedAd:self.rewardedAd didFailWithError:error];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad loaded called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(rewardedAdDidLoad:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate rewardedAdDidLoad:self.rewardedAd];
        }];
    }
}

- (void)rewarded:(OguryReward *)reward {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad rewarded with item[%@]x%@ called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId, reward.rewardName, reward.rewardValue];

    if ([self.delegate respondsToSelector:@selector(rewardedAd:didReceiveReward:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate rewardedAd:self.rewardedAd didReceiveReward:reward];
        }];
    }
}

- (void)adImpression {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad impression called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(rewardedAdDidTriggerImpression:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate rewardedAdDidTriggerImpression:self.rewardedAd];
        }];
    }
}

@end
