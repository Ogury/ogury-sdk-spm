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
- (instancetype)initWithErrorCode:(OguryAdErrorCode)code type:(OguryAdErrorType)type;
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
NSString *const NoAdLoadedDesc = @"There is no loaded ad";
NSString *const NoAdLoadedSugg = @"";
NSString *const ViewInBackgroundDesc = @"Can't display an ad while your application is in background";
NSString *const ViewInBackgroundSugg = @"Plese check viewability before showing an ad";
NSString *const AnotherAdIsAlreadyDisplayedDesc = @"Another ad is already displayed";
NSString *const AnotherAdIsAlreadyDisplayedSugg = @"Try not to show two ads at the time or wait for the previous to end";
NSString *const WebviewTerminatedBySystemDesc = @"The iOS webview was killed by the system because the app consumes too much memory";
NSString *const WebviewTerminatedBySystemSugg = @"Try to reduce your app memory footprint";
NSString *const HeaderBiddingFormatDesc = @"OgurySDK can't generate HB token : %@";
NSString *const HeaderBiddingFormatSugg = @"Check if the OgurySDK has started coorectly";

@implementation OguryAdError (internal)

- (instancetype)initWithErrorCode:(OguryAdErrorCode)code
                             type:(OguryAdErrorType)type {
    return [self initWithErrorCode:code stacktrace:nil type:type];
}

- (instancetype)initWithErrorCode:(OguryAdErrorCode)code
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

- (NSString *)descriptionFor:(OguryAdErrorCode)code stacktrace:(NSString *)stacktrace {
    switch (code) {
        case OguryAdErrorCodeSDKNotCalled:
            return stacktrace == nil
                ? SDKNotProperlyInitializedDesc
                : [NSString stringWithFormat:SDKNotInitializedFormatDesc, stacktrace];
            break;
        case OguryAdErrorCodeSDKNotProperlyInitialized:
            return stacktrace == nil
                ? SDKNotProperlyInitializedDesc
                : [NSString stringWithFormat:SDKNotProperlyInitializedFormatDesc, stacktrace];
            break;
        case OguryAdErrorCodeNoActiveInternetConnection:
            return NoInternetConnectionDesc;
            break;
        case OguryAdErrorCodeInvalidConfiguration:
            return InvalidConfigurationDesc;
            break;
        case OguryAdErrorCodeAdDisabledCountryNotOpened:
            return AdDisabledUnopenedCountryDesc;
            break;
        case OguryAdErrorCodeAdDisabledConsentDenied:
            return AdDisabledConsentDeniedDesc;
            break;
        case OguryAdErrorCodeAdDisabledConsentMissing:
            return AdDisabledConsentMissingDesc;
            break;
        case OguryAdErrorCodeAdDisabledUnspecifiedReason:
            return AdDisabledOtherReasonDesc;
            break;
        case OguryAdErrorCodeAdRequestFailed:
            return [NSString stringWithFormat:AdRequestFailedFormatDesc, stacktrace];
            break;
        case OguryAdErrorCodeNoFill:
            return stacktrace == nil
                ? NoFillDesc
                : [NSString stringWithFormat:NoFillFormatDesc, stacktrace];
            break;
            break;
        case OguryAdErrorCodeAdParsingFailed:
            return stacktrace == nil
                ? AdParsingFailedDesc
                : [NSString stringWithFormat:AdParsingFailedFormatDesc, stacktrace];
            break;
        case OguryAdErrorCodeAdPrecachingFailed:
            return stacktrace == nil
                ? AdPrecachingFailedDesc
                : [NSString stringWithFormat:AdPrecachingFailedFormatDesc, stacktrace];
            break;
        case OguryAdErrorCodeAdPrecachingTimeout:
            return AdPrecachingTimeoutDesc;
            break;
        case OguryAdErrorCodeAdExpired:
            return AdExpiredDesc;
            break;
        case OguryAdErrorCodeNoAdLoaded:
            return NoAdLoadedDesc;
            break;
        case OguryAdErrorCodeViewInBackground:
            return ViewInBackgroundDesc;
            break;
        case OguryAdErrorCodeAnotherAdAlreadyDisplayed:
            return AnotherAdIsAlreadyDisplayedDesc;
            break;
        case OguryAdErrorCodeWebviewTerminatedBySystem:
            return WebviewTerminatedBySystemDesc;
            break;
        case OguryAdErrorCodeViewControllerPreventsAdFromBeingDisplayed:
            return @"";
            break;
        case OguryAdErrorCodeHeaderBidding:
            return HeaderBiddingFormatDesc;
            break;
    }
}

