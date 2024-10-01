//
//  OguryAdError.m
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 23/08/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import "OguryAdError.h"
#import "OGAProfigFullResponse.h"
#import "OguryAdError+Internal.h"
#import <OguryCore/OguryError.h>

@interface OguryAdError (private)
- (instancetype)initWithErrorCode:(NSInteger)code type:(OguryAdErrorType)type;
@end

NSString *const OguryAdsErrorDomain = @"OguryAdsSDK";
NSString *const SDKStartNotCalledDesc = @"SDK not started";
NSString *const SDKStartNotCalledFormatDesc = @"SDK not started (%@)";
NSString *const SDKStartNotCalledSugg = @"It seems that Ogury.start() was not called";
NSString *const SDKNotProperlyInitializedDesc = @"SDK not properly initialized";
NSString *const SDKNotProperlyInitializedFormatDesc = @"SDK not properly initialized (%@)";
NSString *const SDKNotProperlyInitializedSugg = @"Check your AssetKey";
NSString *const NoActiveInternetConnectionDesc = @"No active Internet connection";
NSString *const NoActiveInternetConnectionSugg = @"Try again later";
NSString *const InvalidConfigurationDesc = @"Invalid configuration";
NSString *const InvalidConfigurationSugg = @"The ad configuration was not properly initialized. Try to restart the SDK";
NSString *const AdDisabledCountryNotOpenedDesc = @"Ads are disabled because this country is not opened";
NSString *const AdDisabledCountryNotOpenedSugg = @"";
NSString *const AdDisabledConsentDeniedDesc = @"Ads are disabled because the consent was denied";
NSString *const AdDisabledConsentDeniedSugg = @"Make sure to ask for proper consent before loading an ad";
NSString *const AdDisabledConsentMissingDesc = @"Ads are disabled because the consent is missing";
NSString *const AdDisabledConsentMissingSugg = @"Make sure to ask for proper consent before loading an ad";
NSString *const AdDisabledUnspecifiedReasonDesc = @"Ads are disabled";
NSString *const AdDisabledUnspecifiedReasonSugg = @"";
NSString *const AdRequestFailedFormatDesc = @"Ad request failed. Received %@ from the server";
NSString *const AdRequestFailedSugg = @"";
NSString *const NoFillFormatDesc = @"%@";
NSString *const NoFillDesc = @"No fill";
NSString *const NoFillHBDesc = @"Ad not found";
NSString *const NoFillSugg = @"Ogury couldn't find any suitable ad at that time. Please try again later";
NSString *const AdParsingFailedFormatDesc = @"The parsing of the ad failed : %@";
NSString *const AdParsingFailedDesc = @"The parsing of the ad failed";
NSString *const AdParsingFailedSugg = @"";
NSString *const AdPrecachingFailedFormatDesc = @"The ad's precaching failed : %@";
NSString *const AdPrecachingFailedDesc = @"The ad's precaching failed";
NSString *const AdPrecachingFailedSugg = @"";
NSString *const AdPrecachingTimeoutDesc = @"The ad's precaching timed out";
NSString *const AdPrecachingTimeoutSugg = @"";
NSString *const AdExpiredDesc = @"The ad expired";
NSString *const AdExpiredSugg = @"Try to show the ad faster after the load succeeds";
NSString *const NoAdLoadedDesc = @"There is no loaded ad";
NSString *const NoAdLoadedSugg = @"";
NSString *const ViewInBackgroundDesc = @"Can't display an ad while your application is in background";
NSString *const ViewInBackgroundSugg = @"Plese check viewability before showing an ad";
NSString *const AnotherAdAlreadyDisplayedDesc = @"Another ad is already displayed";
NSString *const AnotherAdAlreadyDisplayedSugg = @"Try not to show two ads at the time or wait for the previous to end";
NSString *const WebviewTerminatedBySystemDesc = @"The iOS webview was killed by the system because the app consumes too much memory";
NSString *const WebviewTerminatedBySystemSugg = @"Try to reduce your app memory footprint";
NSString *const HeaderBiddingFormatDesc = @"OgurySDK can't generate HB token : %@";
NSString *const HeaderBiddingFormatSugg = @"Check if the OgurySDK has started coorectly";

