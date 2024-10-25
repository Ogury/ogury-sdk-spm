//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAMonitoringEventTestsHelper.h"

@interface OGAMonitoringEventTestsHelperTests : XCTestCase

@property(nonatomic, strong) OGAMonitoringEventTestsHelper *formatter;

@end

@implementation OGAMonitoringEventTestsHelperTests

- (void)setUp {
    self.formatter = [[OGAMonitoringEventTestsHelper alloc] init];
}

- (void)testEventCodeFromEvent {
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadEventLoad], @"LI-001");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadEventLoadSendAdSyncRequest], @"LI-002");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadEventLoadAdSyncResponseReceived], @"LI-003");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadEventLoadAdPrecache], @"LI-004");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadEventLoadAdPrecaching], @"LI-005");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadEventMraidRequest], @"LI-014");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadEventLoadAdPrecachedInWebview], @"LI-006");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadEventLoadAdPrecachedOnFormat], @"LI-007");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadEventLoadAdPrecached], @"LI-008");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadEventLoadAdLoaded], @"LI-009");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadEventLoadAdBackgroundUnloaded], @"LI-010");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadEventWebviewTerminatedByOS], @"LI-011");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadEventAdParseStarted], @"LI-012");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadEventAdParseEnded], @"LI-013");
}

- (void)testEventCodeFromLoadErrorEvent {
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadErrorEventNoInternetConnection], @"LE-001");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadErrorEventInitFail], @"LE-015");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadErrorEventSdkNotInitialized], @"LE-015");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadErrorEventSdkInitFailed], @"LE-015");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadErrorEventEmptyAssetKey], @"LE-015");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadErrorEventProfigFailToSync], @"LE-016");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadErrorEventProfigIsNull], @"LE-016");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadErrorEventAdDisabled], @"LE-008");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadErrorEventAdSyncRequestFail], @"LE-009");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadErrorEventAdParsingError], @"LE-017");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadErrorEventNoFill], @"LE-011");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadErrorEventPrecacheError], @"LE-018");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGALoadErrorEventAdMarkUpParsingError], @"LE-017");
}

- (void)testEventCodeFromShowEvent {
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventShow], @"SI-001");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventDisplay], @"SI-002");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventDisplaying], @"SI-003");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventContainerDisplayed], @"SI-004");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventCreativeDisplayed], @"SI-005");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventDisplayed], @"SI-006");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventImpression], @"SI-007");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventAdClicked], @"SI-008");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventOpenLandingPage], @"SI-009");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventLandingPageOpened], @"SI-010");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventCloseLandingPage], @"SI-011");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventLandingPageClosed], @"SI-012");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventAdClose], @"SI-013");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventLauchBrowser], @"SI-014");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowEventForegroundUnload], @"SI-015");
}

- (void)testEventCodeFromShowErrorEvent {
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowErrorEventAdDisabled], @"SE-001");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowErrorEventAdExpired], @"SE-002");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowErrorEventSdkNotInitialized], @"SE-003");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowErrorEventSdkNeverInitialized], @"SE-003");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowErrorEventNoAdLoaded], @"SE-004");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowErrorEventProfigNotSync], @"SE-006");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowErrorEventViewInBackground], @"SE-008");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowErrorEventAnotherAdAlreadyDisplayed], @"SE-009");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowErrorEventNoInternetConnection], @"SE-010");
    XCTAssertEqual([self.formatter eventCodeFromEvent:OGAShowErrorEventWebviewTerminatedByOS], @"SE-011");
}

