//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@class OguryBannerAd;

@protocol OguryBannerAdDelegate <NSObject>
@optional
- (void)didLoadOguryBannerAd:(OguryBannerAd *)banner;
- (void)didClickOguryBannerAd:(OguryBannerAd *)banner;
- (void)didCloseOguryBannerAd:(OguryBannerAd *)banner;
- (void)didFailOguryBannerAdWithError:(OguryAdError *)error forAd:(OguryBannerAd *)banner;
- (void)didTriggerImpressionOguryBannerAd:(OguryBannerAd *)banner;
- (UIViewController *_Nullable)presentingViewControllerForOguryAdsBannerAd:(OguryBannerAd *)banner;
@end

NS_ASSUME_NONNULL_END
