//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAMonitorEventConfigurationFactory.h"
#import "OGAMonitoringEventTestsHelper.h"
#import "OGAMonitoringEventPermissionTestsHelper.h"

@interface OGAMonitorEventConfigurationFactoryTests : XCTestCase
@property(nonatomic, retain) OGAMonitorEventConfigurationFactory *configurationFactory;
@property(nonatomic, retain) OGAMonitoringEventTestsHelper *eventFormatter;
@property(nonatomic, retain) OGAMonitoringEventPermissionTestsHelper *eventPermissionHandler;
@end

@implementation OGAMonitorEventConfigurationFactoryTests

- (void)setUp {
    _configurationFactory = [OGAMonitorEventConfigurationFactory new];
    _eventFormatter = [OGAMonitoringEventTestsHelper new];
    _eventPermissionHandler = [OGAMonitoringEventPermissionTestsHelper new];
}

- (void)testWhenEventConfigurationIsRetrievedThenItMatchesExpectedFields {
    NSArray<NSNumber *> *allEvents = @[
        @(OGALoadEventLoad),
        @(OGALoadEventLoadSendAdSyncRequest),
        @(OGALoadEventLoadAdSyncResponseReceived),
        @(OGALoadEventLoadAdPrecache),
        @(OGALoadEventLoadAdPrecaching),
        @(OGALoadEventLoadAdPrecachedInWebview),
        @(OGALoadEventLoadAdPrecachedOnFormat),
        @(OGALoadEventLoadAdPrecached),
        @(OGALoadEventLoadAdLoaded),
        @(OGALoadEventLoadAdBackgroundUnloaded),
        @(OGALoadEventWebviewTerminatedByOS),
        @(OGALoadEventAdParseStarted),
        @(OGALoadEventAdParseEnded),
        @(OGASKNetworkLoadEventStoreViewControllerLoading),
        @(OGASKNetworkLoadEventStoreViewControllerLoaded),
        @(OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion),
        @(OGALoadErrorEventNoInternetConnection),
        @(OGALoadErrorEventInitFail),
        @(OGALoadErrorEventSdkNotInitialized),
        @(OGALoadErrorEventSdkNeverInitialized),
        @(OGALoadErrorEventSdkInitFailed),
        @(OGALoadErrorEventEmptyAssetKey),
        @(OGALoadErrorEventProfigFailToSync),
        @(OGALoadErrorEventProfigIsNull),
        @(OGALoadErrorEventAdDisabled),
        @(OGALoadErrorEventAdSyncRequestFail),
        @(OGALoadErrorEventAdParsingError),
        @(OGALoadErrorEventNoFill),
        @(OGALoadErrorEventAdMarkUpParsingError),
        @(OGALoadErrorEventPrecacheError),
        @(OGALoadErrorEventCallError),
        @(OGASKNetworkLoadErrorEventFailedLoadingStoreController),
        @(OGAShowEventShow),
        @(OGAShowEventDisplay),
        @(OGAShowEventDisplaying),
        @(OGAShowEventContainerDisplayed),
        @(OGAShowEventCreativeDisplayed),
        @(OGAShowEventDisplayed),
        @(OGAShowEventImpression),
        @(OGAShowEventAdClicked),
        @(OGAShowEventOpenLandingPage),
        @(OGAShowEventLandingPageOpened),
        @(OGAShowEventCloseLandingPage),
        @(OGAShowEventLandingPageClosed),
        @(OGAShowEventAdClose),
        @(OGAShowEventLauchBrowser),
        @(OGAShowEventForegroundUnload),
        @(OGASKNetworkShowEventStartingImpression),
        @(OGASKNetworkShowEventStartImpression),
        @(OGASKNetworkShowEventStoppingImpression),
        @(OGASKNetworkShowEventStopImpression),
        @(OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression),
        @(OGASKNetworkShowEventIncompatibleIOSVersionToStopImpression),
        @(OGAShowErrorEventAdDisabled),
        @(OGAShowErrorEventAdExpired),
        @(OGAShowErrorEventSdkNotInitialized),
        @(OGAShowErrorEventSdkNeverInitialized),
        @(OGAShowErrorEventNoAdLoaded),
        @(OGAShowErrorEventProfigNotSync),
        @(OGAShowErrorEventViewInBackground),
        @(OGAShowErrorEventAnotherAdAlreadyDisplayed),
        @(OGAShowErrorEventNoInternetConnection),
        @(OGAShowErrorEventWebviewTerminatedByOS),
        @(OGASKNetworkShowErrorEventFailedToStartImpression),
        @(OGASKNetworkShowErrorEventFailedToStopImpression)
    ];

    for (int index = 0; index < allEvents.count; index++) {
        OGAMonitoringEvent event = (OGAMonitoringEvent)allEvents[index].intValue;
        OGAMonitorEventConfiguration *eventConfiguration = [self.configurationFactory configurationFor:event];
        XCTAssertEqualObjects(eventConfiguration.eventCode,
                              [self.eventFormatter eventCodeFromEvent:event],
                              @"testing eventCode for %ld",
                              (long)event);

        XCTAssertEqualObjects(eventConfiguration.eventName,
                              [self.eventFormatter eventNameFromEvent:event],
                              @"testing eventName for %ld",
                              (long)event);

        XCTAssertEqualObjects(eventConfiguration.errorType,
                              [self.eventFormatter errorTypeFromEvent:event],
                              @"testing errorType for %ld",
                              (long)event);

        XCTAssertEqualObjects(eventConfiguration.errorDescription,
                              [self.eventFormatter errorDescriptionFromEvent:event],
                              @"testing errorDescription for %ld",
                              (long)event);

        XCTAssertEqual((eventConfiguration.permissionMask & OGAAdIdMaskCampaignId) != 0,
                       [self.eventPermissionHandler canSendCampaignIdFor:event],
                       @"testing permission for %ld",
                       (long)event);
        XCTAssertEqual((eventConfiguration.permissionMask & OGAAdIdMaskCreativeId) != 0,
                       [self.eventPermissionHandler canSendCreativeIdFor:event],
                       @"testing permission for %ld",
                       (long)event);
        XCTAssertEqual((eventConfiguration.permissionMask & OGAAdIdMaskExtras) != 0,
                       [self.eventPermissionHandler canSendExtrasFor:event],
                       @"testing permission for %ld",
                       (long)event);
    }
}

@end
