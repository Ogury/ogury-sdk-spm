//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OguryBannerAdViewDelegateDispatcher.h"
#import "OguryBannerAdView.h"
#import "OGALog.h"
#import "OguryAds+Log.h"

@implementation OguryBannerAdViewDelegateDispatcher

- (void)clicked {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:self.banner.adConfiguration
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Banner] Ad clicked"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.banner.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(bannerAdViewDidClick:)]) {
        [self dispatch:^(id<OguryBannerAdViewDelegate> _Nonnull delegate) {
            [delegate bannerAdViewDidClick:self.banner];
        }];
    }
}

- (void)closed {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:self.banner.adConfiguration
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Banner] Ad closed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.banner.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(bannerAdViewDidClose:)]) {
        [self dispatch:^(id<OguryBannerAdViewDelegate> _Nonnull delegate) {
            [delegate bannerAdViewDidClose:self.banner];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryAdError *)error {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:self.banner.adConfiguration
                                                 logType:OguryLogTypeDelegate
                                                   error:error
                                                 message:@"[Banner] Ad failed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.banner.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(bannerAdView:didFailWithError:)]) {
        [self dispatch:^(id<OguryBannerAdViewDelegate> _Nonnull delegate) {
            [delegate bannerAdView:self.banner didFailWithError:error];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:self.banner.adConfiguration
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Banner] Ad loaded"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.banner.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(bannerAdViewDidLoad:)]) {
        [self dispatch:^(id<OguryBannerAdViewDelegate> _Nonnull delegate) {
            [delegate bannerAdViewDidLoad:self.banner];
        }];
    }
}

- (void)adImpression {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:self.banner.adConfiguration
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Banner] Ad impression"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.banner.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(bannerAdViewDidTriggerImpression:)]) {
        [self dispatch:^(id<OguryBannerAdViewDelegate> _Nonnull delegate) {
            [delegate bannerAdViewDidTriggerImpression:self.banner];
        }];
    }
}

- (UIViewController *)bannerViewController {
    if ([self.delegate respondsToSelector:@selector(presentingViewControllerForBannerAdView:)]) {
        [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                             adConfiguration:self.banner.adConfiguration
                                                     logType:OguryLogTypeDelegate
                                                     message:@"[Banner] Ad bannerViewController"
                                                        tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.banner.adUnitId] ]]];
        return [self.delegate presentingViewControllerForBannerAdView:self.banner];
    }
    return nil;
}

@end
