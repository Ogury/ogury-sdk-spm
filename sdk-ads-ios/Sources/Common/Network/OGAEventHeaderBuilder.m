//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGAEventHeaderBuilder.h"
#import "OGAConfigurationUtils.h"
#import "OGAAdManager.h"
#import "OGAAdIdentifierService.h"
#import "OGAAssetKeyManager.h"
#import "OGAAdHistoryEvent.h"
#import "OGAPreCacheEvent.h"
#import "OGATrackEvent.h"
#import <OguryCore/OGCUtils.h>

@implementation OGAEventHeaderBuilder

#pragma mark - Constants

static NSString *const OGAProfigHeaderBuilderUser = @"User";
static NSString *const OGAProfigHeaderBuilderInstanceToken = @"Instance-Token";
static NSString *const OGAProfigHeaderBuilderDeviceOS = @"Device-OS";
static NSString *const OGAProfigHeaderBuilderUserAgent = @"User-Agent";
static NSString *const OGAProfigHeaderBuilderPackageName = @"Package-Name";
static NSString *const OGAProfigHeaderBuilderSDKVersionType = @"Sdk-Version-Type";
static NSString *const OGAProfigHeaderBuilderSDKVersion = @"Sdk-Version";
static NSString *const OGAProfigHeaderBuilderSDKType = @"Sdk-Type";
static NSString *const OGAProfigHeaderBuilderMediation = @"Mediation";
static NSString *const OGAProfigHeaderBuilderFramework = @"Framework";
static NSString *const OGAProfigHeaderBuilderTimeZone = @"Timezone";
static NSString *const OGAProfigHeaderBuilderConnectivity = @"Connectivity";
static NSString *const OGAProfigHeaderBuilderApiKey = @"Api-Key";
static NSString *const OGAProfigHeaderBuilderEmptyIDFA = @"00000000-0000-0000-0000-000000000000";

#pragma mark - Methods

+ (NSDictionary<NSString *, NSString *> *)buildFor:(OGAMetricEvent *)event {
    if (([event isKindOfClass:[OGAAdHistoryEvent class]] ||
         [event isKindOfClass:[OGATrackEvent class]])) {
        return [OGAEventHeaderBuilder buildForTrackAndHistory:event];
    }
    if (([event isKindOfClass:[OGAPreCacheEvent class]])) {
        return [OGAEventHeaderBuilder buildForPreCacheLog:event];
    }
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[OGAProfigHeaderBuilderUserAgent] = [OGAAdIdentifierService getUserAgent];
    headers[OGAProfigHeaderBuilderDeviceOS] = [OGAConfigurationUtils getDeviceOS];
    headers[OGAProfigHeaderBuilderPackageName] = [OGAConfigurationUtils getAppBundleIdentifer] ?: @"";
    headers[OGAProfigHeaderBuilderSDKVersionType] = [OGAConfigurationUtils getSDKType];
    headers[OGAProfigHeaderBuilderSDKVersion] = [NSString stringWithFormat:@"[%@]", OGA_SDK_VERSION];
    headers[OGAProfigHeaderBuilderSDKType] = [NSString stringWithFormat:@"%lu", (unsigned long)[OGAAdManager sharedManager].sdkType];
    headers[OGAProfigHeaderBuilderMediation] = [NSString stringWithFormat:@"%@", [OGAAdManager sharedManager].mediation];
    headers[OGAProfigHeaderBuilderFramework] = [NSString stringWithFormat:@"%lu", (unsigned long)[OGCUtils frameworkType]];
    headers[OGAProfigHeaderBuilderApiKey] = [NSString stringWithFormat:@"[%@]", OGAAssetKeyManager.shared.assetKey];
    return [NSDictionary dictionaryWithDictionary:headers];
}

+ (NSDictionary<NSString *, NSString *> *)buildForTrackAndHistory:(OGAMetricEvent *)event {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[OGAProfigHeaderBuilderUser] = [event.privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA] ? [OGAAdIdentifierService getAdIdentifier] : OGAProfigHeaderBuilderEmptyIDFA;
    if ([event.privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken]) {
        headers[OGAProfigHeaderBuilderInstanceToken] = [OGAAdIdentifierService getInstanceToken];
    }
    headers[OGAProfigHeaderBuilderUserAgent] = [OGAAdIdentifierService getUserAgent];
    headers[OGAProfigHeaderBuilderDeviceOS] = [OGAConfigurationUtils getDeviceOS];
    headers[OGAProfigHeaderBuilderPackageName] = [OGAConfigurationUtils getAppBundleIdentifer] ?: @"";
    return [NSDictionary dictionaryWithDictionary:headers];
}

+ (NSDictionary<NSString *, NSString *> *)buildForPreCacheLog:(OGAMetricEvent *)event {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[OGAProfigHeaderBuilderUserAgent] = [OGAAdIdentifierService getUserAgent];
    headers[OGAProfigHeaderBuilderDeviceOS] = [OGAConfigurationUtils getDeviceOS];
    headers[OGAProfigHeaderBuilderPackageName] = [OGAConfigurationUtils getAppBundleIdentifer] ?: @"";
    headers[OGAProfigHeaderBuilderApiKey] = [NSString stringWithFormat:@"[%@]", OGAAssetKeyManager.shared.assetKey];
    headers[OGAProfigHeaderBuilderSDKVersion] = [NSString stringWithFormat:@"[%@]", OGA_SDK_VERSION];
    if ([event.privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionTimezone]) {
        headers[OGAProfigHeaderBuilderTimeZone] = [OGAConfigurationUtils timeZone];
    }
    if ([event.privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionConnectivity]) {
        headers[OGAProfigHeaderBuilderConnectivity] = [OGAConfigurationUtils currentNetwork];
    }
    headers[OGAProfigHeaderBuilderSDKVersionType] = [OGAConfigurationUtils getSDKType];
    headers[OGAProfigHeaderBuilderSDKType] = [NSString stringWithFormat:@"%lu", (unsigned long)[OGAAdManager sharedManager].sdkType];
    return [NSDictionary dictionaryWithDictionary:headers];
}

@end
