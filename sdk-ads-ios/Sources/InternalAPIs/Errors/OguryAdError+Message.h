//
//  OguryAdError+Message.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 03/10/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryAdError (Message)
// Domain
extern NSString *const OguryAdsErrorDomain;
// common errors
extern NSString *const SDKStartNotCalledLoadString;
extern NSString *const SDKStartNotCalledShowString;
extern NSString *const SDKStartNotCalledBidString;
extern NSString *const SDKNotProperlyInitializedLoadString;
extern NSString *const SDKNotProperlyInitializedShowString;
extern NSString *const SDKNotProperlyInitializedBidString;
extern NSString *const NoActiveInternetConnectionLoadString;
extern NSString *const NoActiveInternetConnectionShowString;
extern NSString *const InvalidConfigurationBidString;
extern NSString *const InvalidConfigurationLoadString;
extern NSString *const InvalidConfigurationShowString;
extern NSString *const AdDisabledCountryNotOpenedLoadString;
extern NSString *const AdDisabledCountryNotOpenedShowString;
extern NSString *const AdDisabledCountryNotOpenedBidString;
extern NSString *const AdDisabledConsentDeniedLoadString;
extern NSString *const AdDisabledConsentDeniedShowString;
extern NSString *const AdDisabledConsentDeniedBidString;
extern NSString *const AdDisabledConsentMissingLoadString;
extern NSString *const AdDisabledConsentMissingShowString;
extern NSString *const AdDisabledConsentMissingBidString;
extern NSString *const AdDisabledUnspecifiedReasonLoadString;
extern NSString *const AdDisabledUnspecifiedReasonShowString;
extern NSString *const AdDisabledUnspecifiedReasonBidString;
// Load
extern NSString *const AdRequestFailedFormatLoadString;
extern NSString *const NoFillLoadString;
extern NSString *const AdParsingFailedLoadString;
extern NSString *const AdParsingFailedLoadStringFormat;
extern NSString *const AdPrecachingFailedLoadString;
extern NSString *const AdPrecachingFailedLoadStringFormat;
extern NSString *const AdPrecachingTimeoutLoadString;
// Show
extern NSString *const AdExpiredShowString;
extern NSString *const NoAdLoadedShowString;
extern NSString *const ViewInBackgroundShowString;
extern NSString *const AnotherAdAlreadyDisplayedShowString;
extern NSString *const WebviewTerminatedBySystemShowString;
extern NSString *const ViewControllerPreventsFromBeingDisplayedShowString;

@end

NS_ASSUME_NONNULL_END