- (void)testEventNameFromLoadEvent {
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadEventLoad], @"SDK_EVENT_LOAD");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadEventLoadSendAdSyncRequest], @"SDK_EVENT_SEND_ADSYNC_REQUEST");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadEventLoadAdSyncResponseReceived], @"SDK_EVENT_ADSYNC_RESPONSE_RECEIVED");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadEventLoadAdPrecache], @"SDK_EVENT_PRECACHE");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadEventLoadAdPrecaching], @"SDK_EVENT_AD_PRECACHING");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadEventLoadAdPrecachedInWebview], @"SDK_EVENT_AD_PRECACHED_IN_WEBVIEW");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadEventLoadAdPrecachedOnFormat], @"SDK_EVENT_AD_PRECACHED_ON_FORMAT");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadEventLoadAdPrecached], @"SDK_EVENT_AD_PRECACHED");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadEventLoadAdLoaded], @"SDK_EVENT_LOADED");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadEventWebviewTerminatedByOS], @"SDK_LOAD_EVENT_WEBVIEW_TERMINATED");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadEventLoadAdBackgroundUnloaded], @"SDK_EVENT_BACKGROUND_UNLOAD");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadEventAdParseStarted], @"SDK_EVENT_AD_PARSING");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadEventAdParseEnded], @"SDK_EVENT_AD_PARSED");
}

- (void)testEventNameFromLoadErrorEvent {
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadErrorEventNoInternetConnection], @"SDK_EVENT_LOAD_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadErrorEventInitFail], @"SDK_EVENT_LOAD_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadErrorEventSdkNotInitialized], @"SDK_EVENT_LOAD_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadErrorEventSdkInitFailed], @"SDK_EVENT_LOAD_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadErrorEventEmptyAssetKey], @"SDK_EVENT_LOAD_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadErrorEventProfigFailToSync], @"SDK_EVENT_LOAD_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadErrorEventProfigIsNull], @"SDK_EVENT_LOAD_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadErrorEventAdDisabled], @"SDK_EVENT_LOAD_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadErrorEventAdSyncRequestFail], @"SDK_EVENT_LOAD_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadErrorEventAdParsingError], @"SDK_EVENT_LOAD_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadErrorEventAdMarkUpParsingError], @"SDK_EVENT_LOAD_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadErrorEventNoFill], @"SDK_EVENT_LOAD_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGALoadErrorEventPrecacheError], @"SDK_EVENT_LOAD_ERROR");
}

- (void)testEventNameFromShowEvent {
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventShow], @"SDK_EVENT_SHOW");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventDisplay], @"SDK_EVENT_DISPLAY");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventDisplaying], @"SDK_EVENT_AD_DISPLAYING");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventContainerDisplayed], @"SDK_EVENT_AD_CONTAINER_DISPLAYED");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventCreativeDisplayed], @"SDK_EVENT_AD_CREATIVE_DISPLAYED");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventDisplayed], @"SDK_EVENT_AD_DISPLAYED");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventImpression], @"SDK_EVENT_AD_IMPRESSION");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventAdClicked], @"SDK_EVENT_AD_CLICKED");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventOpenLandingPage], @"SDK_EVENT_AD_OPEN_LANDING_PAGE");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventLandingPageOpened], @"SDK_EVENT_AD_LANDING_PAGE_OPENED");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventCloseLandingPage], @"SDK_EVENT_AD_CLOSE_LANDING_PAGE");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventLandingPageClosed], @"SDK_EVENT_AD_LANDING_PAGE_CLOSED");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventAdClose], @"SDK_EVENT_AD_CLOSED");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventLauchBrowser], @"SDK_EVENT_LAUNCH_BROSWER");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowEventForegroundUnload], @"SDK_EVENT_FOREGROUND_UNLOAD");
}

- (void)testEventNameFromShowErrorEvent {
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowErrorEventAdDisabled], @"SDK_EVENT_SHOW_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowErrorEventAdExpired], @"SDK_EVENT_SHOW_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowErrorEventSdkNotInitialized], @"SDK_EVENT_SHOW_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowErrorEventSdkNeverInitialized], @"SDK_EVENT_SHOW_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowErrorEventNoAdLoaded], @"SDK_EVENT_SHOW_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowErrorEventProfigNotSync], @"SDK_EVENT_SHOW_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowErrorEventViewInBackground], @"SDK_EVENT_SHOW_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowErrorEventAnotherAdAlreadyDisplayed], @"SDK_EVENT_SHOW_ERROR");
    XCTAssertEqual([self.formatter eventNameFromEvent:OGAShowErrorEventNoInternetConnection], @"SDK_EVENT_SHOW_ERROR");
}

