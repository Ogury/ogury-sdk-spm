//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAAdMonitorEvent.h"
#import "OGAAdServerMonitorRequestBuilder.h"
#import "OGAMonitoringConstants.h"
#import "OGAMonitoringEventPermissionTestsHelper.h"

@interface OGAMonitoringEventPermissionHandlerTests : XCTestCase

@property(nonatomic, retain) OGAMonitoringEventPermissionTestsHelper *eventPermissionHandler;

@end

@interface OGAMonitoringEventPermissionTestsHelper ()

- (OGAAdIdMask)adIdMaskForEvent:(OGAMonitoringEvent)event;

@end

@implementation OGAMonitoringEventPermissionHandlerTests

- (void)setUp {
    self.eventPermissionHandler = OCMPartialMock([[OGAMonitoringEventPermissionTestsHelper alloc] init]);
}

- (void)testcanSendCampaignIdForEventFalse {
    XCTAssertFalse([self.eventPermissionHandler canSendCampaignIdFor:OGALoadEventLoad]);
}

- (void)testcanSendCampaignIdForEventTrue {
    XCTAssertTrue([self.eventPermissionHandler canSendCampaignIdFor:OGALoadEventLoadAdPrecaching]);
}

- (void)testcanSendCreativeIdForEventFalse {
    XCTAssertFalse([self.eventPermissionHandler canSendCreativeIdFor:OGALoadEventLoad]);
}

- (void)testcanSendCreativeIdForEventTrue {
    XCTAssertTrue([self.eventPermissionHandler canSendCreativeIdFor:OGALoadEventLoadAdPrecaching]);
}

- (void)testAdIdMaskForEvent {
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoad], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadSendAdSyncRequest], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdSyncResponseReceived], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdPrecache], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdPrecaching], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdPrecachedInWebview], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdPrecachedOnFormat], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdPrecached], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdLoaded], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdBackgroundUnloaded], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventWebviewTerminatedByOS], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkLoadEventStoreViewControllerLoading], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkLoadEventStoreViewControllerLoaded], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdPrecache], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdPrecaching], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdPrecachedInWebview], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdPrecachedOnFormat], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdPrecached], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdLoaded], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventLoadAdBackgroundUnloaded], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventWebviewTerminatedByOS], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventAdParseStarted], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadEventAdParseEnded], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkLoadEventStoreViewControllerLoading], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkLoadEventStoreViewControllerLoaded], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventNoInternetConnection], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventInitFail], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventSdkNotInitialized], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventSdkInitFailed], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventEmptyAssetKey], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventProfigFailToSync], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventProfigIsNull], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventAdDisabled], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventAdSyncRequestFail], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventAdParsingError], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventNoFill], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventCallError], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkLoadErrorEventFailedLoadingStoreController], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventShow], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventDisplay], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventDisplaying], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventContainerDisplayed], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventCreativeDisplayed], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventDisplayed], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventAdClicked], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventOpenLandingPage], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventLandingPageOpened], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventCloseLandingPage], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventLandingPageClosed], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventAdClose], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventLauchBrowser], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventForegroundUnload], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkShowEventStartingImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkShowEventStartImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkShowEventStoppingImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkShowEventStopImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkShowEventIncompatibleIOSVersionToStopImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventAdMarkUpParsingError], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventPrecacheError], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGALoadErrorEventCallError], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkLoadErrorEventFailedLoadingStoreController], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventShow], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventDisplay], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventDisplaying], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventContainerDisplayed], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventCreativeDisplayed], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventDisplayed], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventAdClicked], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventOpenLandingPage], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventLandingPageOpened], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventCloseLandingPage], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventLandingPageClosed], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventAdClose], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventLauchBrowser], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowEventForegroundUnload], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkShowEventStartingImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkShowEventStartImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkShowEventStoppingImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkShowEventStopImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkShowEventIncompatibleIOSVersionToStopImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowErrorEventAdDisabled], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowErrorEventAdExpired], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowErrorEventSdkNotInitialized], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowErrorEventSdkNeverInitialized], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowErrorEventNoAdLoaded], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowErrorEventProfigNotSync], OGAAdIdMaskNone);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowErrorEventViewInBackground], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowErrorEventAnotherAdAlreadyDisplayed], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowErrorEventNoInternetConnection], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGAShowErrorEventWebviewTerminatedByOS], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkShowErrorEventFailedToStopImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:OGASKNetworkShowErrorEventFailedToStopImpression], OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras);
    XCTAssertEqual([self.eventPermissionHandler adIdMaskForEvent:99999999999], OGAAdIdMaskNone);
}

@end
