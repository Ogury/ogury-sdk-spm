//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryError+Ads.h"

#import "OguryError+Messages.h"

@implementation OguryError (Ads)

+ (instancetype)createNoInternetConnectionError {
    return [OguryError createOguryErrorWithCode:OguryCoreErrorTypeNoInternetConnection
                           localizedDescription:OguryAdsErrorTypeNoInternetConnectionDesc];
}

+ (instancetype)createNotLoadedError {
    return [OguryError createOguryErrorWithCode:OguryAdsNotLoadedError
                           localizedDescription:OguryAdsErrorTypeNotLoadedDesc];
}

+ (instancetype)createWebViewKilledError {
    return [OguryError createOguryErrorWithCode:OguryAdsWebViewKilledError
                           localizedDescription:OguryAdsErrorTypeWebViewKilledDesc];
}

+ (instancetype)createNotAvailableError {
    return [OguryError createOguryErrorWithCode:OguryAdsNotAvailableError
                           localizedDescription:OguryAdsErrorTypeNotAvailableDesc
                    localizedRecoverySuggestion:OguryAdsErrorTypeNotAvailableSugg];
}

+ (instancetype)createAdDisabledError {
    return [OguryError createOguryErrorWithCode:OguryAdsAdDisabledError
                           localizedDescription:OguryAdsErrorTypeAdDisabledDesc
                    localizedRecoverySuggestion:OguryAdsErrorTypeAdDisabledSugg];
}

+ (instancetype)createProfigNotSyncedError {
    return [OguryError createOguryErrorWithCode:OguryAdsProfigNotSyncedError
                           localizedDescription:OguryAdsErrorTypeProfigNotSyncedDesc
                    localizedRecoverySuggestion:OguryAdsErrorTypeProfigNotSyncedSugg];
}

+ (instancetype)createSdkInitNotCalledError {
    return [OguryError createOguryErrorWithCode:OguryAdsSdkInitNotCalledError
                           localizedDescription:OguryAdsErrorTypeSdkInitNotCalledDesc
                    localizedRecoverySuggestion:OguryAdsErrorTypeSdkInitNotCalledSugg];
}

+ (instancetype)createAnotherAdAlreadyDisplayedError {
    return [OguryError createOguryErrorWithCode:OguryAdsAnotherAdAlreadyDisplayedError
                           localizedDescription:OguryAdsErrorTypeAdAlreadyDisplayedDesc
                    localizedRecoverySuggestion:OguryAdsErrorTypeAdAlreadyDisplayedSugg];
}

+ (instancetype)createCantShowAdsInPresentingViewControllerError {
    return [OguryError createOguryErrorWithCode:OguryAdsCantShowAdsInPresentingViewControllerError
                           localizedDescription:OguryAdsErrorTypeCantShowAdsInPresentingViewControllerDesc
                    localizedRecoverySuggestion:OguryAdsErrorTypeCantShowAdsInPresentingViewControllerSugg];
}

+ (instancetype)createUnknownError {
    return [OguryError createOguryErrorWithCode:OguryAdsUnknownError
                           localizedDescription:OguryAdsErrorTypeUnknownDesc
                    localizedRecoverySuggestion:OguryAdsErrorTypeUnknownSugg];
}

+ (instancetype)createAdExpiredError {
    return [OguryError createOguryErrorWithCode:OguryAdsAdExpiredError
                           localizedDescription:OguryAdsErrorTypeAdExpiredDesc
                    localizedRecoverySuggestion:OguryAdsErrorTypAdExpiredSugg];
}

+ (instancetype)createAssetKeyNotValidError {
    return [OguryError createOguryErrorWithCode:OguryAdsAssetKeyNotValidError
                           localizedDescription:OguryAdsAssetKeyNotValidErrorDesc
                    localizedRecoverySuggestion:OguryAdsAssetKeyNotValidErrorSugg];
}

+ (instancetype)createAdSyncNoFillError {
    return [OguryError createOguryErrorWithCode:OGAInternalErrorAdSyncNoFill
                           localizedDescription:OGAInternalErrorTypeAdSyncErrorNoFillDesc
                    localizedRecoverySuggestion:OGAInternalErrorTypeAdSyncErrorNoFillSugg];
}

