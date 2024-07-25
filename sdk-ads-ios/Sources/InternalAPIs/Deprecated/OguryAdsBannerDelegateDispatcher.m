//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OguryAdsBannerDelegateDispatcher.h"

@implementation OguryAdsBannerDelegateDispatcher

- (void)clicked {
    if ([self.delegate respondsToSelector:@selector(oguryAdsBannerAdClicked:)]) {
        [self dispatch:^(id<OguryAdsBannerDelegate> _Nonnull delegate) {
            [delegate oguryAdsBannerAdClicked:self.banner];
        }];
    }
}

- (void)closed {
    if ([self.delegate respondsToSelector:@selector(oguryAdsBannerAdClosed:)]) {
        [self dispatch:^(id<OguryAdsBannerDelegate> _Nonnull delegate) {
            [delegate oguryAdsBannerAdClosed:self.banner];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)displayed {
    if (!self.hasSentDisplayedDelegate) {
        if ([self.delegate respondsToSelector:@selector(oguryAdsBannerAdDisplayed:)]) {
            [self dispatch:^(id<OguryAdsBannerDelegate> _Nonnull delegate) {
                [delegate oguryAdsBannerAdDisplayed:self.banner];
            }];
        }
        self.hasSentDisplayedDelegate = YES;
    }
}

- (void)failedWithError:(OguryError *)error {
    switch (error.code) {
        case OguryAdsNotLoadedError:
            if ([self.delegate respondsToSelector:@selector(oguryAdsBannerAdError:forBanner:)]) {
                [self dispatch:^(id<OguryAdsBannerDelegate> _Nonnull delegate) {
                    [delegate oguryAdsBannerAdNotLoaded:self.banner];
                }];
            }
            break;
        case OguryAdsNotAvailableError:
            if ([self.delegate respondsToSelector:@selector(oguryAdsBannerAdNotAvailable:)]) {
                [self dispatch:^(id<OguryAdsBannerDelegate> _Nonnull delegate) {
                    [delegate oguryAdsBannerAdNotAvailable:self.banner];
                }];
            }
            break;
        default:
            if ([self.delegate respondsToSelector:@selector(oguryAdsBannerAdError:forBanner:)]) {
                [self dispatch:^(id<OguryAdsBannerDelegate> _Nonnull delegate) {
                    [delegate oguryAdsBannerAdError:[OguryError getOldErrorTypeWith:error.code] forBanner:self.banner];
                }];
            }
            break;
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    if ([self.delegate respondsToSelector:@selector(oguryAdsBannerAdLoaded:)]) {
        [self dispatch:^(id<OguryAdsBannerDelegate> _Nonnull delegate) {
            [delegate oguryAdsBannerAdLoaded:self.banner];
        }];
    }
}

- (void)adImpression {
    if ([self.delegate respondsToSelector:@selector(oguryAdsBannerAdOnAdImpression)]) {
        [self dispatch:^(id<OguryAdsBannerDelegate> _Nonnull delegate) {
            [delegate oguryAdsBannerAdOnAdImpression];
        }];
    }
}

- (UIViewController *)bannerViewController {
    if ([self.delegate respondsToSelector:@selector(oguryAdsBannerAdPresentingViewController:)]) {
        return [self.delegate oguryAdsBannerAdPresentingViewController:self.banner];
    }
    return nil;
}

@end
