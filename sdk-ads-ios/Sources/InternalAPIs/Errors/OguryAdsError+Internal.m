//
//  OguryAdsError.m
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 23/08/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import "OguryAdsError.h"
#import "OGAProfigFullResponse.h"
#import "OguryAdsError.h"
#import "OguryAdsError+Internal.h"

@interface OguryAdsError (private)
- (instancetype)initWithErrorType:(OguryAdsErrorType)type origin:(OguryInternalAdsErrorOrigin)origin;
@end
NSString *const OguryAdsErrorDomain = @"OguryAdsSDK";
NSString *const SDKNotInitializedDesc = @"SDK not initialized";
NSString *const SDKNotInitializedFormatDesc = @"SDK not initialized (%@)";
NSString *const SDKNotInitializedSugg = @"It seems that Ogury.start() was not called";
NSString *const SDKNotProperlyInitializedDesc = @"SDK not properly initialized";
NSString *const SDKNotProperlyInitializedFormatDesc = @"SDK not properly initialized (%@)";
NSString *const SDKNotProperlyInitializedSugg = @"Check your AssetKey";
NSString *const NoInternetConnectionDesc = @"No active Internet connection";
NSString *const NoInternetConnectionSugg = @"Try again later";
NSString *const InvalidConfigurationDesc = @"Invalid configuration";
NSString *const InvalidConfigurationSugg = @"The ad configuration was not properly initialized. Try to restart the SDK";
NSString *const AdDisabledUnopenedCountryDesc = @"Ads are disabled because this country is not opened yet";
NSString *const AdDisabledUnopenedCountrySugg = @"";
NSString *const AdDisabledConsentDeniedDesc = @"Ads are disabled because the consent was denied";
NSString *const AdDisabledConsentDeniedSugg = @"Make sure to ask for proper consent before loading an ad";
NSString *const AdDisabledConsentMissingDesc = @"Ads are disabled because the consent is missing";
NSString *const AdDisabledConsentMissingSugg = @"Make sure to ask for proper consent before loading an ad";
NSString *const AdDisabledOtherReasonDesc = @"Ads are disabled";
NSString *const AdDisabledOtherReasonSugg = @"";
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
NSString *const NoAdLoadedDesc = @"The is no ad loaded";
NSString *const NoAdLoadedSugg = @"";
NSString *const ViewInBackgroundDesc = @"Can't display an ad while your application is in background";
NSString *const ViewInBackgroundSugg = @"Plese check viewability before showing an ad";
NSString *const AnotherAdIsAlreadyDisplayedDesc = @"Another ad is already displayed";
NSString *const AnotherAdIsAlreadyDisplayedSugg = @"Try not to show two ads at the time or wait for the previous to end";
NSString *const WebviewTerminatedBySystemDesc = @"The iOS webview was killed by the system because the app consumes too much memory";
NSString *const WebviewTerminatedBySystemSugg = @"Try to reduce your app memory footprint";

@implementation OguryAdsError (internal)

- (instancetype)initWithErrorType:(OguryAdsErrorType)type
                           origin:(OguryInternalAdsErrorOrigin)origin {
    return [self initWithErrorType:type stacktrace:nil origin:origin];
}

- (instancetype)initWithErrorType:(OguryAdsErrorType)type
                       stacktrace:(NSString *)stacktrace
                           origin:(OguryInternalAdsErrorOrigin)origin {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey : [self descriptionFor:type stacktrace:stacktrace],
        NSLocalizedRecoverySuggestionErrorKey : [self suggestionFor:type]
    };
    if (self = [super initWithDomain:OguryAdsErrorDomain code:type userInfo:userInfo]) {
        self.origin = origin;
    }
    return self;
}