+ (instancetype)createHBNoFillError {
    return [OguryError createOguryErrorWithCode:OGAInternalErrorAdSyncNoFill
                           localizedDescription:OGAInternalErrorTypeHBErrorNoFillDesc
                    localizedRecoverySuggestion:OGAInternalErrorTypeHBErrorNoFillSugg];
}
+ (instancetype)createAdSyncNoDataError {
    return [OguryError createOguryErrorWithCode:OGAInternalErrorAdSyncNoData
                           localizedDescription:OGAInternalErrorTypeAdSyncErrorNoDataDesc
                    localizedRecoverySuggestion:OGAInternalErrorTypeAdSyncErrorNoDataSugg];
}
+ (instancetype)createAdSyncParsingError {
    return [OguryError createOguryErrorWithCode:OGAInternalErrorAdSyncParsingError
                           localizedDescription:OGAInternalErrorTypeAdSyncErrorParsingErrorDesc
                    localizedRecoverySuggestion:OGAInternalErrorTypeAdSyncErrorParsingErrorSugg];
}
+ (instancetype)createAdSyncParsingErrorWithStackTrace:(NSString *)stackTrace {
    return [OguryError createOguryErrorWithCode:OGAInternalErrorAdSyncParsingError
                           localizedDescription:stackTrace
                    localizedRecoverySuggestion:OGAInternalErrorTypeAdSyncErrorParsingErrorSugg];
}
+ (instancetype)createAdSyncProfigNotSyncedError {
    return [OguryError createOguryErrorWithCode:OGAInternalErrorAdSyncProfigNotSynced
                           localizedDescription:OGAInternalErrorTypeAdSyncErrorProfigNotSyncedDesc
                    localizedRecoverySuggestion:OGAInternalErrorTypeAdSyncErrorProfigNotSyncedSugg];
}
+ (instancetype)createBase64DecodeError {
    return [OguryError createOguryErrorWithCode:OGAInternalErrorBase64DecodeError
                           localizedDescription:OGAInternalErrorTypeBase64DecodeErrorDesc
                    localizedRecoverySuggestion:OGAInternalErrorTypeBase64DecodeErrorSugg];
}
+ (instancetype)createClientError:(NSUInteger)statusCode {
    return [OguryError createOguryErrorWithCode:OGAInternalClientError
                           localizedDescription:[NSString stringWithFormat:OGAInternalErrorTypeClientErrorDesc, statusCode]
                    localizedRecoverySuggestion:OGAInternalErrorTypeClientErrorSugg];
}
+ (instancetype)createServerError:(NSUInteger)statusCode {
    return [OguryError createOguryErrorWithCode:OGAInternalServerError
                           localizedDescription:[NSString stringWithFormat:OGAInternalErrorTypeServerErrorDesc, statusCode]
                    localizedRecoverySuggestion:OGAInternalErrorTypeServerErrorSugg];
}

+ (OguryAdsErrorType)getOldErrorTypeWith:(NSInteger)newCode {
    switch (newCode) {
        case OguryCoreErrorTypeNoInternetConnection:
            return OguryAdsErrorNoInternetConnection;
        case OguryAdsNotLoadedError:
            return OguryAdsErrorLoadFailed;
        case OguryAdsNotAvailableError:
            return OguryAdsErrorUnknown;
        case OguryAdsAdDisabledError:
            return OguryAdsErrorAdDisable;
        case OguryAdsProfigNotSyncedError:
            return OguryAdsErrorProfigNotSynced;
        case OguryAdsSdkInitNotCalledError:
            return OguryAdsErrorSdkInitNotCalled;
        case OguryAdsAnotherAdAlreadyDisplayedError:
            return OguryAdsErrorAnotherAdAlreadyDisplayed;
        case OguryAdsCantShowAdsInPresentingViewControllerError:
            return OguryAdsErrorCantShowAdsInPresentingViewController;
        case OguryAdsAdExpiredError:
            return OguryAdsErrorAdExpired;
        case OguryAdsAssetKeyNotValidError:
            return OguryAdsErrorUnknown;
        default:
            return OguryAdsErrorUnknown;
    }
}

@end
