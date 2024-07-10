//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OguryAdsThumbnailAdDelegateDispatcher.h"

@implementation OguryAdsThumbnailAdDelegateDispatcher

- (void)clicked {
    if ([self.delegate respondsToSelector:@selector(oguryAdsThumbnailAdAdClicked)]) {
        [self dispatch:^(id<OguryAdsThumbnailAdDelegate> _Nonnull delegate) {
            [delegate oguryAdsThumbnailAdAdClicked];
        }];
    }
}

- (void)closed {
    if ([self.delegate respondsToSelector:@selector(oguryAdsThumbnailAdAdClosed)]) {
        [self dispatch:^(id<OguryAdsThumbnailAdDelegate> _Nonnull delegate) {
            [delegate oguryAdsThumbnailAdAdClosed];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)displayed {
    if (!self.hasSentDisplayedDelegate) {
        if ([self.delegate respondsToSelector:@selector(oguryAdsThumbnailAdAdDisplayed)]) {
            [self dispatch:^(id<OguryAdsThumbnailAdDelegate> _Nonnull delegate) {
                [delegate oguryAdsThumbnailAdAdDisplayed];
            }];
        }
        self.hasSentDisplayedDelegate = YES;
    }
}

- (void)failedWithError:(OguryError *)error {
    switch (error.code) {
        case OguryAdsNotLoadedError:
            if ([self.delegate respondsToSelector:@selector(oguryAdsThumbnailAdAdNotLoaded)]) {
                [self dispatch:^(id<OguryAdsThumbnailAdDelegate> _Nonnull delegate) {
                    [delegate oguryAdsThumbnailAdAdNotLoaded];
                }];
            }
            break;
        case OguryAdsNotAvailableError:
            if ([self.delegate respondsToSelector:@selector(oguryAdsThumbnailAdAdNotAvailable)]) {
                [self dispatch:^(id<OguryAdsThumbnailAdDelegate> _Nonnull delegate) {
                    [delegate oguryAdsThumbnailAdAdNotAvailable];
                }];
            }
            break;
        default:
            if ([self.delegate respondsToSelector:@selector(oguryAdsThumbnailAdAdError:)]) {
                [self dispatch:^(id<OguryAdsThumbnailAdDelegate> _Nonnull delegate) {
                    [delegate oguryAdsThumbnailAdAdError:[OguryError getOldErrorTypeWith:error.code]];
                }];
            }
            break;
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    if ([self.delegate respondsToSelector:@selector(oguryAdsThumbnailAdAdLoaded)]) {
        [self dispatch:^(id<OguryAdsThumbnailAdDelegate> _Nonnull delegate) {
            [delegate oguryAdsThumbnailAdAdLoaded];
        }];
    }
}

- (void)adImpression {
    if ([self.delegate respondsToSelector:@selector(oguryAdsThumbnailAdOnAdImpression)]) {
        [self dispatch:^(id<OguryAdsThumbnailAdDelegate> _Nonnull delegate) {
            [delegate oguryAdsThumbnailAdOnAdImpression];
        }];
    }
}

@end
