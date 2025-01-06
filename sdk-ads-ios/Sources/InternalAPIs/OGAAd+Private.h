//
//  OGAAd+Private.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 03/01/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#ifndef OGAAd_Private_h
#define OGAAd_Private_h

@class OGAAdConfiguration;
@interface OguryInterstitialAd (WebViewKill)
- (OGAAdConfiguration *)adConfiguration;
- (void)killWebview;
@end

@interface OguryRewardedAd (WebViewKill)
- (OGAAdConfiguration *)adConfiguration;
- (void)killWebview;
@end

@interface OguryThumbnailAd (WebViewKill)
- (OGAAdConfiguration *)adConfiguration;
- (void)killWebview;
@end

@interface OguryBannerAdView (WebViewKill)
- (OGAAdConfiguration *)adConfiguration;
- (void)killWebview;
@end

#endif /* OGAAd_Private_h */
