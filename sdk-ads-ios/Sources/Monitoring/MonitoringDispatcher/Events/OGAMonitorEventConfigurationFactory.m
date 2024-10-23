//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import "OGAMonitorEventConfigurationFactory.h"

@interface OGAMonitorEventConfigurationFactory ()
- (instancetype)init;
@property(nonatomic, retain) NSDictionary<NSNumber *, OGAMonitorEventConfiguration *> *eventConfigurations;
@end

@implementation OGAMonitorEventConfigurationFactory

- (instancetype)init {
    if (self = [super init]) {
        _eventConfigurations = @{
#pragma mark - Load
            @(OGALoadEventLoad) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LI-001"
                                                              eventName:@"SDK_EVENT_LOAD"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadEventLoadSendAdSyncRequest) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LI-002"
                                                              eventName:@"SDK_EVENT_SEND_ADSYNC_REQUEST"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadEventLoadAdSyncResponseReceived) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LI-003"
                                                              eventName:@"SDK_EVENT_ADSYNC_RESPONSE_RECEIVED"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadEventLoadAdPrecache) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LI-004"
                                                              eventName:@"SDK_EVENT_PRECACHE"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGALoadEventLoadAdPrecaching) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LI-005"
                                                              eventName:@"SDK_EVENT_AD_PRECACHING"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGALoadEventMraidRequest) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LI-014"
                                                              eventName:@"SDK_EVENT_MRAID_REQUEST"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGALoadEventLoadAdPrecachedInWebview) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LI-006"
                                                              eventName:@"SDK_EVENT_AD_PRECACHED_IN_WEBVIEW"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGALoadEventLoadAdPrecachedOnFormat) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LI-007"
                                                              eventName:@"SDK_EVENT_AD_PRECACHED_ON_FORMAT"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGALoadEventLoadAdPrecached) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LI-008"
                                                              eventName:@"SDK_EVENT_AD_PRECACHED"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGALoadEventLoadAdLoaded) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LI-009"
                                                              eventName:@"SDK_EVENT_LOADED"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGALoadEventLoadAdBackgroundUnloaded) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LI-010"
                                                              eventName:@"SDK_EVENT_BACKGROUND_UNLOAD"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGALoadEventWebviewTerminatedByOS) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LI-011"
                                                              eventName:@"SDK_LOAD_EVENT_WEBVIEW_TERMINATED"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGALoadEventAdParseStarted) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LI-012"
                                                              eventName:@"SDK_EVENT_AD_PARSING"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadEventAdParseEnded) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LI-013"
                                                              eventName:@"SDK_EVENT_AD_PARSED"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
#pragma mark - Load SKNetwork
            @(OGASKNetworkLoadEventStoreViewControllerLoading) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LUI-001"
                                                              eventName:@"SDK_EVENT_UA_STORE_CONTROLLER_LOADING"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGASKNetworkLoadEventStoreViewControllerLoaded) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LUI-002"
                                                              eventName:@"SDK_EVENT_UA_STORE_CONTROLLER_LOADED"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LUI-003"
                                                              eventName:@"SDK_EVENT_UA_INCOMPATIBLE_IOS_VERSION_FOR_STORE_CONTROLLER"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
