//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryThumbnailAdDelegateDispatcher.h"
#import "OguryThumbnailAd.h"
#import "OGALog.h"
#import "OguryAds+Log.h"

@implementation OguryThumbnailAdDelegateDispatcher

- (void)loaded {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:self.thumbnail.adConfiguration
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Thumbnail] Ad loaded"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.thumbnail.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(thumbnailAdDidLoad:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate thumbnailAdDidLoad:self.thumbnail];
        }];
    }
}

- (void)clicked {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:self.thumbnail.adConfiguration
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Thumbnail] Ad clicked"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.thumbnail.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(thumbnailAdDidClick:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate thumbnailAdDidClick:self.thumbnail];
        }];
    }
}

- (void)closed {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:self.thumbnail.adConfiguration
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Thumbnail] Ad closed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.thumbnail.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(thumbnailAdDidClose:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate thumbnailAdDidClose:self.thumbnail];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryAdError *)error {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:self.thumbnail.adConfiguration
                                                 logType:OguryLogTypeDelegate
                                                   error:error
                                                 message:@"[Thumbnail] Ad failed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.thumbnail.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(thumbnailAd:didFailWithError:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate thumbnailAd:self.thumbnail didFailWithError:error];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)adImpression {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:self.thumbnail.adConfiguration
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Thumbnail] Ad impression"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.thumbnail.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(thumbnailAdDidTriggerImpression:)] && self.thumbnail != nil) {
        [self dispatch:^(id<OguryThumbnailAdDelegate> _Nonnull delegate) {
            [delegate thumbnailAdDidTriggerImpression:self.thumbnail];
        }];
    }
}

@end
