//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OguryError+Messages.h"

NSString *const OguryAdsErrorTypeNoInternetConnectionDesc = @"The device has no Internet connection. Try again when the device is connected to Internet again.";

NSString *const OguryAdsErrorTypeNotLoadedDesc = @"An ad was received from the server but failed to load.";

NSString *const OguryAdsErrorTypeWebViewKilledDesc = @"The ad's webView has been killed by the OS.";

NSString *const OguryAdsErrorTypeNotAvailableDesc = @"No fill for ad.";
NSString *const OguryAdsErrorTypeNotAvailableSugg = @"For testing purpose, you can use a test Ad unit id to always receive non payed test ads.";

NSString *const OguryAdsErrorTypeAdDisabledDesc = @"Ad serving has been disabled for this placement/application.";
NSString *const OguryAdsErrorTypeAdDisabledSugg = @"Please contact your Ogury's account manager";

NSString *const OguryAdsErrorTypeProfigNotSyncedDesc = @"An internal SDK error occurred.";
NSString *const OguryAdsErrorTypeProfigNotSyncedSugg = @"Try again later.";

NSString *const OguryAdsErrorTypeSdkInitNotCalledDesc = @"The Ogury start method must be called before using any feature of the Ogury SDK.";
NSString *const OguryAdsErrorTypeSdkInitNotCalledSugg = @"Call Ogury start method before using the Ogury SDK.";

NSString *const OguryAdsErrorTypeAdAlreadyDisplayedDesc = @"Another ad is already displayed on the screen.";
NSString *const OguryAdsErrorTypeAdAlreadyDisplayedSugg = @"Wait until all fullscreen ad or thumbnail are close.";

NSString *const OguryAdsErrorTypeCantShowAdsInPresentingViewControllerDesc = @"Currently a ViewController is being presented and it is preventing the ad from displaying.";
NSString *const OguryAdsErrorTypeCantShowAdsInPresentingViewControllerSugg = @"Don't use presented or presenting viewController";

NSString *const OguryAdsErrorTypeUnknownDesc = @"Unkown error type.";
NSString *const OguryAdsErrorTypeUnknownSugg = @"Unkown.";

NSString *const OguryAdsErrorTypeAdExpiredDesc = @"The loaded ad is expired.";
NSString *const OguryAdsErrorTypAdExpiredSugg = @"You must call the show method within 4 hours after the load.";

NSString *const OguryAdsAssetKeyNotValidErrorDesc = @"Asset key is empty.";
NSString *const OguryAdsAssetKeyNotValidErrorSugg = @"Copy the asset key from the Ogury dashboard into your call to the Ogury start method.";

NSString *const OGAInternalErrorTypeAdSyncErrorNoFillDesc = @"No fill";
NSString *const OGAInternalErrorTypeAdSyncErrorNoFillSugg = @"Retry again later or use the _test mode";
NSString *const OGAInternalErrorTypeHBErrorNoFillDesc = @"Ad not found";
NSString *const OGAInternalErrorTypeHBErrorNoFillSugg = @"Retry again later or use the _test mode";
NSString *const OGAInternalErrorTypeAdSyncErrorNoDataDesc = @"Empty response";
NSString *const OGAInternalErrorTypeAdSyncErrorNoDataSugg = @"The server answered with an empty array. It shoud not happen";
NSString *const OGAInternalErrorTypeAdSyncErrorParsingErrorDesc = @"Parsing error";
NSString *const OGAInternalErrorTypeAdSyncErrorParsingErrorSugg = @"It seems that the server sent bad data. Try again later.";
NSString *const OGAInternalErrorTypeAdSyncErrorProfigNotSyncedDesc = @"Profig needs to be synced before loading ad";
NSString *const OGAInternalErrorTypeAdSyncErrorProfigNotSyncedSugg = @"Restart SDK.";
NSString *const OGAInternalErrorTypeBase64DecodeErrorDesc = @"Could not decode base64";
NSString *const OGAInternalErrorTypeBase64DecodeErrorSugg = @"";
NSString *const OGAInternalErrorTypeClientErrorDesc = @"Received %ld from the server";
NSString *const OGAInternalErrorTypeClientErrorSugg = @"Check your request";
NSString *const OGAInternalErrorTypeServerErrorDesc = @"Received %ld from the server";
NSString *const OGAInternalErrorTypeServerErrorSugg = @"Check the server";
