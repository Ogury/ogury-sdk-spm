//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryRewardedAdDelegateDispatcher.h"
#import "OguryRewardedAd.h"
#import "OGALog.h"

@implementation OguryRewardedAdDelegateDispatcher

- (void)clicked {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad clicked called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didClickOguryRewardedAd:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didClickOguryRewardedAd:self.rewardedAd];
        }];
    }
}

- (void)closed {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad closed called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didCloseOguryRewardedAd:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didCloseOguryRewardedAd:self.rewardedAd];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryError *)error {
    [self.log logErrorFormat:error format:@"[%@][%@] callback ad failed with error called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didFailOguryRewardedAdWithError:forAd:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didFailOguryRewardedAdWithError:error forAd:self.rewardedAd];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad loaded called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didLoadOguryRewardedAd:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didLoadOguryRewardedAd:self.rewardedAd];
        }];
    }
}

- (void)rewarded:(OguryRewardItem *)item {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad rewarded with item[%@]x%@ called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId, item.rewardName, item.rewardValue];

    if ([self.delegate respondsToSelector:@selector(didRewardOguryRewardedAdWithItem:forAd:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didRewardOguryRewardedAdWithItem:item forAd:self.rewardedAd];
        }];
    }
}

- (void)adImpression {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad impression called", OGAAdConfigurationAdTypeRewarded, self.rewardedAd.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didTriggerImpressionOguryRewardedAd:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didTriggerImpressionOguryRewardedAd:self.rewardedAd];
        }];
    }
}

@end
