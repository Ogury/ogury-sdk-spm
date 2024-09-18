//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OguryBannerAdDelegateDispatcher.h"
#import "OguryBannerAd.h"
#import "OGALog.h"

@implementation OguryBannerAdDelegateDispatcher

- (void)clicked {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Banner] Ad clicked"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.banner.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didClickOguryBannerAd:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didClickOguryBannerAd:self.banner];
        }];
    }
}

- (void)closed {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Banner] Ad closed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.banner.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didCloseOguryBannerAd:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didCloseOguryBannerAd:self.banner];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryError *)error {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                   error:error
                                                 message:@"[Banner] Ad failed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.banner.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didFailOguryBannerAdWithError:forAd:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didFailOguryBannerAdWithError:error forAd:self.banner];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Banner] Ad loaded"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.banner.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didLoadOguryBannerAd:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didLoadOguryBannerAd:self.banner];
        }];
    }
}

- (void)adImpression {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Banner] Ad impression"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.banner.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didTriggerImpressionOguryBannerAd:)]) {
        [self dispatch:^(id<OguryBannerAdDelegate> _Nonnull delegate) {
            [delegate didTriggerImpressionOguryBannerAd:self.banner];
        }];
    }
}

- (UIViewController *)bannerViewController {
    if ([self.delegate respondsToSelector:@selector(presentingViewControllerForOguryAdsBannerAd:)]) {
        [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                             adConfiguration:nil
                                                     logType:OguryLogTypeDelegate
                                                     message:@"[Banner] Ad bannerViewController"
                                                        tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.banner.adUnitId] ]]];
        return [self.delegate presentingViewControllerForOguryAdsBannerAd:self.banner];
    }
    return nil;
}

@end
