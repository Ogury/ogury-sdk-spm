//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@class OguryInterstitialAd;

@protocol OguryInterstitialAdDelegate <NSObject>
@optional
- (void)interstitialAdDidLoad:(OguryInterstitialAd *)interstitialAd NS_SWIFT_NAME(interstitialAdDidLoad(_:));
- (void)interstitialAdDidClick:(OguryInterstitialAd *)interstitialAd NS_SWIFT_NAME(interstitialAdDidClick(_:));
- (void)interstitialAdDidClose:(OguryInterstitialAd *)interstitialAd NS_SWIFT_NAME(interstitialAdDidClose(_:));
- (void)interstitialAd:(OguryInterstitialAd *)interstitialAd didFailWithError:(OguryAdError *)error NS_SWIFT_NAME(interstitialAd(_:didFailWithError:));
- (void)interstitialAdDidTriggerImpression:(OguryInterstitialAd *)interstitialAd NS_SWIFT_NAME(interstitialAdDidTriggerImpression(_:));
@end

NS_ASSUME_NONNULL_END
