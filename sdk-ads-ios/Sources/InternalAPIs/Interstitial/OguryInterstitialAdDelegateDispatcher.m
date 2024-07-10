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

    if ([self.delegate respondsToSelector:@selector(didClickOguryInterstitialAd:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate didClickOguryInterstitialAd:self.interstitial];
        }];
    }
}

- (void)closed {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad closed called", OGAAdConfigurationAdTypeInterstitial, self.interstitial.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didCloseOguryInterstitialAd:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate didCloseOguryInterstitialAd:self.interstitial];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)displayed {
    if (!self.hasSentDisplayedDelegate) {
        [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad displayed called", OGAAdConfigurationAdTypeInterstitial, self.interstitial.adUnitId];

        if ([self.delegate respondsToSelector:@selector(didDisplayOguryInterstitialAd:)]) {
            [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
                [delegate didDisplayOguryInterstitialAd:self.interstitial];
            }];
        }
        self.hasSentDisplayedDelegate = YES;
    }
}

- (void)failedWithError:(OguryError *)error {
    [self.log logErrorFormat:error format:@"[%@][%@] callback ad failed with error called", OGAAdConfigurationAdTypeInterstitial, self.interstitial.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didFailOguryInterstitialAdWithError:forAd:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad loaded called", OGAAdConfigurationAdTypeInterstitial, self.interstitial.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didLoadOguryInterstitialAd:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate didLoadOguryInterstitialAd:self.interstitial];
        }];
    }
}

- (void)adImpression {
    [self.log logFormat:OguryLogLevelInfo format:@"[%@][%@] callback ad ad impression called", OGAAdConfigurationAdTypeInterstitial, self.interstitial.adUnitId];

    if ([self.delegate respondsToSelector:@selector(didTriggerImpressionOguryInterstitialAd:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate didTriggerImpressionOguryInterstitialAd:self.interstitial];
        }];
    }
}

@end
