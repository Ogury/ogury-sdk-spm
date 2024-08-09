//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAConfigurationUtils+Profig.h"
#import "OGAAdIdentifierService.h"
#import "OGADevice.h"
#import "OGAProfigFullResponse.h"
#import "OGAConstants.h"
#import "OGAAssetKeyManager.h"

static NSString *const OGAProfigBodyDeviceKey = @"device";
static NSString *const OGAProfigBodyAssetKey = @"asset_key";
static NSString *const OGAProfigBodyAssetType = @"asset_type";
static NSString *const OGAProfigBodyBundleId = @"bundle_id";
static NSString *const OGAProfigBodyDeviceSDK = @"sdk";
static NSString *const OGAProfigBodyDeviceModuleVersion = @"module_version";

@implementation OGAConfigurationUtils (OGAConfigurationUtils)

+ (NSMutableDictionary *)profigParams {
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    // App
    content[OGARequestBodyAppKey] = [NSMutableDictionary dictionary];
    content[OGARequestBodyAppKey][OGARequestBodyAppVersionKey] = [OGAConfigurationUtils getAppMarketingVersion];
    content[OGARequestBodyAppKey][OGAProfigBodyAssetKey] = [[OGAAssetKeyManager shared] assetKey];
    content[OGARequestBodyAppKey][OGAProfigBodyBundleId] = [OGAConfigurationUtils getAppBundleIdentifer];
    content[OGARequestBodyAppKey][OGAProfigBodyAssetType] = [OGAConfigurationUtils getDeviceOS];
    // SDK
    content[OGAProfigBodyDeviceSDK] = [NSMutableDictionary dictionary];
    content[OGAProfigBodyDeviceSDK][OGAProfigBodyDeviceModuleVersion] = OGA_SDK_VERSION;
    // device
    content[OGAProfigBodyDeviceKey] = [[[OGADevice alloc] init] mapped];
    // Privacy
    content[OGARequestBodyPrivacyComplianceKey] = [NSMutableDictionary dictionary];
    content[OGARequestBodyPrivacyComplianceKey][OGARequestBodyPrivacyTCFKey] = [self tcfConsentString];
    content[OGARequestBodyPrivacyComplianceKey][OGARequestBodyPrivacyGPPKey] = [self gppConsentString];
    content[OGARequestBodyPrivacyComplianceKey][OGARequestBodyPrivacyGPPSIDKey] = [self gppSidConsentString];

    return content;
}

+ (NSString *)gppConsentString {
    return [OGAAdIdentifierService gppConsentString];
}

+ (NSString *)gppSidConsentString {
    return [OGAAdIdentifierService gppSID];
}

+ (NSString *)tcfConsentString {
    return [OGAAdIdentifierService tcfConsentString];
}

+ (NSError *)errorForOGAProfigError:(OGAProfigExternalError)profigError {
    NSString *message = @"Internal error";
    switch (profigError) {
        case OGAProfigExternalErrorNoInternet:
            message = @"No Internet Connection.";
            break;
        case OGAProfigExternalErrorAlreadyLoading:
            message = @"Ogury Ads Setup already loading.";
            break;
        case OGAProfigExternalErrorSetupFailed:
            message = @"Ogury Ads Setup Failed !";
        default:
            break;
    }
    NSError *error = [NSError errorWithDomain:@"OguryAds" code:profigError userInfo:@{NSLocalizedDescriptionKey : message}];
    return error;
}

+ (NSError *)errorForServerProfigError:(OGAProfigFullResponse *)response {
    OGAProfigExternalError errorCode = OGAProfigExternalErrorSetupFailed;
    NSString *message = [NSString stringWithFormat:@"%@ : %@", response.errorType ?: @"Internal error", response.errorMessage ?: @"Can't sync profig"];
    NSError *error = [NSError errorWithDomain:@"OguryAds" code:errorCode userInfo:@{NSLocalizedDescriptionKey : message}];
    return error;
}

@end
