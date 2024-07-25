//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OguryAdsInterstitialDelegateDispatcher.h"

@implementation OguryAdsInterstitialDelegateDispatcher

- (void)clicked {
    if ([self.delegate respondsToSelector:@selector(oguryAdsInterstitialAdClicked)]) {
        [self dispatch:^(id<OguryAdsInterstitialDelegate> _Nonnull delegate) {
            [delegate oguryAdsInterstitialAdClicked];
        }];
    }
}

- (void)closed {
    if ([self.delegate respondsToSelector:@selector(oguryAdsInterstitialAdClosed)]) {
        [self dispatch:^(id<OguryAdsInterstitialDelegate> _Nonnull delegate) {
            [delegate oguryAdsInterstitialAdClosed];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)displayed {
    if (!self.hasSentDisplayedDelegate) {
        if ([self.delegate respondsToSelector:@selector(oguryAdsInterstitialAdDisplayed)]) {
            [self dispatch:^(id<OguryAdsInterstitialDelegate> _Nonnull delegate) {
                [delegate oguryAdsInterstitialAdDisplayed];
            }];
        }
        self.hasSentDisplayedDelegate = YES;
    }
}

- (void)failedWithError:(OguryError *)error {
    switch (error.code) {
        case OguryAdsNotLoadedError:
            if ([self.delegate respondsToSelector:@selector(oguryAdsInterstitialAdNotLoaded)]) {
                [self dispatch:^(id<OguryAdsInterstitialDelegate> _Nonnull delegate) {
                    [delegate oguryAdsInterstitialAdNotLoaded];
                }];
            }
            break;
        case OguryAdsNotAvailableError:
            if ([self.delegate respondsToSelector:@selector(oguryAdsInterstitialAdNotAvailable)]) {
                [self dispatch:^(id<OguryAdsInterstitialDelegate> _Nonnull delegate) {
                    [delegate oguryAdsInterstitialAdNotAvailable];
                }];
            }
            break;
        default:
            if ([self.delegate respondsToSelector:@selector(oguryAdsInterstitialAdError:)]) {
                [self dispatch:^(id<OguryAdsInterstitialDelegate> _Nonnull delegate) {
                    [delegate oguryAdsInterstitialAdError:[OguryError getOldErrorTypeWith:error.code]];
                }];
            }
            break;
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    if ([self.delegate respondsToSelector:@selector(oguryAdsInterstitialAdLoaded)]) {
        [self dispatch:^(id<OguryAdsInterstitialDelegate> _Nonnull delegate) {
            [delegate oguryAdsInterstitialAdLoaded];
        }];
    }
}

- (void)adImpression {
    if ([self.delegate respondsToSelector:@selector(oguryAdsInterstitialAdOnAdImpression)]) {
        [self dispatch:^(id<OguryAdsInterstitialDelegate> _Nonnull delegate) {
            [delegate oguryAdsInterstitialAdOnAdImpression];
        }];
    }
}

@end
