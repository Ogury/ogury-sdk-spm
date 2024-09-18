//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OguryInterstitialAdDelegateDispatcher.h"
#import "OguryInterstitialAd.h"
#import "OGAAdConfiguration.h"
#import "OGALog.h"

@implementation OguryInterstitialAdDelegateDispatcher

- (void)clicked {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Inter] Ad clicked"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.interstitial.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didClickOguryInterstitialAd:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate didClickOguryInterstitialAd:self.interstitial];
        }];
    }
}

- (void)closed {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Inter] Ad closed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.interstitial.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didCloseOguryInterstitialAd:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate didCloseOguryInterstitialAd:self.interstitial];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryError *)error {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                   error:error
                                                 message:@"[Inter] Ad failed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.interstitial.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didFailOguryInterstitialAdWithError:forAd:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)loaded {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Inter] Ad loaded"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.interstitial.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didLoadOguryInterstitialAd:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate didLoadOguryInterstitialAd:self.interstitial];
        }];
    }
}

- (void)adImpression {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Inter] Ad impression"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.interstitial.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(didTriggerImpressionOguryInterstitialAd:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate didTriggerImpressionOguryInterstitialAd:self.interstitial];
        }];
    }
}

@end
