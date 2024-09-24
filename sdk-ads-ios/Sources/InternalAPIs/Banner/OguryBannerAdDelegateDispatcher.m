//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OguryBannerAdDelegateDispatcher.h"
#import "OguryBannerAd.h"
#import "OGALog.h"

@implementation OguryBannerAdDelegateDispatcher

- (void)clicked {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] callback ad clicked called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didClickOguryBannerAd:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didClickOguryBannerAd:self.banner];
        }];
    }
}

- (void)closed {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] callback ad closed called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didCloseOguryBannerAd:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didCloseOguryBannerAd:self.banner];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryAdError *)error {
    [self.log logErrorFormat:error format:@"[banner][%@] calldback failed with error called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didFailOguryBannerAdWithError:forAd:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didFailOguryBannerAdWithError:error forAd:self.banner];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] calldback ad loaded called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didLoadOguryBannerAd:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didLoadOguryBannerAd:self.banner];
        }];
    }
}

- (void)adImpression {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] calldback ad impression called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didTriggerImpressionOguryBannerAd:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didTriggerImpressionOguryBannerAd:self.banner];
        }];
    }
}

- (UIViewController *)bannerViewController {
    if ([self.delegate respondsToSelector:@selector(presentingViewControllerForOguryAdsBannerAd:)]) {
        return [self.delegate presentingViewControllerForOguryAdsBannerAd:self.banner];
    }
    return nil;
}

@end
