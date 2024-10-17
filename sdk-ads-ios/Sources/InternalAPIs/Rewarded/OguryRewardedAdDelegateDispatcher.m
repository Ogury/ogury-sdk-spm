//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryRewardedAdDelegateDispatcher.h"
#import "OguryRewardedAd.h"
#import "OGALog.h"

@implementation OguryRewardedAdDelegateDispatcher

- (void)clicked {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Rewarded] Ad clicked"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.rewardedAd.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(rewardedAdDidClick:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate rewardedAdDidClick:self.rewardedAd];
        }];
    }
}

- (void)closed {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Rewarded] Ad closed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.rewardedAd.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(rewardedAdDidClose:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate rewardedAdDidClose:self.rewardedAd];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryAdError *)error {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                   error:error
                                                 message:@"[Rewarded] Ad failed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.rewardedAd.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(rewardedAd:didFailWithError:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate rewardedAd:self.rewardedAd didFailWithError:error];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Rewarded] Ad loaded"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.rewardedAd.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(rewardedAdDidLoad:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate rewardedAdDidLoad:self.rewardedAd];
        }];
    }
}

- (void)rewarded:(OguryReward *)reward {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Rewarded] reward received"
                                                    tags:@[
                                                        [OguryLogTag tagWithKey:@"AdUnitId"
                                                                          value:self.rewardedAd.adUnitId],
                                                        [OguryLogTag tagWithKey:@"Item"
                                                                          value:[NSString stringWithFormat:@"name: %@, value:%@", reward.rewardName, reward.rewardValue]]
                                                    ]]];

    if ([self.delegate respondsToSelector:@selector(rewardedAd:didReceiveReward:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate rewardedAd:self.rewardedAd didReceiveReward:reward];
        }];
    }
}

- (void)adImpression {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Rewarded] Ad impression"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.rewardedAd.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(rewardedAdDidTriggerImpression:)] && self.rewardedAd != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate rewardedAdDidTriggerImpression:self.rewardedAd];
        }];
    }
}

@end
