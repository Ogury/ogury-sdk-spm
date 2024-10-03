//
//  OguryAdError+Message.m
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 03/10/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import "OguryAdError+Message.h"

@implementation OguryAdError (Message)
// Domain
NSString *const OguryAdsErrorDomain = @"OguryAdsSDK";
// common errors
NSString *const SDKStartNotCalledLoadString = @"The load could not proceed because the SDK appears to have not been started, as no asset key was found.";
NSString *const SDKStartNotCalledShowString = @"The ad could not be displayed because the SDK appears to have not been started, as no asset key was found.";
NSString *const SDKStartNotCalledBidString = @"The bid token could not be generated because the SDK appears to have never been started (no asset key found).";
NSString *const SDKNotProperlyInitializedLoadString = @"The load could not proceed because the SDK is not properly initialized.";
NSString *const SDKNotProperlyInitializedShowString = @"The ad could not be displayed because the SDK is not properly initialized.";
NSString *const SDKNotProperlyInitializedBidString = @"The bid token could not be generated because the SDK is not properly initialized.";
NSString *const NoActiveInternetConnectionLoadString = @"The load could not proceed because there is no active Internet connection.";
NSString *const NoActiveInternetConnectionShowString = @"The ad could not be displayed because there is no active Internet connection.";
NSString *const InvalidConfigurationBidString = @"The bid token could not be generated because the SDK configuration is invalid.";
NSString *const InvalidConfigurationLoadString = @"The load could not proceed due to an invalid SDK configuration.";
NSString *const InvalidConfigurationShowString = @"The ad could not be displayed due to an invalid SDK configuration.";
NSString *const AdDisabledCountryNotOpenedLoadString = @"The load could not proceed because ads are disabled; the user’s country is not yet available for advertising.";
NSString *const AdDisabledCountryNotOpenedShowString = @"The ad could not be displayed because ads are disabled; the user’s country is not yet available for advertising.";
NSString *const AdDisabledCountryNotOpenedBidString = @"The bid token could not be generated because ads are disabled; the user’s country is not yet available for advertising.";
NSString *const AdDisabledConsentDeniedLoadString = @"The load could not proceed because ads are disabled; the user has denied consent for advertising";
NSString *const AdDisabledConsentDeniedShowString = @"The ad could not be displayed because ads are disabled; the user has denied consent for advertising";
NSString *const AdDisabledConsentDeniedBidString = @"The bid token could not be generated because ads are disabled; the user has denied consent for advertising";
NSString *const AdDisabledConsentMissingLoadString = @"The load could not proceed because ads are disabled; the user consent is missing or has not been provided.";
NSString *const AdDisabledConsentMissingShowString = @"The ad could not be displayed because ads are disabled; the user consent is missing or has not been provided.";
NSString *const AdDisabledConsentMissingBidString = @"The bid token could not be generated because ads are disabled; user consent is missing or has not been provided.";
NSString *const AdDisabledUnspecifiedReasonLoadString = @"The load could not proceed because ads are disabled for an unspecified reason.";
NSString *const AdDisabledUnspecifiedReasonShowString = @"The ad could not be displayed because ads are disabled for an unspecified reason.";
NSString *const AdDisabledUnspecifiedReasonBidString = @"The bid token could not be generated because ads are disabled for an unspecified reason.";
// Load
NSString *const AdRequestFailedFormatLoadString = @"The load failed because the ad request encountered an error, and the server returned an unexpected response: %@";
NSString *const NoFillLoadString = @"No ad is currently available for this placement (no fill).";
NSString *const AdParsingFailedLoadString = @"The ad could not be loaded due to a failure in parsing.";
NSString *const AdParsingFailedLoadStringFormat = @"The ad could not be loaded due to a failure in parsing (%@)";
NSString *const AdPrecachingFailedLoadString = @"The ad could not be loaded due to a failure in ad precaching.";
NSString *const AdPrecachingFailedLoadStringFormat = @"The ad could not be loaded due to a failure in ad precaching (%@)";
NSString *const AdPrecachingTimeoutLoadString = @"The ad could not be loaded as precaching exceeded the time limit and timed out.";
// Show
NSString *const AdExpiredShowString = @"The ad could not be displayed because the retention time of the loaded ad has expired.";
NSString *const NoAdLoadedShowString = @"No ad has been loaded.";
NSString *const ViewInBackgroundShowString = @"The ad could not be displayed because the application was running in the background.";
NSString *const AnotherAdAlreadyDisplayedShowString = @"The ad could not be displayed because another ad is currently being displayed.";
NSString *const WebviewTerminatedBySystemShowString = @"The ad could not be displayed because the WebView was terminated by the system, resulting in the ad being unloaded due to high resource consumption by the application.";
NSString *const ViewControllerPreventsFromBeingDisplayedShowString = @"The ad could not be displayed because a ViewController is currently being presented, preventing the ad from displaying.";

@end
