//
//  OguryInterstitialAd+Log.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 06/11/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//
#import <OguryAds/OguryInterstitialAd.h>
#import <OguryAds/OguryRewardedAd.h>
#import <OguryAds/OguryThumbnailAd.h>
#import <OguryAds/OguryBannerAdView.h>
@class OGAAdConfiguration;

@interface OguryInterstitialAd (Log)
- (void)setLogOrigin:(NSString *)origin;
- (OGAAdConfiguration *)adConfiguration;
@end

@interface OguryRewardedAd (Log)
- (void)setLogOrigin:(NSString *)origin;
- (OGAAdConfiguration *)adConfiguration;
@end

@interface OguryThumbnailAd (Log)
- (void)setLogOrigin:(NSString *)origin;
- (OGAAdConfiguration *)adConfiguration;
@end

@interface OguryBannerAdView (Log)
- (void)setLogOrigin:(NSString *)origin;
- (OGAAdConfiguration *)adConfiguration;
@end