#pragma mark - Load Error
            @(OGALoadErrorEventNoInternetConnection) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-001"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"CONDITIONS_NOT_MET"
                                                       errorDescription:@"No Internet connection"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadErrorEventInitFail) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-015"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"INIT_ERROR"
                                                       errorDescription:@"The SDK failed while initializing"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadErrorEventSdkNotInitialized) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-015"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"INIT_ERROR"
                                                       errorDescription:@"SDK not initialized"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadErrorEventSdkNeverInitialized) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-015"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"INIT_ERROR"
                                                       errorDescription:@"SDK never initialized (asset key not found)"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadErrorEventSdkInitFailed) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-015"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"INIT_ERROR"
                                                       errorDescription:@"SDK initialization failed"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadErrorEventEmptyAssetKey) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-015"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"INIT_ERROR"
                                                       errorDescription:@"Asset not initialized (asset key empty)"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadErrorEventProfigFailToSync) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-016"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"PROFIG_ERROR"
                                                       errorDescription:@"SDK configuration synchronization failed"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadErrorEventProfigIsNull) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-016"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"PROFIG_ERROR"
                                                       errorDescription:@"SDK configuration is not synced"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadErrorEventAdDisabled) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-008"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"CONFIG_RESTRICTIONS"
                                                       errorDescription:@"Ad disabled"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadErrorEventAdSyncRequestFail) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-009"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"ADSYNC_ERROR"
                                                       errorDescription:@"Request failed"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadErrorEventNoFill) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-011"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"ADSYNC_ERROR"
                                                       errorDescription:@"No ad received"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadErrorEventConfigurationError) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-016"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"PROFIG_ERROR"
                                                       errorDescription:@"SDK configuration failed"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadErrorEventAdParsingError) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-017"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"AD_PARSING_ERROR"
                                                       errorDescription:@"Ad response parsing has failed"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadErrorEventAdMarkUpParsingError) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-017"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"AD_PARSING_ERROR"
                                                       errorDescription:@"Ad markup parsing has failed"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGALoadErrorEventPrecacheError) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-018"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"PRECACHE_ERROR"
                                                       errorDescription:@""  // will be filled by the various calls
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGALoadErrorEventCallError) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LE-019"
                                                              eventName:@"SDK_EVENT_LOAD_ERROR"
                                                              errorType:@"CALL_ERROR"
                                                       errorDescription:@"Load ignored"
                                                         permissionMask:OGAAdIdMaskNone],
#pragma mark - Load Error SKNetwork
            @(OGASKNetworkLoadErrorEventFailedLoadingStoreController) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"LUE-001"
                                                              eventName:@"SDK_EVENT_UA_LOAD_ERROR"
                                                              errorType:@"FAILED_TO_LOAD_STORE_CONTROLLER"
                                                       errorDescription:@"Error during presentation of StoreKit"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
#pragma mark - Show
            @(OGAShowEventShow) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-001"
                                                              eventName:@"SDK_EVENT_SHOW"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventDisplay) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-002"
                                                              eventName:@"SDK_EVENT_DISPLAY"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventDisplaying) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-003"
                                                              eventName:@"SDK_EVENT_AD_DISPLAYING"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventContainerDisplayed) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-004"
                                                              eventName:@"SDK_EVENT_AD_CONTAINER_DISPLAYED"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventCreativeDisplayed) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-005"
                                                              eventName:@"SDK_EVENT_AD_CREATIVE_DISPLAYED"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventDisplayed) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-006"
                                                              eventName:@"SDK_EVENT_AD_DISPLAYED"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventImpression) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-007"
                                                              eventName:@"SDK_EVENT_AD_IMPRESSION"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventAdClicked) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-008"
                                                              eventName:@"SDK_EVENT_AD_CLICKED"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventOpenLandingPage) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-009"
                                                              eventName:@"SDK_EVENT_AD_OPEN_LANDING_PAGE"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventLandingPageOpened) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-010"
                                                              eventName:@"SDK_EVENT_AD_LANDING_PAGE_OPENED"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventCloseLandingPage) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-011"
                                                              eventName:@"SDK_EVENT_AD_CLOSE_LANDING_PAGE"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventLandingPageClosed) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-012"
                                                              eventName:@"SDK_EVENT_AD_LANDING_PAGE_CLOSED"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventAdClose) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-013"
                                                              eventName:@"SDK_EVENT_AD_CLOSED"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventLauchBrowser) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-014"
                                                              eventName:@"SDK_EVENT_LAUNCH_BROSWER"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventForegroundUnload) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-015"
                                                              eventName:@"SDK_EVENT_FOREGROUND_UNLOAD"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowEventWebviewTerminatedByOS) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SI-017"
                                                              eventName:@"SDK_SHOW_EVENT_WEBVIEW_TERMINATED"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],

#pragma mark - Show SKNetwork
            @(OGASKNetworkShowEventStartingImpression) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SUI-001"
                                                              eventName:@"SDK_EVENT_UA_STARTING_IMPRESSION"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGASKNetworkShowEventStartImpression) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SUI-002"
                                                              eventName:@"SDK_EVENT_UA_START_IMPRESSION"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGASKNetworkShowEventStoppingImpression) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SUI-003"
                                                              eventName:@"SDK_EVENT_UA_STOPPING_IMPRESSION"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGASKNetworkShowEventStopImpression) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SUI-004"
                                                              eventName:@"SDK_EVENT_UA_STOP_IMPRESSION"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SUI-005"
                                                              eventName:@"SDK_EVENT_UA_INCOMPATIBLE_IOS_VERSION_TO_START_IMPRESSION"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGASKNetworkShowEventIncompatibleIOSVersionToStopImpression) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SUI-006"
                                                              eventName:@"SDK_EVENT_UA_INCOMPATIBLE_IOS_VERSION_TO_STOP_IMPRESSION"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
