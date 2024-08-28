//
//  OguryAdsError.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 23/08/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryAdsErrorType.h"
#import "OguryError+Ads.h"
#import <OguryCore/OguryError.h>

NS_ASSUME_NONNULL_BEGIN

@interface OguryAdsError : OguryError
@property(nonatomic) OguryInternalAdsErrorOrigin origin;
@property(nonatomic) OguryAdsErrorType type;

+ (OguryAdsError *)sdkNotInitializedFrom:(OguryInternalAdsErrorOrigin)origin stackTrace:(NSString *)stackTrace;
+ (OguryAdsError *)sdkNotProperlyInitializedFrom:(OguryInternalAdsErrorOrigin)origin stackTrace:(NSString *)stackTrace;
+ (OguryAdsError *)noInternetConnectionFrom:(OguryInternalAdsErrorOrigin)origin;
+ (OguryAdsError *)invalidConfigurationFrom:(OguryInternalAdsErrorOrigin)origin;
+ (OguryAdsError *)adDisabled:(NSString *)reason from:(OguryInternalAdsErrorOrigin)origin;
+ (OguryAdsError *)adDisabledUnopenedCountryFrom:(OguryInternalAdsErrorOrigin)origin;
+ (OguryAdsError *)adDisabledConsentDeniedFrom:(OguryInternalAdsErrorOrigin)origin;
+ (OguryAdsError *)adDisabledConsentMissingFrom:(OguryInternalAdsErrorOrigin)origin;
+ (OguryAdsError *)adDisabledOtherReasonFrom:(OguryInternalAdsErrorOrigin)origin;
+ (OguryAdsError *)adRequestFailedWithCode:(NSUInteger)requestStatusCode;
+ (OguryAdsError *)noFillFrom:(OguryAdsIntegrationType)integration;
+ (OguryAdsError *)adParsingFailedWithStackTrace:(NSString *)stackTrace;
+ (OguryAdsError *)adPrecachingFailedWithStackTrace:(NSString *)stackTrace;
+ (OguryAdsError *)adPrecachingTimeout;
+ (OguryAdsError *)adExpired;
+ (OguryAdsError *)noAdLoaded;
+ (OguryAdsError *)viewInBackground;
+ (OguryAdsError *)anotherAdIsAlreadyDisplayed;
+ (OguryAdsError *)webviewTerminatedBySystem;
+ (OguryAdsError *)viewControllerPreventsAdFromBeingDisplayed;
@end

NS_ASSUME_NONNULL_END