- (NSString *)descriptionFor:(OguryAdsErrorType)type stacktrace:(NSString *)stacktrace {
    switch (type) {
        case OguryAdsErrorTypeSDKNotInitialized:
            return stacktrace == nil
                ? SDKNotProperlyInitializedDesc
                : [NSString stringWithFormat:SDKNotInitializedFormatDesc, stacktrace];
            break;
        case OguryAdsErrorTypeSDKNotProperlyInitialized:
            return stacktrace == nil
                ? SDKNotProperlyInitializedDesc
                : [NSString stringWithFormat:SDKNotProperlyInitializedFormatDesc, stacktrace];
            break;
        case OguryAdsErrorTypeNoInternetConnection:
            return NoInternetConnectionDesc;
            break;
        case OguryAdsErrorTypeInvalidConfiguration:
            return InvalidConfigurationDesc;
            break;
        case OguryAdsErrorTypeAdDisabledUnopenedCountry:
            return AdDisabledUnopenedCountryDesc;
            break;
        case OguryAdsErrorTypeAdDisabledConsentDenied:
            return AdDisabledConsentDeniedDesc;
            break;
        case OguryAdsErrorTypeAdDisabledConsentMissing:
            return AdDisabledConsentMissingDesc;
            break;
        case OguryAdsErrorTypeAdDisabledOtherReason:
            return AdDisabledOtherReasonDesc;
            break;
        case OguryAdsErrorTypeAdRequestFailed:
            return [NSString stringWithFormat:AdRequestFailedFormatDesc, stacktrace];
            break;
        case OguryAdsErrorTypeNoFill:
            return stacktrace == nil
                ? NoFillDesc
                : [NSString stringWithFormat:NoFillFormatDesc, stacktrace];
            break;
            break;
        case OguryAdsErrorTypeAdParsingFailed:
            return stacktrace == nil
                ? AdParsingFailedDesc
                : [NSString stringWithFormat:AdParsingFailedFormatDesc, stacktrace];
            break;
        case OguryAdsErrorTypeAdPrecachingFailed:
            return stacktrace == nil
                ? AdPrecachingFailedDesc
                : [NSString stringWithFormat:AdPrecachingFailedFormatDesc, stacktrace];
            break;
        case OguryAdsErrorTypeAdPrecachingTimeout:
            return AdPrecachingTimeoutDesc;
            break;
        case OguryAdsErrorTypeAdExpired:
            return AdExpiredDesc;
            break;
        case OguryAdsErrorTypeNoAdLoaded:
            return NoAdLoadedDesc;
            break;
        case OguryAdsErrorTypeViewInBackground:
            return ViewInBackgroundDesc;
            break;
        case OguryAdsErrorTypeAnotherAdIsAlreadyDisplayed:
            return AnotherAdIsAlreadyDisplayedDesc;
            break;
        case OguryAdsErrorTypeWebviewTerminatedBySystem:
            return WebviewTerminatedBySystemDesc;
            break;
        default:
            return @"";
            break;
    }
}
- (NSString *)suggestionFor:(OguryAdsErrorType)type {
    switch (type) {
        case OguryAdsErrorTypeSDKNotInitialized:
            return SDKNotInitializedSugg;
            break;
        case OguryAdsErrorTypeSDKNotProperlyInitialized:
            return SDKNotProperlyInitializedSugg;
            break;
        case OguryAdsErrorTypeNoInternetConnection:
            return NoInternetConnectionSugg;
            break;
        case OguryAdsErrorTypeInvalidConfiguration:
            return InvalidConfigurationSugg;
            break;
        case OguryAdsErrorTypeAdDisabledUnopenedCountry:
            return AdDisabledUnopenedCountrySugg;
            break;
        case OguryAdsErrorTypeAdDisabledConsentDenied:
            return AdDisabledConsentDeniedSugg;
            break;
        case OguryAdsErrorTypeAdDisabledConsentMissing:
            return AdDisabledConsentMissingSugg;
            break;
        case OguryAdsErrorTypeAdDisabledOtherReason:
            return AdDisabledOtherReasonSugg;
            break;
        case OguryAdsErrorTypeAdRequestFailed:
            return AdRequestFailedSugg;
            break;
        case OguryAdsErrorTypeNoFill:
            return NoFillSugg;
            break;
        case OguryAdsErrorTypeAdParsingFailed:
            return AdParsingFailedSugg;
            break;
        case OguryAdsErrorTypeAdPrecachingFailed:
            return AdPrecachingFailedSugg;
            break;
        case OguryAdsErrorTypeAdPrecachingTimeout:
            return AdPrecachingTimeoutSugg;
            break;
        case OguryAdsErrorTypeAdExpired:
            return AdExpiredSugg;
            break;
        case OguryAdsErrorTypeNoAdLoaded:
            return NoAdLoadedSugg;
            break;
        case OguryAdsErrorTypeViewInBackground:
            return ViewInBackgroundSugg;
            break;
        case OguryAdsErrorTypeAnotherAdIsAlreadyDisplayed:
            return AnotherAdIsAlreadyDisplayedSugg;
            break;
        case OguryAdsErrorTypeWebviewTerminatedBySystem:
            return WebviewTerminatedBySystemSugg;
            break;
        default:
            return @"";
            break;
    }
}

