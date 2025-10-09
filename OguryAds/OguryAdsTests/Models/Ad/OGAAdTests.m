//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAd.h"

@interface OGAAdTests : XCTestCase

@end

@implementation OGAAdTests

- (void)testKeyMapper {
    OGAJSONKeyMapper *keymapper = [OGAAd keyMapper];
    XCTAssertNotNil(keymapper);
    XCTAssertTrue([[keymapper convertValue:@"html"] isEqualToString:@"ad_content"]);
    XCTAssertTrue([[keymapper convertValue:@"impressionUrl"] isEqualToString:@"impression_url"]);
    XCTAssertTrue([[keymapper convertValue:@"identifier"] isEqualToString:@"id"]);
    XCTAssertTrue([[keymapper convertValue:@"advertiserId"] isEqualToString:@"advertiser.id"]);
    XCTAssertTrue([[keymapper convertValue:@"campaignId"] isEqualToString:@"campaign_id"]);
    XCTAssertTrue([[keymapper convertValue:@"creativeId"] isEqualToString:@"creative_id"]);
    XCTAssertTrue([[keymapper convertValue:@"webViewBaseUrl"] isEqualToString:@"format.webview_base_url"]);
    XCTAssertTrue([[keymapper convertValue:@"mraidDownloadUrl"] isEqualToString:@"format.mraid_download_url"]);
    XCTAssertTrue([[keymapper convertValue:@"moatEnabled"] isEqualToString:@"moatEnabled"]);
    XCTAssertTrue([[keymapper convertValue:@"omidEnabled"] isEqualToString:@"omid"]);
    XCTAssertTrue([[keymapper convertValue:@"adUnit"] isEqualToString:@"ad_unit"]);
    XCTAssertTrue([[keymapper convertValue:@"isImpression"] isEqualToString:@"is_impression"]);
    XCTAssertTrue([[keymapper convertValue:@"thumbnailAdResponse"] isEqualToString:@"overlay"]);
    XCTAssertTrue([[keymapper convertValue:@"bannerAdResponse"] isEqualToString:@"banner"]);
    XCTAssertTrue([[keymapper convertValue:@"clientTrackerPattern"] isEqualToString:@"client_tracker_pattern"]);
    XCTAssertTrue([[keymapper convertValue:@"hasTransparency"] isEqualToString:@"has_transparency"]);
    XCTAssertTrue([[keymapper convertValue:@"sdkCloseButtonUrl"] isEqualToString:@"sdk_close_button_url"]);
    XCTAssertTrue([[keymapper convertValue:@"landingPagePrefetchURL"] isEqualToString:@"landing_page_prefetch_url"]);
    XCTAssertTrue([[keymapper convertValue:@"disableLandingPageJavascript"] isEqualToString:@"landing_page_disable_javascript"]);
    XCTAssertTrue([[keymapper convertValue:@"landingPagePrefetchWhitelist"] isEqualToString:@"landing_page_prefetch_whitelist"]);
    XCTAssertTrue([[keymapper convertValue:@"adKeepAlive"] isEqualToString:@"ad_keep_alive"]);
    XCTAssertTrue([[keymapper convertValue:@"delayForSendingLoaded"] isEqualToString:@"format.delay_for_sending_loaded"]);
    XCTAssertTrue([[keymapper convertValue:@"launchOmidSessionAtLoad"] isEqualToString:@"format.launch_omid_load"]);
    XCTAssertTrue([[keymapper convertValue:@"adTrackUrl"] isEqualToString:@"ad_track_urls.ad_track_url"]);
    XCTAssertTrue([[keymapper convertValue:@"adPrecacheUrl"] isEqualToString:@"ad_track_urls.ad_precache_url"]);
    XCTAssertTrue([[keymapper convertValue:@"adHistoryUrl"] isEqualToString:@"ad_track_urls.ad_history_url"]);
    XCTAssertTrue([[keymapper convertValue:@"impressionSource"] isEqualToString:@"impression_source"]);
    XCTAssertTrue([[keymapper convertValue:@"skAdNetworkResponse"] isEqualToString:@"skadnetwork"]);
    XCTAssertTrue([[keymapper convertValue:@"rawLoadedSource"] isEqualToString:@"loaded_source"]);
    XCTAssertTrue([[keymapper convertValue:@"expirationTime"] isEqualToString:@"cache.ad_expiration"]);
    XCTAssertTrue([[keymapper convertValue:@"maxNumberOfReloadWebView"] isEqualToString:@"format.max_attempts_reload"]);
    XCTAssertTrue([[keymapper convertValue:@"extras"] isEqualToString:@"extras"]);
}

- (void)testSupportedOrientationForAd_defaultOrientation {
    XCTAssertEqual([OGAAd supportedOrientationForAd:nil], UIInterfaceOrientationMaskAll);

    OGAAd *ad = [[OGAAd alloc] init];
    ad.orientation = nil;
    XCTAssertEqual([OGAAd supportedOrientationForAd:ad], UIInterfaceOrientationMaskAll);
}

- (void)testSupportedOrientationForAd_forcedOrientationInPortrait {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.orientation = OGAAdOrientationPortrait;
    XCTAssertEqual([OGAAd supportedOrientationForAd:ad], UIInterfaceOrientationMaskPortrait);
}

- (void)testSupportedOrientationForAd_forcedOrientationInLandscape {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.orientation = OGAAdOrientationLandscape;
    XCTAssertEqual([OGAAd supportedOrientationForAd:ad], UIInterfaceOrientationMaskLandscape);
}

- (void)testLoadedSourceIsFormatWhenNil {
    OGAAd *ad = [[OGAAd alloc] init];
    XCTAssertEqual([ad loadedSource], LoadedSourceFormat);
}

- (void)testLoadedSourceIsFormatWhenProvided {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.rawLoadedSource = @"format";
    XCTAssertEqual([ad loadedSource], LoadedSourceFormat);
}

- (void)testLoadedSourceIsSDKWhenProvided {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.rawLoadedSource = @"sdk";
    XCTAssertEqual([ad loadedSource], LoadedSourceSDK);
}

@end
