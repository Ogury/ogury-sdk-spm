//
//  Copyright © 2018 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OGAJSONModel.h"
#import "OGAAdUnit.h"
#import "OGAThumbnailAdResponse.h"
#import "OGABannerAdResponse.h"
#import "OGASKAdNetworkResponse.h"
#import "OGAAdLoadStateManager.h"
#import "OGAAdPrivacyConfiguration.h"

@class OGAAdConfiguration;
@class OGAAdPrivacyConfiguration;

extern NSString *const _Nonnull OGAAdOrientationPortrait;
extern NSString *const _Nonnull OGAAdOrientationLandscape;

@interface OGAAd : OGAJSONModel

@property(nonatomic, strong, nullable) NSString *identifier;
@property(nonatomic, strong, nullable) NSString *localIdentifier;
@property(nonatomic, strong, nullable) NSDictionary *json;
@property(nonatomic, strong, nullable) NSString *html;
@property(nonatomic, strong, nullable) NSString *impressionUrl;
@property(nonatomic, strong, nullable) NSString *advertiserId;
@property(nonatomic, strong, nullable) NSString *campaignId;
@property(nonatomic, strong, nullable) NSString *creativeId;
@property(nonatomic, strong, nullable) NSString *webViewBaseUrl;
@property(nonatomic, strong, nullable) NSString *mraidDownloadUrl;
@property(nonatomic, strong, nullable) NSString *sdkBackgroundColor;
@property(nonatomic, assign) BOOL moatEnabled;
@property(nonatomic, assign) BOOL omidEnabled;
@property(nonatomic, assign) BOOL isVideo;
@property(nonatomic, assign) BOOL isImpression;
@property(nonatomic, strong, nullable) OGAAdUnit *adUnit;
@property(nonatomic, strong, nullable) NSString *orientation;  // custom parse
@property(nonatomic, strong, nullable) NSString *adWebViewId;  // custom parse
@property(nonatomic, strong, nullable) NSString *clientTrackerPattern;
@property(nonatomic, assign) BOOL hasTransparency;
@property(nonatomic, strong, nullable) NSString *sdkCloseButtonUrl;
@property(nonatomic, strong, nullable) NSString *landingPagePrefetchURL;
@property(nonatomic, assign) BOOL disableLandingPageJavascript;
@property(nonatomic, strong, nullable) NSString *landingPagePrefetchWhitelist;
@property(nonatomic, strong, nullable) OGAThumbnailAdResponse *thumbnailAdResponse;
@property(nonatomic, strong, nullable) OGABannerAdResponse *bannerAdResponse;
@property(nonatomic, assign) BOOL adKeepAlive;
@property(nonatomic, strong, nullable) OGAAdPrivacyConfiguration *privacyConfiguration;
@property(nonatomic, strong, nullable) OGAAdConfiguration *adConfiguration;
@property(nonatomic, assign) NSInteger delayForSendingLoaded;
@property(nonatomic, assign) BOOL launchOmidSessionAtLoad;
@property(nonatomic, strong, nullable) NSString *adPrecacheUrl;
@property(nonatomic, strong, nullable) NSString *adTrackUrl;
@property(nonatomic, strong, nullable) NSString *adHistoryUrl;
@property(nonatomic, strong, nullable) NSString *impressionSource;
@property(nonatomic, strong, nullable) NSString *rawLoadedSource;
@property(nonatomic, strong, nullable) OGASKAdNetworkResponse *skAdNetworkResponse;
@property(nonatomic, strong, nullable) NSNumber *expirationTime;
@property(nonatomic, strong, nullable) NSNumber *maxNumberOfReloadWebView;
@property(nonatomic, strong, nullable) NSArray *extras;

+ (UIInterfaceOrientationMask)supportedOrientationForAd:(OGAAd *_Nullable)ad;
- (LoadedSource)loadedSource;
- (NSString *_Nonnull)getRawLoadedSource;

@end