+ (OguryAdsError *)sdkNotInitializedFrom:(OguryInternalAdsErrorOrigin)origin stackTrace:(NSString *)stackTrace {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeSDKNotInitialized stacktrace:stackTrace origin:origin];
}
+ (OguryAdsError *)sdkNotProperlyInitializedFrom:(OguryInternalAdsErrorOrigin)origin stackTrace:(NSString *)stackTrace {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeSDKNotProperlyInitialized stacktrace:stackTrace origin:origin];
}
+ (OguryAdsError *)noInternetConnectionFrom:(OguryInternalAdsErrorOrigin)origin {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeNoInternetConnection origin:origin];
}
+ (OguryAdsError *)invalidConfigurationFrom:(OguryInternalAdsErrorOrigin)origin {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeInvalidConfiguration origin:origin];
}
+ (OguryAdsError *)adDisabled:(NSString *)reason from:(OguryInternalAdsErrorOrigin)origin {
    if ([reason isEqualToString:OGAAdConfigurationDisablingReasonCountryUnopened]) {
        return [self adDisabledUnopenedCountryFrom:origin];
    } else if ([reason isEqualToString:OGAAdConfigurationDisablingReasonConsentDenied]) {
        return [self adDisabledConsentDeniedFrom:origin];
    } else if ([reason isEqualToString:OGAAdConfigurationDisablingReasonConsentMissing]) {
        return [self adDisabledConsentMissingFrom:origin];
    }
    return [self adDisabledOtherReasonFrom:origin];
}
+ (OguryAdsError *)adDisabledUnopenedCountryFrom:(OguryInternalAdsErrorOrigin)origin {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeAdDisabledUnopenedCountry origin:origin];
}
+ (OguryAdsError *)adDisabledConsentDeniedFrom:(OguryInternalAdsErrorOrigin)origin {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeAdDisabledConsentDenied origin:origin];
}
+ (OguryAdsError *)adDisabledConsentMissingFrom:(OguryInternalAdsErrorOrigin)origin {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeAdDisabledConsentMissing origin:origin];
}
+ (OguryAdsError *)adDisabledOtherReasonFrom:(OguryInternalAdsErrorOrigin)origin {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeAdDisabledOtherReason origin:origin];
}
+ (OguryAdsError *)adRequestFailedWithCode:(NSUInteger)requestStatusCode {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeAdRequestFailed
                                         stacktrace:[NSString stringWithFormat:@"%ld", requestStatusCode]
                                             origin:OguryInternalAdsErrorOriginLoad];
}
+ (OguryAdsError *)noFillFrom:(OguryAdsIntegrationType)integration {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeNoFill
                                         stacktrace:integration == OguryAdsIntegrationTypeDirect ? NoFillDesc : NoFillHBDesc
                                             origin:OguryInternalAdsErrorOriginLoad];
}
+ (OguryAdsError *)adParsingFailedWithStackTrace:(NSString *)stackTrace {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeAdParsingFailed
                                         stacktrace:stackTrace
                                             origin:OguryInternalAdsErrorOriginLoad];
}
+ (OguryAdsError *)adPrecachingFailedWithStackTrace:(NSString *)stackTrace {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeAdPrecachingFailed
                                         stacktrace:stackTrace
                                             origin:OguryInternalAdsErrorOriginLoad];
}
+ (OguryAdsError *)adPrecachingTimeout {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeAdPrecachingTimeout
                                             origin:OguryInternalAdsErrorOriginLoad];
}
+ (OguryAdsError *)adExpired {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeAdExpired
                                             origin:OguryInternalAdsErrorOriginShow];
}
+ (OguryAdsError *)noAdLoaded {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeNoAdLoaded
                                             origin:OguryInternalAdsErrorOriginShow];
}
+ (OguryAdsError *)viewInBackground {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeViewInBackground
                                             origin:OguryInternalAdsErrorOriginShow];
}
+ (OguryAdsError *)anotherAdIsAlreadyDisplayed {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeAnotherAdIsAlreadyDisplayed
                                             origin:OguryInternalAdsErrorOriginShow];
}
+ (OguryAdsError *)webviewTerminatedBySystem {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeWebviewTerminatedBySystem
                                             origin:OguryInternalAdsErrorOriginShow];
}
+ (OguryAdsError *)viewControllerPreventsAdFromBeingDisplayed {
    return [[OguryAdsError alloc] initWithErrorType:OguryAdsErrorTypeViewControllerPreventsAdFromBeingDisplayed
                                             origin:OguryInternalAdsErrorOriginShow];
}

@end
