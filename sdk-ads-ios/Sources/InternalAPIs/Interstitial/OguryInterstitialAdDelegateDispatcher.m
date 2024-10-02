//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OguryInterstitialAdDelegateDispatcher.h"
#import "OguryInterstitialAd.h"
#import "OGAAdConfiguration.h"
#import "OGALog.h"

@implementation OguryInterstitialAdDelegateDispatcher

- (void)clicked {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad clicked called", OGAAdConfigurationAdTypeInterstitial, self.interstitial.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryInterstitialAdDidClick:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate oguryInterstitialAdDidClick:self.interstitial];
        }];
    }
}

- (void)closed {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad closed called", OGAAdConfigurationAdTypeInterstitial, self.interstitial.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryInterstitialAdDidClose:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate oguryInterstitialAdDidClose:self.interstitial];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryAdError *)error {
    [self.log logErrorFormat:error format:@"[%@][%@] callback ad failed with error called", OGAAdConfigurationAdTypeInterstitial, self.interstitial.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryInterstitialAd:didFailWithError:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate oguryInterstitialAd:self.interstitial didFailWithError:error];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad loaded called", OGAAdConfigurationAdTypeInterstitial, self.interstitial.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryInterstitialAdDidLoad:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate oguryInterstitialAdDidLoad:self.interstitial];
        }];
    }
}

- (void)adImpression {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad ad impression called", OGAAdConfigurationAdTypeInterstitial, self.interstitial.adUnitId];

    if ([self.delegate respondsToSelector:@selector(oguryInterstitialAdDidTriggerImpression:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate oguryInterstitialAdDidTriggerImpression:self.interstitial];
        }];
    }
}

@end
