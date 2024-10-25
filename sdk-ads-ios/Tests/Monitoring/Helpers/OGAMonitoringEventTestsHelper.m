//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGAMonitoringEventTestsHelper.h"
#import <Foundation/Foundation.h>

@implementation OGAMonitoringEventTestsHelper

#pragma mark Monitoring Event Converting Methods

- (NSString *)eventCodeFromEvent:(OGAMonitoringEvent)event {
    switch (event) {
            // Load
        case OGALoadEventLoad:
            return @"LI-001";
        case OGALoadEventLoadSendAdSyncRequest:
            return @"LI-002";
        case OGALoadEventLoadAdSyncResponseReceived:
            return @"LI-003";
        case OGALoadEventLoadAdPrecache:
            return @"LI-004";
        case OGALoadEventLoadAdPrecaching:
            return @"LI-005";
        case OGALoadEventMraidRequest:
            return @"LI-014";
        case OGALoadEventLoadAdPrecachedInWebview:
            return @"LI-006";
        case OGALoadEventLoadAdPrecachedOnFormat:
            return @"LI-007";
        case OGALoadEventLoadAdPrecached:
            return @"LI-008";
        case OGALoadEventLoadAdLoaded:
            return @"LI-009";
        case OGALoadEventLoadAdBackgroundUnloaded:
            return @"LI-010";
        case OGALoadEventWebviewTerminatedByOS:
            return @"LI-011";
        case OGALoadEventAdParseStarted:
            return @"LI-012";
        case OGALoadEventAdParseEnded:
            return @"LI-013";

            // Load SKNetwork
        case OGASKNetworkLoadEventStoreViewControllerLoading:
            return @"LUI-001";
        case OGASKNetworkLoadEventStoreViewControllerLoaded:
            return @"LUI-002";
        case OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion:
            return @"LUI-003";

            // Load Error
        case OGALoadErrorEventNoInternetConnection:
            return @"LE-001";
        case OGALoadErrorEventInitFail:
            return @"LE-015";
        case OGALoadErrorEventSdkNotInitialized:
            return @"LE-015";
        case OGALoadErrorEventSdkInitFailed:
            return @"LE-015";
        case OGALoadErrorEventEmptyAssetKey:
            return @"LE-015";
        case OGALoadErrorEventProfigFailToSync:
            return @"LE-016";
        case OGALoadErrorEventProfigIsNull:
            return @"LE-016";
        case OGALoadErrorEventConfigurationError:
            return @"LE-015";
        case OGALoadErrorEventAdDisabled:
            return @"LE-008";
        case OGALoadErrorEventAdSyncRequestFail:
            return @"LE-009";
        case OGALoadErrorEventNoFill:
            return @"LE-011";
        case OGALoadErrorEventPrecacheError:
            return @"LE-018";
        case OGALoadErrorEventSdkNeverInitialized:
            return @"LE-015";
        case OGALoadErrorEventAdParsingError:
        case OGALoadErrorEventAdMarkUpParsingError:
            return @"LE-017";
        case OGALoadErrorEventCallError:
            return @"LE-019";

            // Load Error SKNetwork
        case OGASKNetworkLoadErrorEventFailedLoadingStoreController:
            return @"LUE-001";

            // Show
        case OGAShowEventShow:
            return @"SI-001";
        case OGAShowEventDisplay:
            return @"SI-002";
        case OGAShowEventDisplaying:
            return @"SI-003";
        case OGAShowEventContainerDisplayed:
            return @"SI-004";
        case OGAShowEventCreativeDisplayed:
            return @"SI-005";
        case OGAShowEventDisplayed:
            return @"SI-006";
        case OGAShowEventImpression:
            return @"SI-007";
        case OGAShowEventAdClicked:
            return @"SI-008";
        case OGAShowEventOpenLandingPage:
            return @"SI-009";
        case OGAShowEventLandingPageOpened:
            return @"SI-010";
        case OGAShowEventCloseLandingPage:
            return @"SI-011";
        case OGAShowEventLandingPageClosed:
            return @"SI-012";
        case OGAShowEventAdClose:
            return @"SI-013";
        case OGAShowEventLauchBrowser:
            return @"SI-014";
        case OGAShowEventForegroundUnload:
            return @"SI-015";
        case OGAShowEventWebviewTerminatedByOS:
            return @"SI-017";
            // Show SKNetwork
        case OGASKNetworkShowEventStartingImpression:
            return @"SUI-001";
        case OGASKNetworkShowEventStartImpression:
            return @"SUI-002";
        case OGASKNetworkShowEventStoppingImpression:
            return @"SUI-003";
        case OGASKNetworkShowEventStopImpression:
            return @"SUI-004";
        case OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression:
            return @"SUI-005";
        case OGASKNetworkShowEventIncompatibleIOSVersionToStopImpression:
            return @"SUI-006";

            // Show Error
        case OGAShowErrorEventAdDisabled:
            return @"SE-001";
        case OGAShowErrorEventAdExpired:
            return @"SE-002";
        case OGAShowErrorEventSdkNotInitialized:
            return @"SE-003";
        case OGAShowErrorEventSdkNeverInitialized:
            return @"SE-003";
        case OGAShowErrorEventNoAdLoaded:
            return @"SE-004";
        case OGAShowErrorEventProfigNotSync:
            return @"SE-006";
        case OGAShowErrorEventViewInBackground:
            return @"SE-008";
        case OGAShowErrorEventAnotherAdAlreadyDisplayed:
            return @"SE-009";
        case OGAShowErrorEventNoInternetConnection:
            return @"SE-010";
        case OGAShowErrorEventWebviewTerminatedByOS:
            return @"SE-011";

            // Show Error SKNetwork
        case OGASKNetworkShowErrorEventFailedToStartImpression:
            return @"SUE-001";
        case OGASKNetworkShowErrorEventFailedToStopImpression:
            return @"SUE-002";
    }
}