@implementation OguryAdError (internal)

- (instancetype)initWithErrorCode:(NSInteger)code
                             type:(OguryAdErrorType)type {
    return [self initWithErrorCode:code stacktrace:nil type:type];
}

- (instancetype)initWithErrorCode:(NSInteger)code
                       stacktrace:(NSString *)stacktrace
                             type:(OguryAdErrorType)type {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey : [self descriptionFor:code stacktrace:stacktrace],
        NSLocalizedRecoverySuggestionErrorKey : [self suggestionFor:code]
    };
    if (self = [super initWithDomain:OguryAdsErrorDomain code:code userInfo:userInfo]) {
        self.type = type;
    }
    return self;
}

- (NSString *)descriptionFor:(NSInteger)code stacktrace:(NSString *)stacktrace {
    switch (code) {
        case OguryLoadErrorCodeSDKNeverStarted:
        case OguryShowErrorCodeSDKNeverStarted:
            return stacktrace == nil
                ? SDKNotProperlyInitializedDesc
                : [NSString stringWithFormat:SDKStartNotCalledFormatDesc, stacktrace];

        case OguryLoadErrorCodeSDKNotProperlyInitialized:
        case OguryShowErrorCodeSDKNotProperlyInitialized:
            return stacktrace == nil
                ? SDKNotProperlyInitializedDesc
                : [NSString stringWithFormat:SDKNotProperlyInitializedFormatDesc, stacktrace];

        case OguryLoadErrorCodeNoActiveInternetConnection:
        case OguryShowErrorCodeNoActiveInternetConnection:
            return NoActiveInternetConnectionDesc;

        case OguryLoadErrorCodeInvalidConfiguration:
        case OguryShowErrorCodeInvalidConfiguration:
            return InvalidConfigurationDesc;

        case OguryLoadErrorCodeAdDisabledCountryNotOpened:
        case OguryShowErrorCodeAdDisabledCountryNotOpened:
            return AdDisabledCountryNotOpenedDesc;

        case OguryLoadErrorCodeAdDisabledConsentDenied:
        case OguryShowErrorCodeAdDisabledConsentDenied:
            return AdDisabledConsentDeniedDesc;

        case OguryLoadErrorCodeAdDisabledConsentMissing:
        case OguryShowErrorCodeAdDisabledConsentMissing:
            return AdDisabledConsentMissingDesc;

        case OguryLoadErrorCodeAdDisabledUnspecifiedReason:
        case OguryShowErrorCodeAdDisabledUnspecifiedReason:
            return AdDisabledUnspecifiedReasonDesc;

        case OguryLoadErrorCodeAdRequestFailed:
            return [NSString stringWithFormat:AdRequestFailedFormatDesc, stacktrace];

        case OguryLoadErrorCodeNoFill:
            return stacktrace == nil
                ? NoFillDesc
                : [NSString stringWithFormat:NoFillFormatDesc, stacktrace];

        case OguryLoadErrorCodeAdParsingFailed:
            return stacktrace == nil
                ? AdParsingFailedDesc
                : [NSString stringWithFormat:AdParsingFailedFormatDesc, stacktrace];

        case OguryLoadErrorCodeAdPrecachingFailed:
            return stacktrace == nil
                ? AdPrecachingFailedDesc
                : [NSString stringWithFormat:AdPrecachingFailedFormatDesc, stacktrace];

        case OguryLoadErrorCodeAdPrecachingTimeout:
            return AdPrecachingTimeoutDesc;

        case OguryShowErrorCodeAdExpired:
            return AdExpiredDesc;

        case OguryShowErrorCodeNoAdLoaded:
            return NoAdLoadedDesc;

        case OguryShowErrorCodeViewInBackground:
            return ViewInBackgroundDesc;

        case OguryShowErrorCodeAnotherAdAlreadyDisplayed:
            return AnotherAdAlreadyDisplayedDesc;

        case OguryShowErrorCodeWebviewTerminatedBySystem:
            return WebviewTerminatedBySystemDesc;

        case OguryShowErrorCodeViewControllerPreventsAdFromBeingDisplayed:
            return @"";

        default:
            return @"";
    }
}

