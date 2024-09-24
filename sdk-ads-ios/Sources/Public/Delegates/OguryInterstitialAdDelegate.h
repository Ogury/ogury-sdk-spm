//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@class OguryInterstitialAd;

@protocol OguryInterstitialAdDelegate <NSObject>
@optional
- (void)didLoadOguryInterstitialAd:(OguryInterstitialAd *)interstitial;
- (void)didClickOguryInterstitialAd:(OguryInterstitialAd *)interstitial;
- (void)didCloseOguryInterstitialAd:(OguryInterstitialAd *)interstitial;
- (void)didFailOguryInterstitialAdWithError:(OguryAdError *)error forAd:(OguryInterstitialAd *)interstitial;
- (void)didTriggerImpressionOguryInterstitialAd:(OguryInterstitialAd *)interstitial;
@end

NS_ASSUME_NONNULL_END