- (NSString *)eventNameFromEvent:(OGAMonitoringEvent)event {
    switch (event) {
            // Load
        case OGALoadEventLoad:
            return @"SDK_EVENT_LOAD";
        case OGALoadEventLoadSendAdSyncRequest:
            return @"SDK_EVENT_SEND_ADSYNC_REQUEST";
        case OGALoadEventLoadAdSyncResponseReceived:
            return @"SDK_EVENT_ADSYNC_RESPONSE_RECEIVED";
        case OGALoadEventLoadAdPrecache:
            return @"SDK_EVENT_PRECACHE";
        case OGALoadEventLoadAdPrecaching:
            return @"SDK_EVENT_AD_PRECACHING";
        case OGALoadEventMraidRequest:
            return @"SDK_EVENT_MRAID_REQUEST";
        case OGALoadEventLoadAdPrecachedInWebview:
            return @"SDK_EVENT_AD_PRECACHED_IN_WEBVIEW";
        case OGALoadEventLoadAdPrecachedOnFormat:
            return @"SDK_EVENT_AD_PRECACHED_ON_FORMAT";
        case OGALoadEventLoadAdPrecached:
            return @"SDK_EVENT_AD_PRECACHED";
        case OGALoadEventLoadAdLoaded:
            return @"SDK_EVENT_LOADED";
        case OGALoadEventLoadAdBackgroundUnloaded:
            return @"SDK_EVENT_BACKGROUND_UNLOAD";
        case OGALoadEventWebviewTerminatedByOS:
            return @"SDK_LOAD_EVENT_WEBVIEW_TERMINATED";
        case OGALoadEventAdParseStarted:
            return @"SDK_EVENT_AD_PARSING";
        case OGALoadEventAdParseEnded:
            return @"SDK_EVENT_AD_PARSED";

            // Load SKNetwork
        case OGASKNetworkLoadEventStoreViewControllerLoading:
            return @"SDK_EVENT_UA_STORE_CONTROLLER_LOADING";
        case OGASKNetworkLoadEventStoreViewControllerLoaded:
            return @"SDK_EVENT_UA_STORE_CONTROLLER_LOADED";
        case OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion:
            return @"SDK_EVENT_UA_INCOMPATIBLE_IOS_VERSION_FOR_STORE_CONTROLLER";

            // Load Error
        case OGALoadErrorEventNoInternetConnection:
        case OGALoadErrorEventInitFail:
        case OGALoadErrorEventSdkNotInitialized:
        case OGALoadErrorEventSdkInitFailed:
        case OGALoadErrorEventEmptyAssetKey:
        case OGALoadErrorEventProfigFailToSync:
        case OGALoadErrorEventProfigIsNull:
        case OGALoadErrorEventAdDisabled:
        case OGALoadErrorEventAdSyncRequestFail:
        case OGALoadErrorEventAdParsingError:
        case OGALoadErrorEventNoFill:
        case OGALoadErrorEventAdMarkUpParsingError:
        case OGALoadErrorEventPrecacheError:
        case OGALoadErrorEventCallError:
        case OGALoadErrorEventConfigurationError:
        case OGALoadErrorEventSdkNeverInitialized:
            return @"SDK_EVENT_LOAD_ERROR";

            // Load Error SKNetwork
        case OGASKNetworkLoadErrorEventFailedLoadingStoreController:
            return @"SDK_EVENT_UA_LOAD_ERROR";

            // Show
        case OGAShowEventShow:
            return @"SDK_EVENT_SHOW";
        case OGAShowEventDisplay:
            return @"SDK_EVENT_DISPLAY";
        case OGAShowEventDisplaying:
            return @"SDK_EVENT_AD_DISPLAYING";
        case OGAShowEventContainerDisplayed:
            return @"SDK_EVENT_AD_CONTAINER_DISPLAYED";
        case OGAShowEventCreativeDisplayed:
            return @"SDK_EVENT_AD_CREATIVE_DISPLAYED";
        case OGAShowEventDisplayed:
            return @"SDK_EVENT_AD_DISPLAYED";
        case OGAShowEventImpression:
            return @"SDK_EVENT_AD_IMPRESSION";
        case OGAShowEventAdClicked:
            return @"SDK_EVENT_AD_CLICKED";
        case OGAShowEventOpenLandingPage:
            return @"SDK_EVENT_AD_OPEN_LANDING_PAGE";
        case OGAShowEventLandingPageOpened:
            return @"SDK_EVENT_AD_LANDING_PAGE_OPENED";
        case OGAShowEventCloseLandingPage:
            return @"SDK_EVENT_AD_CLOSE_LANDING_PAGE";
        case OGAShowEventLandingPageClosed:
            return @"SDK_EVENT_AD_LANDING_PAGE_CLOSED";
        case OGAShowEventAdClose:
            return @"SDK_EVENT_AD_CLOSED";
        case OGAShowEventLauchBrowser:
            return @"SDK_EVENT_LAUNCH_BROSWER";
        case OGAShowEventForegroundUnload:
            return @"SDK_EVENT_FOREGROUND_UNLOAD";
        case OGAShowEventWebviewTerminatedByOS:
            return @"SDK_SHOW_EVENT_WEBVIEW_TERMINATED";

            // Show SKNetwork
        case OGASKNetworkShowEventStartingImpression:
            return @"SDK_EVENT_UA_STARTING_IMPRESSION";
        case OGASKNetworkShowEventStartImpression:
            return @"SDK_EVENT_UA_START_IMPRESSION";
        case OGASKNetworkShowEventStoppingImpression:
            return @"SDK_EVENT_UA_STOPPING_IMPRESSION";
        case OGASKNetworkShowEventStopImpression:
            return @"SDK_EVENT_UA_STOP_IMPRESSION";
        case OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression:
            return @"SDK_EVENT_UA_INCOMPATIBLE_IOS_VERSION_TO_START_IMPRESSION";
        case OGASKNetworkShowEventIncompatibleIOSVersionToStopImpression:
            return @"SDK_EVENT_UA_INCOMPATIBLE_IOS_VERSION_TO_STOP_IMPRESSION";

            // Show Error
        case OGAShowErrorEventAdDisabled:
        case OGAShowErrorEventAdExpired:
        case OGAShowErrorEventSdkNotInitialized:
        case OGAShowErrorEventSdkNeverInitialized:
        case OGAShowErrorEventNoAdLoaded:
        case OGAShowErrorEventProfigNotSync:
        case OGAShowErrorEventViewInBackground:
        case OGAShowErrorEventAnotherAdAlreadyDisplayed:
        case OGAShowErrorEventNoInternetConnection:
        case OGAShowErrorEventWebviewTerminatedByOS:
            return @"SDK_EVENT_SHOW_ERROR";

            // Show Error SKNetwork
        case OGASKNetworkShowErrorEventFailedToStartImpression:
        case OGASKNetworkShowErrorEventFailedToStopImpression:
            return @"SDK_EVENT_UA_SHOW_ERROR";
            break;
    }
}

