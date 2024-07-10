//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryCore.h>
#import "OguryAdsDelegate.h"
#import "OguryAdsError.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OGAInternalError) {
    OGAInternalErrorAdSyncNoFill = 100000,
    OGAInternalErrorAdSyncNoData = 100001,
    OGAInternalErrorAdSyncParsingError = 100002,
    OGAInternalErrorAdSyncProfigNotSynced = 100003,
    OGAInternalErrorBase64DecodeError = 100004,
    OGAInternalClientError = 100005,
    OGAInternalServerError = 100006
};

@interface OguryError (Ads)

+ (instancetype)createNoInternetConnectionError;
+ (instancetype)createNotLoadedError;
+ (instancetype)createNotAvailableError;
+ (instancetype)createAdDisabledError;
+ (instancetype)createProfigNotSyncedError;
+ (instancetype)createSdkInitNotCalledError;
+ (instancetype)createAnotherAdAlreadyDisplayedError;
+ (instancetype)createCantShowAdsInPresentingViewControllerError;
+ (instancetype)createAdExpiredError;
+ (instancetype)createUnknownError;
+ (instancetype)createAssetKeyNotValidError;
+ (instancetype)createWebViewKilledError;
+ (instancetype)createAdSyncNoFillError;
+ (instancetype)createHBNoFillError;
+ (instancetype)createAdSyncNoDataError;
+ (instancetype)createAdSyncParsingError;
+ (instancetype)createAdSyncParsingErrorWithStackTrace:(NSString *)stackTrace;
+ (instancetype)createAdSyncProfigNotSyncedError;
+ (instancetype)createBase64DecodeError;
+ (instancetype)createClientError:(NSUInteger)statusCode;
+ (instancetype)createServerError:(NSUInteger)statusCode;

+ (OguryAdsErrorType)getOldErrorTypeWith:(NSInteger)newCode;

@end

NS_ASSUME_NONNULL_END
