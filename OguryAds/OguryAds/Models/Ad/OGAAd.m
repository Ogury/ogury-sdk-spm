//
//  Copyright © 2018 Ogury Ltd. All rights reserved.
//

#import "OGAAd.h"

NSString *const _Nonnull OGAAdOrientationPortrait = @"portrait";
NSString *const _Nonnull OGAAdOrientationLandscape = @"landscape";
NSString *const OGALoadedSourceFormat = @"format";
NSString *const OGALoadedSourceSDK = @"sdk";

@implementation OGAAd

+ (OGAJSONKeyMapper *)keyMapper {
    return [[OGAJSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"html" : @"ad_content",
        @"impressionUrl" : @"impression_url",
        @"identifier" : @"id",
        @"advertiserId" : @"advertiser.id",
        @"campaignId" : @"campaign_id",
        @"creativeId" : @"creative_id",
        @"webViewBaseUrl" : @"format.webview_base_url",
        @"mraidDownloadUrl" : @"format.mraid_download_url",
        @"sdkBackgroundColor" : @"sdk_background_color",
        @"moatEnabled" : @"moatEnabled",
        @"omidEnabled" : @"omid",
        @"isVideo" : @"is_video",
        @"adUnit" : @"ad_unit",
        @"isImpression" : @"is_impression",
        @"thumbnailAdResponse" : @"overlay",
        @"bannerAdResponse" : @"banner",
        @"clientTrackerPattern" : @"client_tracker_pattern",
        @"hasTransparency" : @"has_transparency",
        @"sdkCloseButtonUrl" : @"sdk_close_button_url",
        @"landingPagePrefetchURL" : @"landing_page_prefetch_url",
        @"disableLandingPageJavascript" : @"landing_page_disable_javascript",
        @"landingPagePrefetchWhitelist" : @"landing_page_prefetch_whitelist",
        @"adKeepAlive" : @"ad_keep_alive",
        @"delayForSendingLoaded" : @"format.delay_for_sending_loaded",
        @"launchOmidSessionAtLoad" : @"format.launch_omid_load",
        @"adTrackUrl" : @"ad_track_urls.ad_track_url",
        @"adPrecacheUrl" : @"ad_track_urls.ad_precache_url",
        @"adHistoryUrl" : @"ad_track_urls.ad_history_url",
        @"impressionSource" : @"impression_source",
        @"skAdNetworkResponse" : @"skadnetwork",
        @"rawLoadedSource" : @"loaded_source",
        @"expirationTime" : @"cache.ad_expiration",
        @"maxNumberOfReloadWebView" : @"format.max_attempts_reload",
        @"extras" : @"extras"
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return true;
}

+ (UIInterfaceOrientationMask)supportedOrientationForAd:(OGAAd *)ad {
    if ([ad.orientation isEqualToString:OGAAdOrientationLandscape]) {
        return UIInterfaceOrientationMaskLandscape;
    } else if ([ad.orientation isEqualToString:OGAAdOrientationPortrait]) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

/// transforms the raw NSString (if available) loadedSource into a NSString enum `LoadedSource`
/// if no loaded_source was found, we use the format behavior
- (LoadedSource)loadedSource {
    return [self.rawLoadedSource isEqualToString:OGALoadedSourceSDK] ? LoadedSourceSDK : LoadedSourceFormat;
}

- (NSString *)getRawLoadedSource {
    return _rawLoadedSource != nil ? _rawLoadedSource : OGALoadedSourceFormat;
}
@end