- (NSString *)errorTypeFromEvent:(OGAMonitoringEvent)event {
    switch (event) {
            // Load
        case OGALoadEventLoad:
        case OGALoadEventLoadSendAdSyncRequest:
        case OGALoadEventLoadAdSyncResponseReceived:
        case OGALoadEventLoadAdPrecache:
        case OGALoadEventLoadAdPrecaching:
        case OGALoadEventMraidRequest:
        case OGALoadEventLoadAdPrecachedInWebview:
        case OGALoadEventLoadAdPrecachedOnFormat:
        case OGALoadEventLoadAdPrecached:
        case OGALoadEventLoadAdLoaded:
        case OGALoadEventLoadAdBackgroundUnloaded:
        case OGALoadEventWebviewTerminatedByOS:
        case OGALoadEventAdParseStarted:
        case OGALoadEventAdParseEnded:
            return nil;

            // Load SKNetwork
        case OGASKNetworkLoadEventStoreViewControllerLoading:
        case OGASKNetworkLoadEventStoreViewControllerLoaded:
        case OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion:
            return nil;

            // Load Error
        case OGALoadErrorEventNoInternetConnection:
            return @"CONDITIONS_NOT_MET";
        case OGALoadErrorEventInitFail:
        case OGALoadErrorEventSdkNotInitialized:
        case OGALoadErrorEventSdkInitFailed:
        case OGALoadErrorEventEmptyAssetKey:
        case OGALoadErrorEventSdkNeverInitialized:
            return @"INIT_ERROR";
        case OGALoadErrorEventProfigFailToSync:
        case OGALoadErrorEventProfigIsNull:
            return @"PROFIG_ERROR";
        case OGALoadErrorEventConfigurationError:
            return @"PROFIG_INIT_ERROR";
        case OGALoadErrorEventAdDisabled:
            return @"CONFIG_RESTRICTIONS";
        case OGALoadErrorEventAdSyncRequestFail:
        case OGALoadErrorEventNoFill:
            return @"ADSYNC_ERROR";
        case OGALoadErrorEventAdParsingError:
        case OGALoadErrorEventAdMarkUpParsingError:
            return @"AD_PARSING_ERROR";
        case OGALoadErrorEventPrecacheError:
            return @"PRECACHE_ERROR";
        case OGALoadErrorEventCallError:
            return @"CALL_ERROR";

            // Load Error SKNetwork
        case OGASKNetworkLoadErrorEventFailedLoadingStoreController:
            return @"FAILED_TO_LOAD_STORE_CONTROLLER";

            // Show
        case OGAShowEventShow:
        case OGAShowEventDisplay:
        case OGAShowEventDisplaying:
        case OGAShowEventContainerDisplayed:
        case OGAShowEventCreativeDisplayed:
        case OGAShowEventDisplayed:
        case OGAShowEventImpression:
        case OGAShowEventAdClicked:
        case OGAShowEventOpenLandingPage:
        case OGAShowEventLandingPageOpened:
        case OGAShowEventCloseLandingPage:
        case OGAShowEventLandingPageClosed:
        case OGAShowEventAdClose:
        case OGAShowEventLauchBrowser:
        case OGAShowEventForegroundUnload:
        case OGAShowEventWebviewTerminatedByOS:
            return nil;

            // Show SKNetwork
        case OGASKNetworkShowEventStartingImpression:
        case OGASKNetworkShowEventStartImpression:
        case OGASKNetworkShowEventStoppingImpression:
        case OGASKNetworkShowEventStopImpression:
        case OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression:
        case OGASKNetworkShowEventIncompatibleIOSVersionToStopImpression:
            return nil;

            // Show Error
        case OGAShowErrorEventAdDisabled:
        case OGAShowErrorEventAdExpired:
            return @"CONFIG_RESTRICTIONS";
        case OGAShowErrorEventSdkNotInitialized:
        case OGAShowErrorEventSdkNeverInitialized:
            return @"INIT_ERROR";
        case OGAShowErrorEventNoAdLoaded:
            return @"PRECACHE_ERROR";
        case OGAShowErrorEventProfigNotSync:
            return @"PROFIG_ERROR";
        case OGAShowErrorEventViewInBackground:
        case OGAShowErrorEventAnotherAdAlreadyDisplayed:
        case OGAShowErrorEventNoInternetConnection:
        case OGAShowErrorEventWebviewTerminatedByOS:
            return @"CONDITIONS_NOT_MET";

            // Show Error SKNetwork
        case OGASKNetworkShowErrorEventFailedToStartImpression:
            return @"UA_FAILED_TO_START_IMPRESSION";
        case OGASKNetworkShowErrorEventFailedToStopImpression:
            return @"UA_FAILED_TO_STOP_IMPRESSION";
    }
}