- (NSString *)suggestionFor:(NSInteger)code {
    switch (code) {
        case OguryLoadErrorCodeSDKNeverStarted:
        case OguryShowErrorCodeSDKNeverStarted:
            return SDKStartNotCalledSugg;

        case OguryLoadErrorCodeSDKNotProperlyInitialized:
        case OguryShowErrorCodeSDKNotProperlyInitialized:
            return SDKNotProperlyInitializedSugg;

        case OguryLoadErrorCodeNoActiveInternetConnection:
        case OguryShowErrorCodeNoActiveInternetConnection:
            return NoActiveInternetConnectionSugg;

        case OguryLoadErrorCodeInvalidConfiguration:
        case OguryShowErrorCodeInvalidConfiguration:
            return InvalidConfigurationSugg;

        case OguryLoadErrorCodeAdDisabledCountryNotOpened:
        case OguryShowErrorCodeAdDisabledCountryNotOpened:
            return AdDisabledCountryNotOpenedSugg;

        case OguryLoadErrorCodeAdDisabledConsentDenied:
        case OguryShowErrorCodeAdDisabledConsentDenied:
            return AdDisabledConsentDeniedSugg;

        case OguryLoadErrorCodeAdDisabledConsentMissing:
        case OguryShowErrorCodeAdDisabledConsentMissing:
            return AdDisabledConsentMissingSugg;

        case OguryLoadErrorCodeAdDisabledUnspecifiedReason:
        case OguryShowErrorCodeAdDisabledUnspecifiedReason:
            return AdDisabledUnspecifiedReasonSugg;

        case OguryLoadErrorCodeAdRequestFailed:
            return AdRequestFailedSugg;

        case OguryLoadErrorCodeNoFill:
            return NoFillSugg;

        case OguryLoadErrorCodeAdParsingFailed:
            return AdParsingFailedSugg;

        case OguryLoadErrorCodeAdPrecachingFailed:
            return AdPrecachingFailedSugg;

        case OguryLoadErrorCodeAdPrecachingTimeout:
            return AdPrecachingTimeoutSugg;

        case OguryShowErrorCodeAdExpired:
            return AdExpiredSugg;

        case OguryShowErrorCodeNoAdLoaded:
            return NoAdLoadedSugg;

        case OguryShowErrorCodeViewInBackground:
            return ViewInBackgroundSugg;

        case OguryShowErrorCodeAnotherAdAlreadyDisplayed:
            return AnotherAdAlreadyDisplayedSugg;

        case OguryShowErrorCodeWebviewTerminatedBySystem:
            return WebviewTerminatedBySystemSugg;

        case OguryShowErrorCodeViewControllerPreventsAdFromBeingDisplayed:
            return @"";

        default:
            return @"";
    }
}

