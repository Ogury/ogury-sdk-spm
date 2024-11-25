//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@class OguryBannerAdView;

@protocol OguryBannerAdViewDelegate <NSObject>
@optional
- (void)bannerAdViewDidLoad:(OguryBannerAdView *)bannerAd NS_SWIFT_NAME(bannerAdViewDidLoad(_:));
- (void)bannerAdViewDidClick:(OguryBannerAdView *)bannerAd NS_SWIFT_NAME(bannerAdViewDidClick(_:));
- (void)bannerAdViewDidClose:(OguryBannerAdView *)bannerAd NS_SWIFT_NAME(bannerAdViewDidClose(_:));
- (void)bannerAdView:(OguryBannerAdView *)bannerAd didFailWithError:(OguryAdError *)error NS_SWIFT_NAME(bannerAdView(_:didFailWithError:));
- (void)bannerAdViewDidTriggerImpression:(OguryBannerAdView *)bannerAd NS_SWIFT_NAME(bannerAdViewDidTriggerImpression(_:));
- (UIViewController *_Nullable)presentingViewControllerForBannerAdView:(OguryBannerAdView *)bannerAd NS_SWIFT_NAME(presentingViewController(forBannerAdView:));
@end

NS_ASSUME_NONNULL_END