- (NSString *)errorDescriptionFromEvent:(OGAMonitoringEvent)event {
    switch (event) {
            // Load
        case OGALoadEventLoad:
        case OGALoadEventLoadSendAdSyncRequest:
        case OGALoadEventLoadAdSyncResponseReceived:
        case OGALoadEventLoadAdPrecache:
        case OGALoadEventLoadAdPrecaching:
        case OGALoadEventMraidRequest:
        case OGALoadEventLoadAdPrecachedInWebview:
        case OGALoadEventLoadAdPrecachedOnFormat:
        case OGALoadEventLoadAdPrecached:
        case OGALoadEventLoadAdLoaded:
        case OGALoadEventLoadAdBackgroundUnloaded:
        case OGALoadEventWebviewTerminatedByOS:
        case OGALoadEventAdParseStarted:
        case OGALoadEventAdParseEnded:
            return nil;

            // Load SKNetwork
        case OGASKNetworkLoadEventStoreViewControllerLoading:
        case OGASKNetworkLoadEventStoreViewControllerLoaded:
        case OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion:
            return nil;

            // Load Error
        case OGALoadErrorEventNoInternetConnection:
            return @"No Internet connection";
        case OGALoadErrorEventInitFail:
            return @"The SDK failed while initializing";
        case OGALoadErrorEventSdkNotInitialized:
            return @"SDK not initialized";
        case OGALoadErrorEventSdkInitFailed:
            return @"SDK initialization failed";
        case OGALoadErrorEventSdkNeverInitialized:
            return @"SDK never initialized (asset key not found)";
        case OGALoadErrorEventEmptyAssetKey:
            return @"Asset not initialized (asset key empty)";
        case OGALoadErrorEventProfigFailToSync:
            return @"SDK configuration synchronization failed";
        case OGALoadErrorEventProfigIsNull:
            return @"SDK configuration is not synced";
        case OGALoadErrorEventAdDisabled:
            return @"Ad disabled";
        case OGALoadErrorEventAdSyncRequestFail:
            return @"Request failed";
        case OGALoadErrorEventAdParsingError:
            return @"Ad response parsing has failed";
        case OGALoadErrorEventNoFill:
            return @"No ad received";
        case OGALoadErrorEventAdMarkUpParsingError:
            return @"Ad markup parsing has failed";
        case OGALoadErrorEventPrecacheError:
            return @"";
        case OGALoadErrorEventCallError:
            return @"Load ignored";
        case OGALoadErrorEventConfigurationError:
            return @"Load ignored";

            // Load Error
        case OGASKNetworkLoadErrorEventFailedLoadingStoreController:
            return @"Error during presentation of StoreKit";

            // Show
        case OGAShowEventShow:
        case OGAShowEventDisplay:
        case OGAShowEventDisplaying:
        case OGAShowEventContainerDisplayed:
        case OGAShowEventCreativeDisplayed:
        case OGAShowEventDisplayed:
        case OGAShowEventImpression:
        case OGAShowEventAdClicked:
        case OGAShowEventOpenLandingPage:
        case OGAShowEventLandingPageOpened:
        case OGAShowEventCloseLandingPage:
        case OGAShowEventLandingPageClosed:
        case OGAShowEventAdClose:
        case OGAShowEventLauchBrowser:
        case OGAShowEventForegroundUnload:
        case OGAShowEventWebviewTerminatedByOS:
            return nil;

            // Show SKNetwork
        case OGASKNetworkShowEventStartingImpression:
        case OGASKNetworkShowEventStartImpression:
        case OGASKNetworkShowEventStoppingImpression:
        case OGASKNetworkShowEventStopImpression:
        case OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression:
        case OGASKNetworkShowEventIncompatibleIOSVersionToStopImpression:
            return nil;

            // Show Error
        case OGAShowErrorEventAdDisabled:
            return @"Ad disabled";
        case OGAShowErrorEventAdExpired:
            return @"Ad expired";
        case OGAShowErrorEventSdkNotInitialized:
            return @"SDK not initialized";
        case OGAShowErrorEventSdkNeverInitialized:
            return @"SDK never initialized (asset key not found)";
        case OGAShowErrorEventNoAdLoaded:
            return @"No ad loaded";
        case OGAShowErrorEventProfigNotSync:
            return @"SDK configuration is not sync";
        case OGAShowErrorEventViewInBackground:
            return @"View in background";
        case OGAShowErrorEventAnotherAdAlreadyDisplayed:
            return @"Another ad already displayed";
        case OGAShowErrorEventNoInternetConnection:
            return @"No Internet connection";
        case OGAShowErrorEventWebviewTerminatedByOS:
            return @"Webview terminated by the OS";

            // Show Error SKNetwork
        case OGASKNetworkShowErrorEventFailedToStartImpression:
            return @"Failed to notify StoreKit of starting the impression";
        case OGASKNetworkShowErrorEventFailedToStopImpression:
            return @"Failed to notify StoreKit of ending the impression";
    }
}

@end
