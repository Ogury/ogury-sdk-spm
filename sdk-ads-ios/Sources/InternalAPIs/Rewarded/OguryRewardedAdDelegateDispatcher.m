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
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.optinVideo.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didClickOguryRewardedAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didClickOguryRewardedAd:self.optinVideo];
        }];
    }
}

- (void)closed {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Rewarded] Ad closed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.optinVideo.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didCloseOguryRewardedAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didCloseOguryRewardedAd:self.optinVideo];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryError *)error {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                   error:error
                                                 message:@"[Rewarded] Ad failed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.optinVideo.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didFailOguryRewardedAdWithError:forAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didFailOguryRewardedAdWithError:error forAd:self.optinVideo];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Rewarded] Ad loaded"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.optinVideo.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didLoadOguryRewardedAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didLoadOguryRewardedAd:self.optinVideo];
        }];
    }
}

- (void)rewarded:(OGARewardItem *)item {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Rewarded] reward received"
                                                    tags:@[
                                                        [OguryLogTag tagWithKey:@"AdUnitId"
                                                                          value:self.optinVideo.adUnitId],
                                                        [OguryLogTag tagWithKey:@"Item"
                                                                          value:[NSString stringWithFormat:@"name: %@, value:%@", item.rewardName, item.rewardValue]]
                                                    ]]];

    if ([self.delegate respondsToSelector:@selector(didRewardOguryRewardedAdWithItem:forAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didRewardOguryRewardedAdWithItem:item forAd:self.optinVideo];
        }];
    }
}

- (void)adImpression {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Rewarded] Ad impression"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.optinVideo.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didTriggerImpressionOguryRewardedAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryRewardedAdDelegate> _Nonnull delegate) {
            [delegate didTriggerImpressionOguryRewardedAd:self.optinVideo];
        }];
    }
}

@end
