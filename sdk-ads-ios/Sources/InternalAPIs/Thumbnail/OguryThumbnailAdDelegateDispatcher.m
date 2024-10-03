//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryThumbnailAdDelegateDispatcher.h"
#import "OguryThumbnailAd.h"
#import "OGALog.h"

@implementation OguryThumbnailAdDelegateDispatcher

- (void)loaded {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad loaded called", OGAAdConfigurationAdTypeThumbnailAd, self.thumbnail.adUnitId];

    if ([self.delegate respondsToSelector:@selector(thumbnailAdDidLoad:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate thumbnailAdDidLoad:self.thumbnail];
        }];
    }
}

- (void)clicked {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad clicked called", OGAAdConfigurationAdTypeThumbnailAd, self.thumbnail.adUnitId];

    if ([self.delegate respondsToSelector:@selector(thumbnailAdDidClick:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate thumbnailAdDidClick:self.thumbnail];
        }];
    }
}

- (void)closed {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad closed called", OGAAdConfigurationAdTypeThumbnailAd, self.thumbnail.adUnitId];

    if ([self.delegate respondsToSelector:@selector(thumbnailAdDidClose:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate thumbnailAdDidClose:self.thumbnail];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryAdError *)error {
    [self.log logErrorFormat:error format:@"[%@][%@] callback failed with error called", OGAAdConfigurationAdTypeThumbnailAd, self.thumbnail.adUnitId];

    if ([self.delegate respondsToSelector:@selector(thumbnailAd:didFailWithError:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate thumbnailAd:self.thumbnail didFailWithError:error];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)adImpression {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad impression called", OGAAdConfigurationAdTypeThumbnailAd, self.thumbnail.adUnitId];

    if ([self.delegate respondsToSelector:@selector(thumbnailAdDidTriggerImpression:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate thumbnailAdDidTriggerImpression:self.thumbnail];
        }];
    }
}

@end
