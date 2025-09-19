//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Constants

extern NSString *const OGAAdMonitorEventBodyAdUnit;
extern NSString *const OGAAdMonitorEventBodyAdUnitId;
extern NSString *const OGAAdMonitorEventBodyMediation;
extern NSString *const OGAAdMonitorEventBodyMediationName;
extern NSString *const OGAAdMonitorEventBodyMediationVersion;
extern NSString *const OGAAdMonitorEventBodyAd;
extern NSString *const OGAAdMonitorEventBodyAdCampaignId;
extern NSString *const OGAAdMonitorEventBodyAdCreativeId;
extern NSString *const OGAAdMonitorEventBodyAdRequestedSize;
extern NSString *const OGAAdMonitorEventBodyAdCreativeSize;
extern NSString *const OGAAdMonitorEventBodyAdSizeWidth;
extern NSString *const OGAAdMonitorEventBodyAdSizeHeight;
extern NSString *const OGAAdMonitorEventBodyAdBanner;
extern NSString *const OGAAdMonitorEventBodyAdExtras;
extern NSString *const OGAMonitorEventBodyTimestamp;
extern NSString *const OGAMonitorEventBodySessionId;
extern NSString *const OGAMonitorEventBodyEventCode;
extern NSString *const OGAMonitorEventBodyEventName;
extern NSString *const OGAMonitorEventBodyDetails;
extern NSString *const OGAMonitorEventBodyDispatchMethod;
extern NSString *const OGAMonitorEventBodyDispatchMethodDeferred;
extern NSString *const OGAMonitorEventBodyDispatchMethodImmediate;
extern NSString *const OGAMonitorEventBodyReload;
extern NSString *const OGAMonitorEventBodyError;
extern NSString *const OGAMonitorEventBodyErrorType;
extern NSString *const OGAMonitorEventBodyErrorContent;
extern NSString *const OGAMonitoringEventDetailLoadedSource;
extern NSString *const OGAMonitoringEventDetailNbAdsToPrecache;
extern NSString *const OGAMonitoringEventDetailNbAdsLoaded;
extern NSString *const OGAMonitoringEventDetailFromAdMarkUp;
extern NSString *const OGAMonitoringEventDetailExposure;
extern NSString *const OGAMonitoringEventDetailImpressionSource;
extern NSString *const OGAMonitoringEventDetailWebviewTermination;
extern NSString *const OGAMonitoringEventContentAdExpired;
extern NSString *const OGAMonitoringEventContentExpirationSource;
extern NSString *const OGAMonitoringEventContentExpirationTimeSpan;
extern NSString *const OGAMonitoringErrorEventContentReason;
extern NSString *const OGAMonitoringErrorEventContentStacktrace;
extern NSString *const OGAMonitoringErrorEventContentExpirationSourceAd;
extern NSString *const OGAMonitoringErrorEventContentExpirationSourceProfig;
extern NSString *const OGAMonitoringEventDetailNonce;
extern NSString *const OGAMonitoringEventDetailItunesItemId;
extern NSString *const OGAMonitoringEventDetailAdvertisedAppStoreItemIdentifier;
extern NSString *const OGAMonitoringErrorEventContentAccomplished;
extern NSString *const OGAMonitoringErrorEventContentTimeSpan;
extern NSString *const OGAAdMonitorEventBodyMediationAdapterVersion;
extern NSString *const OGAMonitoringErrorEventContentTimeoutDuration;
extern NSString *const OGAMonitoringErrorEventContentUrl;
extern NSString *const OGAMonitoringErrorEventWebviewDidTerminateStackTrace;

#pragma mark Enums

