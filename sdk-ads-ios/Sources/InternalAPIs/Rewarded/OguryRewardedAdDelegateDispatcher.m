//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryRewardedAdDelegateDispatcher.h"
#import "OguryRewardedAd.h"
#import "OGALog.h"

@implementation OguryRewardedAdDelegateDispatcher

- (void)clicked {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad clicked called", OGAAdConfigurationAdTypeRewarded, self.optinVideo.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didClickOguryRewardedAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didClickOguryRewardedAd:self.optinVideo];
        }];
    }
}

- (void)closed {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad closed called", OGAAdConfigurationAdTypeRewarded, self.optinVideo.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didCloseOguryRewardedAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didCloseOguryRewardedAd:self.optinVideo];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryError *)error {
    [self.log logErrorFormat:error format:@"[%@][%@] callback ad failed with error called", OGAAdConfigurationAdTypeRewarded, self.optinVideo.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didFailOguryRewardedAdWithError:forAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didFailOguryRewardedAdWithError:error forAd:self.optinVideo];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad loaded called", OGAAdConfigurationAdTypeRewarded, self.optinVideo.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didLoadOguryRewardedAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didLoadOguryRewardedAd:self.optinVideo];
        }];
    }
}

- (void)rewarded:(OGARewardItem *)item {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad rewarded with item[%@]x%@ called", OGAAdConfigurationAdTypeRewarded, self.optinVideo.adUnitId, item.rewardName, item.rewardValue];

    if ([self.delegate respondsToSelector:@selector(didRewardOguryRewardedAdWithItem:forAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didRewardOguryRewardedAdWithItem:item forAd:self.optinVideo];
        }];
    }
}

- (void)adImpression {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad impression called", OGAAdConfigurationAdTypeRewarded, self.optinVideo.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didTriggerImpressionOguryRewardedAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didTriggerImpressionOguryRewardedAd:self.optinVideo];
        }];
    }
}

@end
