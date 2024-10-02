//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryRewardedAdDelegateDispatcher.h"
#import "OguryRewardedAd.h"
#import "OGALog.h"

@implementation OguryRewardedAdDelegateDispatcher

- (void)clicked {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad clicked called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryRewardedAdDidClick:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate oguryRewardedAdDidClick:self.rewardedAd];
        }];
    }
}

- (void)closed {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad closed called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryRewardedAdDidClose:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate oguryRewardedAdDidClose:self.rewardedAd];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryAdError *)error {
    [self.log logErrorFormat:error format:@"[%@][%@] callback ad failed with error called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryRewardedAd:didFailWithError:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate oguryRewardedAd:self.rewardedAd didFailWithError:error];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad loaded called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryRewardedAdDidLoad:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate oguryRewardedAdDidLoad:self.rewardedAd];
        }];
    }
}

- (void)rewarded:(OguryRewardItem *)item {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad rewarded with item[%@]x%@ called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId, item.rewardName, item.rewardValue];

    if ([self.delegate respondsToSelector:@selector(oguryRewardedAd:didReceiveReward:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate oguryRewardedAd:self.rewardedAd didReceiveReward:item];
        }];
    }
}

- (void)adImpression {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad impression called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryRewardedAdDidTriggerImpression:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate oguryRewardedAdDidTriggerImpression:self.rewardedAd];
        }];
    }
}

@end