#pragma mark - Show Error
            @(OGAShowErrorEventAdDisabled) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SE-001"
                                                              eventName:@"SDK_EVENT_SHOW_ERROR"
                                                              errorType:@"CONFIG_RESTRICTIONS"
                                                       errorDescription:@"Ad disabled"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGAShowErrorEventAdExpired) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SE-002"
                                                              eventName:@"SDK_EVENT_SHOW_ERROR"
                                                              errorType:@"CONFIG_RESTRICTIONS"
                                                       errorDescription:@"Ad expired"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowErrorEventSdkNotInitialized) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SE-003"
                                                              eventName:@"SDK_EVENT_SHOW_ERROR"
                                                              errorType:@"INIT_ERROR"
                                                       errorDescription:@"SDK not initialized"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGAShowErrorEventSdkNeverInitialized) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SE-003"
                                                              eventName:@"SDK_EVENT_SHOW_ERROR"
                                                              errorType:@"INIT_ERROR"
                                                       errorDescription:@"SDK never initialized (asset key not found)"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGAShowErrorEventNoAdLoaded) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SE-004"
                                                              eventName:@"SDK_EVENT_SHOW_ERROR"
                                                              errorType:@"PRECACHE_ERROR"
                                                       errorDescription:@"No ad loaded"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGAShowErrorEventProfigNotSync) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SE-006"
                                                              eventName:@"SDK_EVENT_SHOW_ERROR"
                                                              errorType:@"PROFIG_ERROR"
                                                       errorDescription:@"SDK configuration is not sync"
                                                         permissionMask:OGAAdIdMaskNone],
            @(OGAShowErrorEventViewInBackground) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SE-008"
                                                              eventName:@"SDK_EVENT_SHOW_ERROR"
                                                              errorType:@"CONDITIONS_NOT_MET"
                                                       errorDescription:@"View in background"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowErrorEventAnotherAdAlreadyDisplayed) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SE-009"
                                                              eventName:@"SDK_EVENT_SHOW_ERROR"
                                                              errorType:@"CONDITIONS_NOT_MET"
                                                       errorDescription:@"Another ad already displayed"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowErrorEventNoInternetConnection) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SE-010"
                                                              eventName:@"SDK_EVENT_SHOW_ERROR"
                                                              errorType:@"CONDITIONS_NOT_MET"
                                                       errorDescription:@"No Internet connection"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGAShowErrorEventWebviewTerminatedByOS) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SE-011"
                                                              eventName:@"SDK_EVENT_SHOW_ERROR"
                                                              errorType:@"CONDITIONS_NOT_MET"
                                                       errorDescription:@"Webview terminated by the OS"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
#pragma mark - Show Error SKNetwork
            @(OGASKNetworkShowErrorEventFailedToStartImpression) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SUE-001"
                                                              eventName:@"SDK_EVENT_UA_SHOW_ERROR"
                                                              errorType:@"UA_FAILED_TO_START_IMPRESSION"
                                                       errorDescription:@"Failed to notify StoreKit of starting the impression"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
            @(OGASKNetworkShowErrorEventFailedToStopImpression) :
                [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"SUE-002"
                                                              eventName:@"SDK_EVENT_UA_SHOW_ERROR"
                                                              errorType:@"UA_FAILED_TO_STOP_IMPRESSION"
                                                       errorDescription:@"Failed to notify StoreKit of ending the impression"
                                                         permissionMask:OGAAdIdMaskCampaignId | OGAAdIdMaskCreativeId | OGAAdIdMaskExtras],
        };
    }
    return self;
}

+ (instancetype)shared {
    static OGAMonitorEventConfigurationFactory *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[OGAMonitorEventConfigurationFactory alloc] init];
    });
    return instance;
}

- (OGAMonitorEventConfiguration *)configurationFor:(OGAMonitoringEvent)event {
    return [self.eventConfigurations objectForKey:@(event)];
}

@end
