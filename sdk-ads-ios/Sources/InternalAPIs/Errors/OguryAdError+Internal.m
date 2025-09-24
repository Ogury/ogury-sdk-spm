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
#import "OguryAdError+Message.h"
#import <OguryCore/OguryError.h>
#import <OguryCore/OguryError+internal.h>

@implementation OguryAdError (internal)

- (instancetype)initWithErrorCode:(NSInteger)code
                             type:(OguryAdErrorType)type {
    return [self initWithErrorCode:code stacktrace:nil type:type];
}

- (instancetype)initWithErrorCode:(NSInteger)code
                       stacktrace:(NSString *_Nullable)stacktrace
                             type:(OguryAdErrorType)type {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey : [self descriptionFor:code stacktrace:stacktrace]
    };
    if (self = [super initWithDomain:OguryAdsErrorDomain code:code userInfo:userInfo]) {
        self.type = type;
        self.additionalInformation = stacktrace ?: @"";
    }
    return self;
}

- (NSString *)descriptionFor:(NSInteger)code stacktrace:(NSString *)stacktrace {
    switch (code) {
        case OguryLoadErrorCodeSDKNotStarted:
            return SDKStartNotCalledLoadString;
        case OguryShowErrorCodeSDKNotStarted:
            return SDKStartNotCalledShowString;
        case OguryLoadErrorCodeSDKNotProperlyInitialized:
            return SDKNotProperlyInitializedLoadString;
        case OguryShowErrorCodeSDKNotProperlyInitialized:
            return SDKNotProperlyInitializedShowString;
        case OguryLoadErrorCodeNoActiveInternetConnection:
            return NoActiveInternetConnectionLoadString;
        case OguryShowErrorCodeNoActiveInternetConnection:
            return NoActiveInternetConnectionShowString;
        case OguryLoadErrorCodeInvalidConfiguration:
            return InvalidConfigurationLoadString;
        case OguryShowErrorCodeInvalidConfiguration:
            return InvalidConfigurationShowString;
        case OguryLoadErrorCodeAdDisabledCountryNotOpened:
            return AdDisabledCountryNotOpenedLoadString;
        case OguryShowErrorCodeAdDisabledCountryNotOpened:
            return AdDisabledCountryNotOpenedShowString;
        case OguryLoadErrorCodeAdDisabledConsentDenied:
            return AdDisabledConsentDeniedLoadString;
        case OguryShowErrorCodeAdDisabledConsentDenied:
            return AdDisabledConsentDeniedShowString;
        case OguryLoadErrorCodeAdDisabledConsentMissing:
            return AdDisabledConsentMissingLoadString;
        case OguryShowErrorCodeAdDisabledConsentMissing:
            return AdDisabledConsentMissingShowString;
        case OguryLoadErrorCodeAdDisabledUnspecifiedReason:
            return AdDisabledUnspecifiedReasonLoadString;
        case OguryShowErrorCodeAdDisabledUnspecifiedReason:
            return AdDisabledUnspecifiedReasonShowString;
        case OguryLoadErrorCodeAdRequestFailed:
            return AdRequestFailedFormatLoadString;
        case OguryLoadErrorCodeNoFill:
            return NoFillLoadString;
        case OguryLoadErrorCodeAdParsingFailed:
            return AdParsingFailedLoadString;
        case OguryLoadErrorCodeAdPrecachingFailed:
            return AdPrecachingFailedLoadString;
        case OguryLoadErrorCodeAdPrecachingTimeout:
            return AdPrecachingTimeoutLoadString;
        case OguryShowErrorCodeAdExpired:
            return AdExpiredShowString;
        case OguryShowErrorCodeNoAdLoaded:
            return NoAdLoadedShowString;
        case OguryShowErrorCodeViewInBackground:
            return ViewInBackgroundShowString;
        case OguryShowErrorCodeAnotherAdAlreadyDisplayed:
            return AnotherAdAlreadyDisplayedShowString;
        case OguryShowErrorCodeWebviewTerminatedBySystem:
            return WebviewTerminatedBySystemShowString;
        case OguryShowErrorCodeViewControllerPreventsAdFromBeingDisplayed:
            return ViewControllerPreventsFromBeingDisplayedShowString;

        default:
            return @"";
    }
}

+ (OguryAdError *)sdkNotInitializedFrom:(OguryAdErrorType)type {
    return [[OguryAdError alloc] initWithErrorCode:type == OguryAdErrorTypeLoad
                                     ? OguryLoadErrorCodeSDKNotStarted
                                     : OguryShowErrorCodeSDKNotStarted
                                              type:type];
}
+ (OguryAdError *)sdkNotProperlyInitializedFrom:(OguryAdErrorType)type {
    return [[OguryAdError alloc] initWithErrorCode:type == OguryAdErrorTypeLoad
                                     ? OguryLoadErrorCodeSDKNotProperlyInitialized
                                     : OguryShowErrorCodeSDKNotProperlyInitialized
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
                                        stacktrace:[NSString stringWithFormat:@"Request error code : %ld", requestStatusCode]
                                              type:OguryAdErrorTypeLoad];
}
+ (OguryAdError *)noFillFrom:(OguryAdIntegrationType)integration {
    return [[OguryAdError alloc] initWithErrorCode:OguryLoadErrorCodeNoFill
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

+ (OguryAdError *)createOguryErrorWithCode:(NSInteger)code {
    return [[OguryAdError alloc] initWithErrorCode:code type:OguryAdErrorTypeLoad];
}
+ (OguryAdError *)createOguryErrorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription {
    return [[OguryAdError alloc] initWithErrorCode:code stacktrace:localizedDescription type:OguryAdErrorTypeLoad];
}
+ (OguryAdError *)createOguryErrorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription localizedRecoverySuggestion:(NSString *)localizedRecoverySuggestion {
    return [[OguryAdError alloc] initWithErrorCode:code stacktrace:localizedDescription type:OguryAdErrorTypeLoad];
}

+ (OguryError *)headerBiddingFrom:(NSInteger)originalErrorCode {
    NSInteger bidCode = [self publicBidTokenErrorCodeFrom:originalErrorCode];
    return [OguryError createOguryErrorWithCode:bidCode localizedDescription:[self bidDescriptionFor:bidCode]];
}

+ (NSString *)bidDescriptionFor:(NSInteger)code {
    switch (code) {
        case OguryBidTokenErrorCodeSDKNotStarted:
            return SDKStartNotCalledBidString;
        case OguryBidTokenErrorCodeSDKNotProperlyInitialized:
            return SDKNotProperlyInitializedBidString;
        case OguryBidTokenErrorCodeInvalidConfiguration:
            return InvalidConfigurationBidString;
        case OguryBidTokenErrorCodeAdDisabledCountryNotOpened:
            return AdDisabledCountryNotOpenedBidString;
        case OguryBidTokenErrorCodeAdDisabledConsentDenied:
            return AdDisabledConsentDeniedBidString;
        case OguryBidTokenErrorCodeAdDisabledConsentMissing:
            return AdDisabledConsentMissingBidString;
        case OguryBidTokenErrorCodeAdDisabledUnspecifiedReason:
            return AdDisabledUnspecifiedReasonBidString;
        default:
            return @"";
    }
}

+ (NSInteger)publicBidTokenErrorCodeFrom:(NSInteger)code {
    switch (code) {
        case OguryLoadErrorCodeSDKNotStarted:
        case OguryShowErrorCodeSDKNotStarted:
            return OguryBidTokenErrorCodeSDKNotStarted;

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
