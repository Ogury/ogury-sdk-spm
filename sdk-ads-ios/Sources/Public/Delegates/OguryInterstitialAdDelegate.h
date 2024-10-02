//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@class OguryInterstitialAd;

@protocol OguryInterstitialAdDelegate <NSObject>
@optional
- (void)oguryInterstitialAdDidLoad:(OguryInterstitialAd *)interstitial;
- (void)oguryInterstitialAdDidClick:(OguryInterstitialAd *)interstitial;
- (void)oguryInterstitialAdDidClose:(OguryInterstitialAd *)interstitial;
- (void)oguryInterstitialAd:(OguryInterstitialAd *)interstitial didFailWithError:(OguryAdError *)error;
- (void)oguryInterstitialAdDidTriggerImpression:(OguryInterstitialAd *)interstitial;
@end

NS_ASSUME_NONNULL_END
