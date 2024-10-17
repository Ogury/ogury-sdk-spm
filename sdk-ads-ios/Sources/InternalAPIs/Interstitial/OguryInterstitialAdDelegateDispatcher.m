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

    if ([self.delegate respondsToSelector:@selector(interstitialAdDidClick:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate interstitialAdDidClick:self.interstitial];
        }];
    }
}

- (void)closed {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Inter] Ad closed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.interstitial.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(interstitialAdDidClose:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate interstitialAdDidClose:self.interstitial];
        }];
    }
    self.hasSentDisplayedDelegate = NO;
}

- (void)failedWithError:(OguryAdError *)error {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                   error:error
                                                 message:@"[Inter] Ad failed"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.interstitial.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(interstitialAd:didFailWithError:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate interstitialAd:self.interstitial didFailWithError:error];
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

    if ([self.delegate respondsToSelector:@selector(interstitialAdDidLoad:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate interstitialAdDidLoad:self.interstitial];
        }];
    }
}

- (void)adImpression {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:nil
                                                 logType:OguryLogTypeDelegate
                                                 message:@"[Inter] Ad impression"
                                                    tags:@[ [OguryLogTag tagWithKey:@"AdUnitId" value:self.interstitial.adUnitId] ]]];

    if ([self.delegate respondsToSelector:@selector(interstitialAdDidTriggerImpression:)]) {
        [self dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
            [delegate interstitialAdDidTriggerImpression:self.interstitial];
        }];
    }
}

@end
