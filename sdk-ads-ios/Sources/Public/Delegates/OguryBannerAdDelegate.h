//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@class OguryBannerAdView;

@protocol OguryBannerAdDelegate <NSObject>
@optional
- (void)oguryBannerAdViewDidLoad:(OguryBannerAdView *)banner;
- (void)oguryBannerAdViewDidClick:(OguryBannerAdView *)banner;
- (void)oguryBannerAdViewDidClose:(OguryBannerAdView *)banner;
- (void)oguryBannerAdView:(OguryBannerAdView *)banner didFailWithError:(OguryAdError *)error;
- (void)oguryBannerAdViewDidTriggerImpression:(OguryBannerAdView *)banner;
- (UIViewController *_Nullable)presentingViewControllerForOguryAdsBannerAdView:(OguryBannerAdView *)banner;
@end

NS_ASSUME_NONNULL_END
