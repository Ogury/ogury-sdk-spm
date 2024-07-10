//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OguryAdsOptinVideoDelegateDispatcher.h"
#import "OguryError+Ads.h"

@implementation OguryAdsOptinVideoDelegateDispatcher

- (void)rewarded:(OGARewardItem *)item {
    if ([self.delegate respondsToSelector:@selector(oguryAdsOptinVideoAdRewarded:)]) {
        [self dispatch:^(id<OguryAdsOptinVideoDelegate> _Nonnull delegate) {
            [delegate oguryAdsOptinVideoAdRewarded:item];
        }];
    }
}

- (void)clicked {
    if ([self.delegate respondsToSelector:@selector(oguryAdsOptinVideoAdClicked)]) {
        [self dispatch:^(id<OguryAdsOptinVideoDelegate> _Nonnull delegate) {
            [delegate oguryAdsOptinVideoAdClicked];
        }];
    }
}

- (void)closed {
    if ([self.delegate respondsToSelector:@selector(oguryAdsOptinVideoAdClosed)]) {
        [self dispatch:^(id<OguryAdsOptinVideoDelegate> _Nonnull delegate) {
            [delegate oguryAdsOptinVideoAdClosed];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)displayed {
    if (!self.hasSentDisplayedDelegate) {
        if ([self.delegate respondsToSelector:@selector(oguryAdsOptinVideoAdDisplayed)]) {
            [self dispatch:^(id<OguryAdsOptinVideoDelegate> _Nonnull delegate) {
                [delegate oguryAdsOptinVideoAdDisplayed];
            }];
        }
        self.hasSentDisplayedDelegate = YES;
    }
}

- (void)failedWithError:(OguryError *)error {
    switch (error.code) {
        case OguryAdsNotLoadedError:
            if ([self.delegate respondsToSelector:@selector(oguryAdsOptinVideoAdNotLoaded)]) {
                [self dispatch:^(id<OguryAdsOptinVideoDelegate> _Nonnull delegate) {
                    [delegate oguryAdsOptinVideoAdNotLoaded];
                }];
            }
            break;
        case OguryAdsNotAvailableError:
            if ([self.delegate respondsToSelector:@selector(oguryAdsOptinVideoAdNotAvailable)]) {
                [self dispatch:^(id<OguryAdsOptinVideoDelegate> _Nonnull delegate) {
                    [delegate oguryAdsOptinVideoAdNotAvailable];
                }];
            }
            break;
        default:
            if ([self.delegate respondsToSelector:@selector(oguryAdsOptinVideoAdError:)]) {
                [self dispatch:^(id<OguryAdsOptinVideoDelegate> _Nonnull delegate) {
                    [delegate oguryAdsOptinVideoAdError:[OguryError getOldErrorTypeWith:error.code]];
                }];
            }
            break;
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    if ([self.delegate respondsToSelector:@selector(oguryAdsOptinVideoAdLoaded)]) {
        [self dispatch:^(id<OguryAdsOptinVideoDelegate> _Nonnull delegate) {
            [delegate oguryAdsOptinVideoAdLoaded];
        }];
    }
}

- (void)adImpression {
    if ([self.delegate respondsToSelector:@selector(oguryAdsOptinVideoAdOnAdImpression)]) {
        [self dispatch:^(id<OguryAdsOptinVideoDelegate> _Nonnull delegate) {
            [delegate oguryAdsOptinVideoAdOnAdImpression];
        }];
    }
}

@end
