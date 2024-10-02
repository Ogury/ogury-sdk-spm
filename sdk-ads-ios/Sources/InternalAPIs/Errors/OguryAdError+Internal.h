//
//  OguryAdError.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 23/08/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryAdError.h"
#import <OguryCore/OguryError.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OGAInternalError) {
    OGAInternalUnknownError = 100000
};

typedef NS_ENUM(NSInteger, OguryAdIntegrationType) {
    OguryAdIntegrationTypeDirect = 0,
    OguryAdIntegrationTypeHeaderBidding
};

@interface OguryAdError (internal)

+ (OguryAdError *)sdkNotInitializedFrom:(OguryAdErrorType)type stackTrace:(NSString *)stackTrace;
+ (OguryAdError *)sdkNotProperlyInitializedFrom:(OguryAdErrorType)type stackTrace:(NSString *)stackTrace;
+ (OguryAdError *)noInternetConnectionFrom:(OguryAdErrorType)type;
+ (OguryAdError *)invalidConfigurationFrom:(OguryAdErrorType)type;
+ (OguryAdError *)adDisabled:(NSString *)reason from:(OguryAdErrorType)type;
+ (OguryAdError *)adDisabledUnopenedCountryFrom:(OguryAdErrorType)type;
+ (OguryAdError *)adDisabledConsentDeniedFrom:(OguryAdErrorType)type;
+ (OguryAdError *)adDisabledConsentMissingFrom:(OguryAdErrorType)type;
+ (OguryAdError *)adDisabledOtherReasonFrom:(OguryAdErrorType)type;
+ (OguryAdError *)adRequestFailedWithCode:(NSUInteger)requestStatusCode;
+ (OguryAdError *)noFillFrom:(OguryAdIntegrationType)integration;
+ (OguryAdError *)adParsingFailedWithStackTrace:(NSString *)stackTrace;
+ (OguryAdError *)adPrecachingFailedWithStackTrace:(NSString *)stackTrace;
+ (OguryAdError *)adPrecachingTimeout;
+ (OguryAdError *)adExpired;
+ (OguryAdError *)noAdLoaded;
+ (OguryAdError *)viewInBackground;
+ (OguryAdError *)anotherAdIsAlreadyDisplayed;
+ (OguryAdError *)webviewTerminatedBySystem;
+ (OguryAdError *)viewControllerPreventsAdFromBeingDisplayed;
+ (OguryError *)headerBiddingFrom:(NSInteger)originalErrorCode stacktrace:(NSString *)stacktrace;

@end

NS_ASSUME_NONNULL_END