- (NSString *)suggestionFor:(OguryAdErrorCode)code {
    switch (code) {
        case OguryAdErrorCodeSDKNotCalled:
            return SDKNotInitializedSugg;
            break;
        case OguryAdErrorCodeSDKNotProperlyInitialized:
            return SDKNotProperlyInitializedSugg;
            break;
        case OguryAdErrorCodeNoActiveInternetConnection:
            return NoInternetConnectionSugg;
            break;
        case OguryAdErrorCodeInvalidConfiguration:
            return InvalidConfigurationSugg;
            break;
        case OguryAdErrorCodeAdDisabledCountryNotOpened:
            return AdDisabledUnopenedCountrySugg;
            break;
        case OguryAdErrorCodeAdDisabledConsentDenied:
            return AdDisabledConsentDeniedSugg;
            break;
        case OguryAdErrorCodeAdDisabledConsentMissing:
            return AdDisabledConsentMissingSugg;
            break;
        case OguryAdErrorCodeAdDisabledUnspecifiedReason:
            return AdDisabledOtherReasonSugg;
            break;
        case OguryAdErrorCodeAdRequestFailed:
            return AdRequestFailedSugg;
            break;
        case OguryAdErrorCodeNoFill:
            return NoFillSugg;
            break;
        case OguryAdErrorCodeAdParsingFailed:
            return AdParsingFailedSugg;
            break;
        case OguryAdErrorCodeAdPrecachingFailed:
            return AdPrecachingFailedSugg;
            break;
        case OguryAdErrorCodeAdPrecachingTimeout:
            return AdPrecachingTimeoutSugg;
            break;
        case OguryAdErrorCodeAdExpired:
            return AdExpiredSugg;
            break;
        case OguryAdErrorCodeNoAdLoaded:
            return NoAdLoadedSugg;
            break;
        case OguryAdErrorCodeViewInBackground:
            return ViewInBackgroundSugg;
            break;
        case OguryAdErrorCodeAnotherAdAlreadyDisplayed:
            return AnotherAdIsAlreadyDisplayedSugg;
            break;
        case OguryAdErrorCodeWebviewTerminatedBySystem:
            return WebviewTerminatedBySystemSugg;
            break;
        case OguryAdErrorCodeViewControllerPreventsAdFromBeingDisplayed:
            return @"";
            break;
        case OguryAdErrorCodeHeaderBidding:
            return @"";
            break;
        default:
            return @"";
            break;
    }
}

+ (OguryAdError *)sdkNotInitializedFrom:(OguryAdErrorType)type stackTrace:(NSString *)stackTrace {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeSDKNotCalled stacktrace:stackTrace type:type];
}
+ (OguryAdError *)sdkNotProperlyInitializedFrom:(OguryAdErrorType)type stackTrace:(NSString *)stackTrace {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeSDKNotProperlyInitialized stacktrace:stackTrace type:type];
}
+ (OguryAdError *)noInternetConnectionFrom:(OguryAdErrorType)type {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeNoActiveInternetConnection type:type];
}
+ (OguryAdError *)invalidConfigurationFrom:(OguryAdErrorType)type {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeInvalidConfiguration type:type];
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
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeAdDisabledCountryNotOpened type:type];
}
+ (OguryAdError *)adDisabledConsentDeniedFrom:(OguryAdErrorType)type {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeAdDisabledConsentDenied type:type];
}
+ (OguryAdError *)adDisabledConsentMissingFrom:(OguryAdErrorType)type {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeAdDisabledConsentMissing type:type];
}
+ (OguryAdError *)adDisabledOtherReasonFrom:(OguryAdErrorType)type {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeAdDisabledUnspecifiedReason type:type];
}
+ (OguryAdError *)adRequestFailedWithCode:(NSUInteger)requestStatusCode {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeAdRequestFailed
                                        stacktrace:[NSString stringWithFormat:@"%ld", requestStatusCode]
                                              type:OguryAdErrorTypeLoad];
}
+ (OguryAdError *)noFillFrom:(OguryAdIntegrationType)integration {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeNoFill
                                        stacktrace:integration == OguryAdIntegrationTypeDirect ? NoFillDesc : NoFillHBDesc
                                              type:OguryAdErrorTypeLoad];
}
+ (OguryAdError *)adParsingFailedWithStackTrace:(NSString *)stackTrace {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeAdParsingFailed
                                        stacktrace:stackTrace
                                              type:OguryAdErrorTypeLoad];
}
+ (OguryAdError *)adPrecachingFailedWithStackTrace:(NSString *)stackTrace {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeAdPrecachingFailed
                                        stacktrace:stackTrace
                                              type:OguryAdErrorTypeLoad];
}
+ (OguryAdError *)adPrecachingTimeout {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeAdPrecachingTimeout
                                              type:OguryAdErrorTypeLoad];
}
+ (OguryAdError *)adExpired {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeAdExpired
                                              type:OguryAdErrorTypeShow];
}
+ (OguryAdError *)noAdLoaded {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeNoAdLoaded
                                              type:OguryAdErrorTypeShow];
}
+ (OguryAdError *)viewInBackground {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeViewInBackground
                                              type:OguryAdErrorTypeShow];
}
+ (OguryAdError *)anotherAdIsAlreadyDisplayed {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeAnotherAdAlreadyDisplayed
                                              type:OguryAdErrorTypeShow];
}
+ (OguryAdError *)webviewTerminatedBySystem {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeWebviewTerminatedBySystem
                                              type:OguryAdErrorTypeShow];
}
+ (OguryAdError *)viewControllerPreventsAdFromBeingDisplayed {
    return [[OguryAdError alloc] initWithErrorCode:OguryAdErrorCodeViewControllerPreventsAdFromBeingDisplayed
                                              type:OguryAdErrorTypeShow];
}
+ (OguryError *)headerBiddingWithStacktrace:(NSString *)stacktrace {
    return [OguryAdError createOguryErrorWithCode:OguryAdErrorCodeHeaderBidding
                             localizedDescription:[NSString stringWithFormat:HeaderBiddingFormatDesc, stacktrace]];
}

@end