- (void)testErrorTypeFromLoadErrorEvent {
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGALoadErrorEventNoInternetConnection], @"CONDITIONS_NOT_MET");

    XCTAssertEqual([self.formatter errorTypeFromEvent:OGALoadErrorEventInitFail], @"INIT_ERROR");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGALoadErrorEventSdkNotInitialized], @"INIT_ERROR");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGALoadErrorEventSdkInitFailed], @"INIT_ERROR");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGALoadErrorEventEmptyAssetKey], @"INIT_ERROR");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGALoadErrorEventProfigFailToSync], @"PROFIG_ERROR");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGALoadErrorEventProfigIsNull], @"PROFIG_ERROR");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGALoadErrorEventAdDisabled], @"CONFIG_RESTRICTIONS");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGALoadErrorEventAdSyncRequestFail], @"ADSYNC_ERROR");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGALoadErrorEventAdParsingError], @"AD_PARSING_ERROR");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGALoadErrorEventAdMarkUpParsingError], @"AD_PARSING_ERROR");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGALoadErrorEventNoFill], @"ADSYNC_ERROR");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGALoadErrorEventPrecacheError], @"PRECACHE_ERROR");
}

- (void)testErrorTypeFromShowErrorEvent {
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGAShowErrorEventAdDisabled], @"CONFIG_RESTRICTIONS");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGAShowErrorEventAdExpired], @"CONFIG_RESTRICTIONS");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGAShowErrorEventSdkNotInitialized], @"INIT_ERROR");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGAShowErrorEventSdkNeverInitialized], @"INIT_ERROR");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGAShowErrorEventNoAdLoaded], @"PRECACHE_ERROR");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGAShowErrorEventProfigNotSync], @"PROFIG_ERROR");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGAShowErrorEventViewInBackground], @"CONDITIONS_NOT_MET");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGAShowErrorEventAnotherAdAlreadyDisplayed], @"CONDITIONS_NOT_MET");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGAShowErrorEventNoInternetConnection], @"CONDITIONS_NOT_MET");
    XCTAssertEqual([self.formatter errorTypeFromEvent:OGAShowErrorEventWebviewTerminatedByOS], @"CONDITIONS_NOT_MET");
}

- (void)testErrorDescriptionFromLoadErrorEvent {
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGALoadErrorEventNoInternetConnection], @"No Internet connection");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGALoadErrorEventInitFail], @"The SDK failed while initializing");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGALoadErrorEventSdkNotInitialized], @"SDK not initialized");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGALoadErrorEventSdkInitFailed], @"SDK initialization failed");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGALoadErrorEventEmptyAssetKey], @"Asset not initialized (asset key empty)");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGALoadErrorEventProfigFailToSync], @"SDK configuration synchronization failed");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGALoadErrorEventProfigIsNull], @"SDK configuration is not synced");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGALoadErrorEventAdDisabled], @"Ad disabled");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGALoadErrorEventAdSyncRequestFail], @"Request failed");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGALoadErrorEventAdParsingError], @"Ad response parsing has failed");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGALoadErrorEventAdMarkUpParsingError], @"Ad markup parsing has failed");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGALoadErrorEventNoFill], @"No ad received");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGALoadErrorEventPrecacheError], @"");
}

- (void)testErrorDescriptionFromShowErrorEvent {
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGAShowErrorEventAdDisabled], @"Ad disabled");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGAShowErrorEventAdExpired], @"Ad expired");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGAShowErrorEventSdkNotInitialized], @"SDK not initialized");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGAShowErrorEventSdkNeverInitialized], @"SDK never initialized (asset key not found)");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGAShowErrorEventNoAdLoaded], @"No ad loaded");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGAShowErrorEventProfigNotSync], @"SDK configuration is not sync");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGAShowErrorEventViewInBackground], @"View in background");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGAShowErrorEventAnotherAdAlreadyDisplayed], @"Another ad already displayed");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGAShowErrorEventNoInternetConnection], @"No Internet connection");
    XCTAssertEqual([self.formatter errorDescriptionFromEvent:OGAShowErrorEventWebviewTerminatedByOS], @"Webview terminated by the OS");
}

@end
