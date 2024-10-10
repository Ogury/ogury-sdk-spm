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

    if ([self.delegate respondsToSelector:@selector(interstitialAdDidClick:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate interstitialAdDidClick:self.interstitial];
        }];
    }
}

- (void)closed {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad closed called", OGAAdConfigurationAdTypeInterstitial, self.interstitial.adUnitId];

    if ([self.delegate respondsToSelector:@selector(interstitialAdDidClose:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate interstitialAdDidClose:self.interstitial];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryAdError *)error {
    [self.log logErrorFormat:error format:@"[%@][%@] callback ad failed with error called", OGAAdConfigurationAdTypeInterstitial, self.interstitial.adUnitId];

    if ([self.delegate respondsToSelector:@selector(interstitialAd:didFailWithError:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate interstitialAd:self.interstitial didFailWithError:error];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad loaded called", OGAAdConfigurationAdTypeInterstitial, self.interstitial.adUnitId];

    if ([self.delegate respondsToSelector:@selector(interstitialAdDidLoad:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate interstitialAdDidLoad:self.interstitial];
        }];
    }
}

- (void)adImpression {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad ad impression called", OGAAdConfigurationAdTypeInterstitial, self.interstitial.adUnitId];

    if ([self.delegate respondsToSelector:@selector(interstitialAdDidTriggerImpression:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate interstitialAdDidTriggerImpression:self.interstitial];
        }];
    }
}

@end
