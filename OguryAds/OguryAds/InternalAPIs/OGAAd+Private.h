//
//  OGAAd+Private.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 03/01/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#ifndef OGAAd_Private_h
#define OGAAd_Private_h

#import <WebKit/WebKit.h>

@class OGAAdConfiguration;
@interface OguryInterstitialAd (WebViewKill)
- (OGAAdConfiguration *)adConfiguration;
- (void)simulateWebviewTerminated;
- (WKWebView *)adWebview;
@end

@interface OguryRewardedAd (WebViewKill)
- (OGAAdConfiguration *)adConfiguration;
- (void)simulateWebviewTerminated;
- (WKWebView *)adWebview;
@end

@interface OguryThumbnailAd (WebViewKill)
- (OGAAdConfiguration *)adConfiguration;
- (void)simulateWebviewTerminated;
- (WKWebView *)adWebview;
@end

@interface OguryBannerAdView (WebViewKill)
- (OGAAdConfiguration *)adConfiguration;
- (void)simulateWebviewTerminated;
- (WKWebView *)adWebview;
@end

#endif /* OGAAd_Private_h */