+ (OguryAdError *)sdkNotInitializedFrom:(OguryAdErrorType)type stackTrace:(NSString *)stackTrace {
    return [[OguryAdError alloc] initWithErrorCode:type == OguryAdErrorTypeLoad
                                     ? OguryLoadErrorCodeSDKNeverStarted
                                     : OguryShowErrorCodeSDKNeverStarted
                                        stacktrace:stackTrace
                                              type:type];
}
+ (OguryAdError *)sdkNotProperlyInitializedFrom:(OguryAdErrorType)type stackTrace:(NSString *)stackTrace {
    return [[OguryAdError alloc] initWithErrorCode:type == OguryAdErrorTypeLoad
                                     ? OguryLoadErrorCodeSDKNotProperlyInitialized
                                     : OguryShowErrorCodeSDKNotProperlyInitialized
                                        stacktrace:stackTrace
                                              type:type];
}
+ (OguryAdError *)noInternetConnectionFrom:(OguryAdErrorType)type {
    return [[OguryAdError alloc] initWithErrorCode:type == OguryAdErrorTypeLoad
                                     ? OguryLoadErrorCodeNoActiveInternetConnection
                                     : OguryShowErrorCodeNoActiveInternetConnection
                                              type:type];
}
+ (OguryAdError *)invalidConfigurationFrom:(OguryAdErrorType)type {
    return [[OguryAdError alloc] initWithErrorCode:type == OguryAdErrorTypeLoad
                                     ? OguryLoadErrorCodeInvalidConfiguration
                                     : OguryShowErrorCodeInvalidConfiguration
                                              type:type];
}
+ (OguryAdError *)adDisabled:(NSString *)reason from:(OguryAdErrorType)type {
    if ([reason isEqualToString:OGAAdConfigurationDisablingReasonCountryUnopened]) {
        return [self adDisabledUnopenedCountryFrom:type];
    } else if ([reason isEqualToString:OGAAdConfigurationDisablingReasonConsentDenied]) {
        return [self adDisabledConsentDeniedFrom:type];
    } else if ([reason isEqualToString:OGAAdConfigurationDisablingReasonConsentMissing]) {
        return [self adDisabledConsentMissingFrom:type];
    }
    return [self adDisabledOtherReasonFrom:type];
}
+ (OguryAdError *)adDisabledUnopenedCountryFrom:(OguryAdErrorType)type {
    return [[OguryAdError alloc] initWithErrorCode:type == OguryAdErrorTypeLoad
                                     ? OguryLoadErrorCodeAdDisabledCountryNotOpened
                                     : OguryShowErrorCodeAdDisabledCountryNotOpened
                                              type:type];
}
+ (OguryAdError *)adDisabledConsentDeniedFrom:(OguryAdErrorType)type {
    return [[OguryAdError alloc] initWithErrorCode:type == OguryAdErrorTypeLoad
                                     ? OguryLoadErrorCodeAdDisabledConsentDenied
                                     : OguryShowErrorCodeAdDisabledConsentDenied
                                              type:type];
}
+ (OguryAdError *)adDisabledConsentMissingFrom:(OguryAdErrorType)type {
    return [[OguryAdError alloc] initWithErrorCode:type == OguryAdErrorTypeLoad
                                     ? OguryLoadErrorCodeAdDisabledConsentMissing
                                     : OguryShowErrorCodeAdDisabledConsentMissing
                                              type:type];
}
+ (OguryAdError *)adDisabledOtherReasonFrom:(OguryAdErrorType)type {
    return [[OguryAdError alloc] initWithErrorCode:type == OguryAdErrorTypeLoad
                                     ? OguryLoadErrorCodeAdDisabledUnspecifiedReason
                                     : OguryShowErrorCodeAdDisabledUnspecifiedReason
                                              type:type];
}
+ (OguryAdError *)adRequestFailedWithCode:(NSUInteger)requestStatusCode {
    return [[OguryAdError alloc] initWithErrorCode:OguryLoadErrorCodeAdRequestFailed
                                        stacktrace:[NSString stringWithFormat:@"%ld", requestStatusCode]
                                              type:OguryAdErrorTypeLoad];
}
+ (OguryAdError *)noFillFrom:(OguryAdIntegrationType)integration {
    return [[OguryAdError alloc] initWithErrorCode:OguryLoadErrorCodeNoFill
                                        stacktrace:integration == OguryAdIntegrationTypeDirect ? NoFillDesc : NoFillHBDesc
                                              type:OguryAdErrorTypeLoad];
}
+ (OguryAdError *)adParsingFailedWithStackTrace:(NSString *)stackTrace {
    return [[OguryAdError alloc] initWithErrorCode:OguryLoadErrorCodeAdParsingFailed
                                        stacktrace:stackTrace
                                              type:OguryAdErrorTypeLoad];
}
+ (OguryAdError *)adPrecachingFailedWithStackTrace:(NSString *)stackTrace {
    return [[OguryAdError alloc] initWithErrorCode:OguryLoadErrorCodeAdPrecachingFailed
                                        stacktrace:stackTrace
                                              type:OguryAdErrorTypeLoad];
}
+ (OguryAdError *)adPrecachingTimeout {
    return [[OguryAdError alloc] initWithErrorCode:OguryLoadErrorCodeAdPrecachingTimeout
                                              type:OguryAdErrorTypeLoad];
}
+ (OguryAdError *)adExpired {
    return [[OguryAdError alloc] initWithErrorCode:OguryShowErrorCodeAdExpired
                                              type:OguryAdErrorTypeShow];
}
+ (OguryAdError *)noAdLoaded {
    return [[OguryAdError alloc] initWithErrorCode:OguryShowErrorCodeNoAdLoaded
                                              type:OguryAdErrorTypeShow];
}
+ (OguryAdError *)viewInBackground {
    return [[OguryAdError alloc] initWithErrorCode:OguryShowErrorCodeViewInBackground
                                              type:OguryAdErrorTypeShow];
}
+ (OguryAdError *)anotherAdIsAlreadyDisplayed {
    return [[OguryAdError alloc] initWithErrorCode:OguryShowErrorCodeAnotherAdAlreadyDisplayed
                                              type:OguryAdErrorTypeShow];
}
+ (OguryAdError *)webviewTerminatedBySystem {
    return [[OguryAdError alloc] initWithErrorCode:OguryShowErrorCodeWebviewTerminatedBySystem
                                              type:OguryAdErrorTypeShow];
}
+ (OguryAdError *)viewControllerPreventsAdFromBeingDisplayed {
    return [[OguryAdError alloc] initWithErrorCode:OguryShowErrorCodeViewControllerPreventsAdFromBeingDisplayed
                                              type:OguryAdErrorTypeShow];
}
+ (OguryError *)headerBiddingFrom:(NSInteger)originalErrorCode stacktrace:(NSString *)stacktrace {
    return [OguryError createOguryErrorWithCode:[self publicBidTokenErrorCodeFrom:originalErrorCode]
                           localizedDescription:[NSString stringWithFormat:HeaderBiddingFormatDesc, stacktrace]];
}

