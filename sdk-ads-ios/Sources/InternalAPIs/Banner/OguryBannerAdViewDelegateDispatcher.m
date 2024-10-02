//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OguryBannerAdViewDelegateDispatcher.h"
#import "OguryBannerAdView.h"
#import "OGALog.h"

@implementation OguryBannerAdViewDelegateDispatcher

- (void)clicked {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] callback ad clicked called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(bannerAdViewDidClick:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate bannerAdViewDidClick:self.banner];
        }];
    }
}

- (void)closed {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] callback ad closed called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(bannerAdViewDidClose:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate bannerAdViewDidClose:self.banner];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryAdError *)error {
    [self.log logErrorFormat:error format:@"[banner][%@] calldback failed with error called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(bannerAdView:didFailWithError:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate bannerAdView:self.banner didFailWithError:error];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] calldback ad loaded called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(bannerAdViewDidLoad:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate bannerAdViewDidLoad:self.banner];
        }];
    }
}

- (void)adImpression {
    [self.log logFormat:OguryLogLevelInfo format:@"[banner][%@] calldback ad impression called", self.banner.adUnitId];

    if ([self.delegate respondsToSelector:@selector(bannerAdViewDidTriggerImpression:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate bannerAdViewDidTriggerImpression:self.banner];
        }];
    }
}

- (UIViewController *)bannerViewController {
    if ([self.delegate respondsToSelector:@selector(presentingViewControllerForBannerAdView:)]) {
        return [self.delegate presentingViewControllerForBannerAdView:self.banner];
    }
    return nil;
}

@end
