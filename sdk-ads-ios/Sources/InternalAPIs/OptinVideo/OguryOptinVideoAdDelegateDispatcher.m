//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryOptinVideoAdDelegateDispatcher.h"
#import "OguryOptinVideoAd.h"
#import "OGALog.h"

@implementation OguryOptinVideoAdDelegateDispatcher

- (void)clicked {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad clicked called", OGAAdConfigurationAdTypeOptinVideo, self.optinVideo.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didClickOguryOptinVideoAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryOptinVideoAdDelegate> _Nonnull delegate) {
            [delegate didClickOguryOptinVideoAd:self.optinVideo];
        }];
    }
}

- (void)closed {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad closed called", OGAAdConfigurationAdTypeOptinVideo, self.optinVideo.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didCloseOguryOptinVideoAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryOptinVideoAdDelegate> _Nonnull delegate) {
            [delegate didCloseOguryOptinVideoAd:self.optinVideo];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)displayed {
    if (!self.hasSentDisplayedDelegate) {
        [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad displayed called", OGAAdConfigurationAdTypeOptinVideo, self.optinVideo.adUnitId];

        if ([self.delegate respondsToSelector:@selector(didDisplayOguryOptinVideoAd:)] && self.optinVideo != nil) {
            [self dispatch:^(id<OguryOptinVideoAdDelegate> _Nonnull delegate) {
                [delegate didDisplayOguryOptinVideoAd:self.optinVideo];
            }];
        }
        self.hasSentDisplayedDelegate = YES;
    }
}

- (void)failedWithError:(OguryError *)error {
    [self.log logErrorFormat:error format:@"[%@][%@] callback ad failed with error called", OGAAdConfigurationAdTypeOptinVideo, self.optinVideo.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didFailOguryOptinVideoAdWithError:forAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryOptinVideoAdDelegate> _Nonnull delegate) {
            [delegate didFailOguryOptinVideoAdWithError:error forAd:self.optinVideo];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad loaded called", OGAAdConfigurationAdTypeOptinVideo, self.optinVideo.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didLoadOguryOptinVideoAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryOptinVideoAdDelegate> _Nonnull delegate) {
            [delegate didLoadOguryOptinVideoAd:self.optinVideo];
        }];
    }
}

- (void)rewarded:(OGARewardItem *)item {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad rewarded with item[%@]x%@ called", OGAAdConfigurationAdTypeOptinVideo, self.optinVideo.adUnitId, item.rewardName, item.rewardValue];

    if ([self.delegate respondsToSelector:@selector(didRewardOguryOptinVideoAdWithItem:forAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryOptinVideoAdDelegate> _Nonnull delegate) {
            [delegate didRewardOguryOptinVideoAdWithItem:item forAd:self.optinVideo];
        }];
    }
}

- (void)adImpression {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad impression called", OGAAdConfigurationAdTypeOptinVideo, self.optinVideo.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didTriggerImpressionOguryOptinVideoAd:)] && self.optinVideo != nil) {
        [self dispatch:^(id<OguryOptinVideoAdDelegate> _Nonnull delegate) {
            [delegate didTriggerImpressionOguryOptinVideoAd:self.optinVideo];
        }];
    }
}

@end
