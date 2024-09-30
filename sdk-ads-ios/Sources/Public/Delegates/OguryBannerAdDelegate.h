//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@class OguryBannerAdView;

@protocol OguryBannerAdDelegate <NSObject>
@optional
- (void)didLoadOguryBannerAdView:(OguryBannerAdView *)banner;
- (void)didClickOguryBannerAdView:(OguryBannerAdView *)banner;
- (void)didCloseOguryBannerAdView:(OguryBannerAdView *)banner;
- (void)didFailOguryBannerAdView:(OguryBannerAdView *)banner error:(OguryAdError *)error;
- (void)didTriggerImpressionOguryBannerAdView:(OguryBannerAdView *)banner;
- (UIViewController *_Nullable)presentingViewControllerForOguryAdsBannerAdView:(OguryBannerAdView *)banner;
@end

NS_ASSUME_NONNULL_END
