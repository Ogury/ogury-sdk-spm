//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import "OGAMonitoringEventPermissionTestsHelper.h"

@implementation OGAMonitoringEventPermissionTestsHelper

- (OGAAdIdMask)adIdMaskForEvent:(OGAMonitoringEvent)event {
    OGAAdIdMask adIdMask = OGAAdIdMaskNone;
    switch (event) {
            // Load
        case OGALoadEventLoad:
        case OGALoadEventLoadSendAdSyncRequest:
        case OGALoadEventLoadAdSyncResponseReceived:
            return adIdMask;
        case OGALoadEventLoadAdPrecache:
        case OGALoadEventLoadAdPrecaching:
        case OGALoadEventLoadAdPrecachedInWebview:
        case OGALoadEventLoadAdPrecachedOnFormat:
        case OGALoadEventMraidRequest:
        case OGALoadEventLoadAdPrecached:
            return adIdMask |= OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras;
        case OGALoadEventLoadAdLoaded:
        case OGALoadEventLoadAdBackgroundUnloaded:
        case OGALoadEventWebviewTerminatedByOS:
            return adIdMask |= OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras;
        case OGALoadEventAdParseStarted:
            return adIdMask;
        case OGALoadEventAdParseEnded:
            return adIdMask |= OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras;

            // Load SKNetwork
        case OGASKNetworkLoadEventStoreViewControllerLoading:
        case OGASKNetworkLoadEventStoreViewControllerLoaded:
        case OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion:
            return adIdMask |= OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras;

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
        case OGALoadErrorEventSdkNeverInitialized:
        case OGALoadErrorEventConfigurationError:
            return adIdMask;
        case OGALoadErrorEventPrecacheError:
            return adIdMask |= OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras;
        case OGALoadErrorEventCallError:
            return adIdMask;

            // Load Error
        case OGASKNetworkLoadErrorEventFailedLoadingStoreController:
            return adIdMask |= OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras;

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
            return adIdMask |= OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras;

            // Show SKNetwork
        case OGASKNetworkShowEventStartingImpression:
        case OGASKNetworkShowEventStartImpression:
        case OGASKNetworkShowEventStoppingImpression:
        case OGASKNetworkShowEventStopImpression:
        case OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression:
        case OGASKNetworkShowEventIncompatibleIOSVersionToStopImpression:
            return adIdMask |= OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras;

            // Show Error
        case OGAShowErrorEventAdDisabled:
        case OGAShowErrorEventSdkNotInitialized:
        case OGAShowErrorEventSdkNeverInitialized:
        case OGAShowErrorEventNoAdLoaded:
        case OGAShowErrorEventProfigNotSync:
            return adIdMask;
        case OGAShowErrorEventNoInternetConnection:
        case OGAShowErrorEventAdExpired:
        case OGAShowErrorEventViewInBackground:
        case OGAShowErrorEventAnotherAdAlreadyDisplayed:
        case OGAShowErrorEventWebviewTerminatedByOS:
            return adIdMask |= OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras;

            // Show Error SKNetwork
        case OGASKNetworkShowErrorEventFailedToStartImpression:
        case OGASKNetworkShowErrorEventFailedToStopImpression:
            return adIdMask |= OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras;
    }
    return adIdMask;
}

- (BOOL)canSendCampaignIdFor:(OGAMonitoringEvent)event {
    OGAAdIdMask adIdMask = [self adIdMaskForEvent:event];
    return adIdMask & OGAAdIdMaskCampaignId;
}

- (BOOL)canSendCreativeIdFor:(OGAMonitoringEvent)event {
    OGAAdIdMask adIdMask = [self adIdMaskForEvent:event];
    return adIdMask & OGAAdIdMaskCreativeId;
}

- (BOOL)canSendExtrasFor:(OGAMonitoringEvent)event {
    OGAAdIdMask adIdMask = [self adIdMaskForEvent:event];
    return adIdMask & OGAAdIdMaskExtras;
}

@end
