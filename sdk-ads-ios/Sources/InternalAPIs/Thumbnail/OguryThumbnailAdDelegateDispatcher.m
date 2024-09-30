//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryThumbnailAdDelegateDispatcher.h"
#import "OguryThumbnailAd.h"
#import "OGALog.h"

@implementation OguryThumbnailAdDelegateDispatcher

- (void)loaded {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad loaded called", OGAAdConfigurationAdTypeThumbnailAd, self.thumbnail.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didLoadOguryThumbnailAd:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate didLoadOguryThumbnailAd:self.thumbnail];
        }];
    }
}

- (void)clicked {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad clicked called", OGAAdConfigurationAdTypeThumbnailAd, self.thumbnail.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didClickOguryThumbnailAd:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate didClickOguryThumbnailAd:self.thumbnail];
        }];
    }
}

- (void)closed {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad closed called", OGAAdConfigurationAdTypeThumbnailAd, self.thumbnail.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didCloseOguryThumbnailAd:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate didCloseOguryThumbnailAd:self.thumbnail];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryAdError *)error {
    [self.log logErrorFormat:error format:@"[%@][%@] callback failed with error called", OGAAdConfigurationAdTypeThumbnailAd, self.thumbnail.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didFailOguryThumbnailAd:error:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate didFailOguryThumbnailAd:self.thumbnail error:error];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)adImpression {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad impression called", OGAAdConfigurationAdTypeThumbnailAd, self.thumbnail.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didTriggerImpressionOguryThumbnailAd:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate didTriggerImpressionOguryThumbnailAd:self.thumbnail];
        }];
    }
}

@end