typedef NS_ENUM(NSInteger, OGAMonitoringEvent) {

    // Load
    OGALoadEventLoad,
    OGALoadEventLoadSendAdSyncRequest,
    OGALoadEventLoadAdSyncResponseReceived,
    OGALoadEventLoadAdPrecache,
    OGALoadEventLoadAdPrecaching,
    OGALoadEventMraidRequest,
    OGALoadEventLoadAdPrecachedInWebview,
    OGALoadEventLoadAdPrecachedOnFormat,
    OGALoadEventLoadAdPrecached,
    OGALoadEventLoadAdLoaded,
    OGALoadEventLoadAdBackgroundUnloaded,
    OGALoadEventWebviewTerminatedByOS,
    OGALoadEventAdParseStarted,
    OGALoadEventAdParseEnded,

    // Load SKNetwork
    OGASKNetworkLoadEventStoreViewControllerLoading,
    OGASKNetworkLoadEventStoreViewControllerLoaded,
    OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion,

    // Load Error
    OGALoadErrorEventNoInternetConnection,
    OGALoadErrorEventInitFail,
    OGALoadErrorEventSdkNotInitialized,
    OGALoadErrorEventSdkNeverInitialized,
    OGALoadErrorEventSdkInitFailed,
    OGALoadErrorEventEmptyAssetKey,
    OGALoadErrorEventProfigFailToSync,
    OGALoadErrorEventProfigIsNull,
    OGALoadErrorEventConfigurationError,
    OGALoadErrorEventAdDisabled,
    OGALoadErrorEventAdSyncRequestFail,
    OGALoadErrorEventNoFill,
    OGALoadErrorEventAdParsingError,
    OGALoadErrorEventAdMarkUpParsingError,
    OGALoadErrorEventPrecacheError,
    OGALoadErrorEventCallError,

    // Load Error SKNetwork
    OGASKNetworkLoadErrorEventFailedLoadingStoreController,

    // Show
    OGAShowEventShow,
    OGAShowEventDisplay,
    OGAShowEventDisplaying,
    OGAShowEventContainerDisplayed,
    OGAShowEventCreativeDisplayed,
    OGAShowEventDisplayed,
    OGAShowEventImpression,
    OGAShowEventAdClicked,
    OGAShowEventOpenLandingPage,
    OGAShowEventLandingPageOpened,
    OGAShowEventCloseLandingPage,
    OGAShowEventLandingPageClosed,
    OGAShowEventAdClose,
    OGAShowEventLauchBrowser,
    OGAShowEventForegroundUnload,
    OGAShowEventWebviewTerminatedByOS,
    OGAShowEventAdQualityBlankAd,

    // Show SKNetwork
    OGASKNetworkShowEventStartingImpression,
    OGASKNetworkShowEventStartImpression,
    OGASKNetworkShowEventStoppingImpression,
    OGASKNetworkShowEventStopImpression,
    OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression,
    OGASKNetworkShowEventIncompatibleIOSVersionToStopImpression,

    // Show Error
    OGAShowErrorEventAdDisabled,
    OGAShowErrorEventAdExpired,
    OGAShowErrorEventSdkNeverInitialized,
    OGAShowErrorEventSdkNotInitialized,
    OGAShowErrorEventNoAdLoaded,
    OGAShowErrorEventProfigNotSync,
    OGAShowErrorEventViewInBackground,
    OGAShowErrorEventAnotherAdAlreadyDisplayed,
    OGAShowErrorEventNoInternetConnection,
    OGAShowErrorEventWebviewTerminatedByOS,

    // Show Error SKNetwork
    OGASKNetworkShowErrorEventFailedToStartImpression,
    OGASKNetworkShowErrorEventFailedToStopImpression
};

typedef NS_OPTIONS(NSInteger, OGATrackingMask) { OGATrackingMaskNone = 0,
                                                 OGATrackingMaskCache = (1 << 0),
                                                 OGATrackingMaskPreCache = (1 << 1),
                                                 OGATrackingMaskAdsLifeCycle = (1 << 2) };

typedef NS_OPTIONS(NSInteger, OGAAdIdMask) {
    OGAAdIdMaskNone = 0,
    OGAAdIdMaskCampaignId = 1 << 0,
    OGAAdIdMaskCreativeId = 1 << 1,
    OGAAdIdMaskExtras = 1 << 2,
};

typedef NS_ENUM(NSInteger, OGAMonitoringPrecacheError) {
    OGAMonitoringPrecacheErrorHtmlEmpty,
    OGAMonitoringPrecacheErrorTimeOut,
    OGAMonitoringPrecacheErrorHtmlLoadFailed,
    OGAMonitoringPrecacheErrorUnload,
    OGAMonitoringPrecacheErrorMraidDownloadFailed
};
