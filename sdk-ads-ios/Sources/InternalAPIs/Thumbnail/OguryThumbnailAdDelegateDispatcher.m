//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryThumbnailAdDelegateDispatcher.h"
#import "OguryThumbnailAd.h"
#import "OGALog.h"

@implementation OguryThumbnailAdDelegateDispatcher

- (void)loaded {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Thumbnail] Ad loaded"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.thumbnail.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didLoadOguryThumbnailAd:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate didLoadOguryThumbnailAd:self.thumbnail];
        }];
    }
}

- (void)clicked {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Thumbnail] Ad clicked"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.thumbnail.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didClickOguryThumbnailAd:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate didClickOguryThumbnailAd:self.thumbnail];
        }];
    }
}

- (void)closed {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Thumbnail] Ad closed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.thumbnail.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didCloseOguryThumbnailAd:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate didCloseOguryThumbnailAd:self.thumbnail];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryError *)error {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                   error:error
                                                 message:@"[Thumbnail] Ad failed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.thumbnail.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didFailOguryThumbnailAdWithError:forAd:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate didFailOguryThumbnailAdWithError:error forAd:self.thumbnail];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)adImpression {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Thumbnail] Ad impression"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.thumbnail.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didTriggerImpressionOguryThumbnailAd:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate didTriggerImpressionOguryThumbnailAd:self.thumbnail];
        }];
    }
}

@end
