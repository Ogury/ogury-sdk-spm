//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OguryBannerAdViewDelegateDispatcher.h"
#import "OguryBannerAdView.h"
#import "OGALog.h"

@implementation OguryBannerAdViewDelegateDispatcher

- (void)clicked {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] callback ad clicked called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didClickOguryBannerAdView:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didClickOguryBannerAdView:self.banner];
        }];
    }
}

- (void)closed {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] callback ad closed called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didCloseOguryBannerAdView:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didCloseOguryBannerAdView:self.banner];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryAdError *)error {
    [self.log logErrorFormat:error format:@"[banner][%@] calldback failed with error called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didFailOguryBannerAdView:error:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didFailOguryBannerAdView:self.banner error:error];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] calldback ad loaded called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didLoadOguryBannerAdView:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didLoadOguryBannerAdView:self.banner];
        }];
    }
}

- (void)adImpression {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] calldback ad impression called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didTriggerImpressionOguryBannerAdView:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didTriggerImpressionOguryBannerAdView:self.banner];
        }];
    }
}

- (UIViewController *)bannerViewController {
    if ([self.delegate respondsToSelector:@selector(presentingViewControllerForOguryAdsBannerAdView:)]) {
        return [self.delegate presentingViewControllerForOguryAdsBannerAdView:self.banner];
    }
    return nil;
}

@end