+ (NSInteger)publicBidTokenErrorCodeFrom:(NSInteger)code {
    switch (code) {
        case OguryLoadErrorCodeSDKNeverStarted:
        case OguryShowErrorCodeSDKNeverStarted:
            return OguryBidTokenErrorCodeSDKNeverStarted;

        case OguryLoadErrorCodeSDKNotProperlyInitialized:
        case OguryShowErrorCodeSDKNotProperlyInitialized:
            return OguryBidTokenErrorCodeSDKNotProperlyInitialized;

        case OguryLoadErrorCodeNoActiveInternetConnection:
        case OguryShowErrorCodeNoActiveInternetConnection:
            return OguryBidTokenErrorCodeNoActiveInternetConnection;

        case OguryLoadErrorCodeInvalidConfiguration:
        case OguryShowErrorCodeInvalidConfiguration:
            return OguryBidTokenErrorCodeInvalidConfiguration;

        case OguryLoadErrorCodeAdDisabledCountryNotOpened:
        case OguryShowErrorCodeAdDisabledCountryNotOpened:
            return OguryBidTokenErrorCodeAdDisabledCountryNotOpened;

        case OguryLoadErrorCodeAdDisabledConsentDenied:
        case OguryShowErrorCodeAdDisabledConsentDenied:
            return OguryBidTokenErrorCodeAdDisabledConsentDenied;

        case OguryLoadErrorCodeAdDisabledConsentMissing:
        case OguryShowErrorCodeAdDisabledConsentMissing:
            return OguryBidTokenErrorCodeAdDisabledConsentMissing;

        case OguryLoadErrorCodeAdDisabledUnspecifiedReason:
        case OguryShowErrorCodeAdDisabledUnspecifiedReason:
            return OguryBidTokenErrorCodeAdDisabledUnspecifiedReason;

        default:
            return code;
    }
}

@end
