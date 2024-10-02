//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OguryBannerAdViewDelegateDispatcher.h"
#import "OguryBannerAdView.h"
#import "OGALog.h"

@implementation OguryBannerAdViewDelegateDispatcher

- (void)clicked {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] callback ad clicked called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryBannerAdViewDidClick:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate oguryBannerAdViewDidClick:self.banner];
        }];
    }
}

- (void)closed {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] callback ad closed called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryBannerAdViewDidClose:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate oguryBannerAdViewDidClose:self.banner];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryAdError *)error {
    [self.log logErrorFormat:error format:@"[banner][%@] calldback failed with error called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryBannerAdView:didFailWithError:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate oguryBannerAdView:self.banner didFailWithError:error];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] calldback ad loaded called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryBannerAdViewDidLoad:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate oguryBannerAdViewDidLoad:self.banner];
        }];
    }
}

- (void)adImpression {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] calldback ad impression called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryBannerAdViewDidTriggerImpression:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate oguryBannerAdViewDidTriggerImpression:self.banner];
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
