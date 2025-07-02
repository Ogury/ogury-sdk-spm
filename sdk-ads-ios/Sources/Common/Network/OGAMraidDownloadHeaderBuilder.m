//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAMraidDownloadHeaderBuilder.h"
#import "OGAConfigurationUtils.h"
#import "OGAAdManager.h"
#import "OGAAdIdentifierService.h"
#import "OGAAssetKeyManager.h"

@implementation OGAMraidDownloadHeaderBuilder

#pragma mark - Constants

static NSString *const OGAProfigHeaderBuilderUser = @"User";
static NSString *const OGAProfigHeaderBuilderInstanceToken = @"Instance-Token";
static NSString *const OGAProfigHeaderBuilderDeviceOS = @"Device-OS";
static NSString *const OGAProfigHeaderBuilderUserAgent = @"User-Agent";
static NSString *const OGAProfigHeaderBuilderPackageName = @"Package-Name";
static NSString *const OGAProfigHeaderBuilderSDKVersionType = @"sdk-Version-Type";
static NSString *const OGAProfigHeaderBuilderSDKVersion = @"sdk-Version";
static NSString *const OGAProfigHeaderBuilderSDKType = @"Sdk-Type";
static NSString *const OGAProfigHeaderBuilderMediation = @"Mediation";
static NSString *const OGAProfigHeaderBuilderFramework = @"Framework";
static NSString *const OGAProfigHeaderBuilderTimeZone = @"Timezone";
static NSString *const OGAProfigHeaderBuilderConnectivity = @"Connectivity";
static NSString *const OGAProfigHeaderBuilderApiKey = @"Api-Key";

#pragma mark - Methods

+ (NSDictionary<NSString *, NSString *> *)build {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[OGAProfigHeaderBuilderInstanceToken] = [OGAAdIdentifierService getInstanceToken];
    headers[OGAProfigHeaderBuilderUserAgent] = [OGAAdIdentifierService getUserAgent];
    headers[OGAProfigHeaderBuilderDeviceOS] = [OGAConfigurationUtils getDeviceOS];
    headers[OGAProfigHeaderBuilderPackageName] = NSBundle.mainBundle.bundleIdentifier ?: @"";
    headers[OGAProfigHeaderBuilderSDKVersionType] = [OGAConfigurationUtils getSDKType];
    headers[OGAProfigHeaderBuilderSDKVersion] = [NSString stringWithFormat:@"[%@]", OGA_SDK_VERSION];
    headers[OGAProfigHeaderBuilderSDKType] = [NSString stringWithFormat:@"%lu", (unsigned long)[OGAAdManager sharedManager].sdkType];
    headers[OGAProfigHeaderBuilderMediation] = [NSString stringWithFormat:@"%@", [OGAAdManager sharedManager].mediation];
    headers[OGAProfigHeaderBuilderFramework] = [NSString stringWithFormat:@"%lu", (unsigned long)[OGAConfigurationUtils getFrameworkType]];
    headers[OGAProfigHeaderBuilderTimeZone] = [OGAConfigurationUtils timeZone];
    headers[OGAProfigHeaderBuilderConnectivity] = [OGAConfigurationUtils currentNetwork];
    headers[OGAProfigHeaderBuilderApiKey] = [NSString stringWithFormat:@"[%@]", OGAAssetKeyManager.shared.assetKey];

    return [NSDictionary dictionaryWithDictionary:headers];
}

@end
