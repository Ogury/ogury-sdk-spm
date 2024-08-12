//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+OGAFormatter.h"
#import "OGAAdConfiguration+AdSync.h"
#import "OGAAdIdentifierService.h"
#import "OGAConfigurationUtils.h"
#import "OGAConstants.h"
#import "OGADevice.h"
#import "OGADeviceOrientationConstants.h"
#import "OGAOMIDService.h"
#import "OGAReachability.h"
#import "OGASKAdNetworkService.h"
#import "OGAThumbnailAdConstants.h"
#import "OGAWebViewUserAgentService.h"

@implementation OGAAdConfiguration (AdSync)

#pragma mark - Constants

static NSString *const AdSyncServiceBodyNameKey = @"name";
static NSString *const AdSyncServiceBodyConnectivityeKey = @"connectivity";
static NSString *const AdSyncServiceBodyTimestampKey = @"sent_at";
static NSString *const AdSyncServiceBodyRequestIdKey = @"request_id";
static NSString *const AdSyncServiceBodyCountryKey = @"country";
static NSString *const AdSyncServiceBodyBuildKey = @"build";
static NSString *const AdSyncServiceBodyAppsPublishersKey = @"apps_publishers";
static NSString *const AdSyncServiceBodyVersionKey = @"version";
static NSString *const AdSyncServiceBodySKAdNetworkKey = @"skadnetwork";
static NSString *const AdSyncServiceBodySKAdNetworkVersion = @"version";
static NSString *const AdSyncServiceBodySKAdNetworkIdentifierList = @"identifier_list";
static NSString *const AdSyncServiceBodyDeviceKey = @"device";
static NSString *const AdSyncServiceBodyAppKey = @"app";
static NSString *const AdSyncServiceBodyDeviceWidthKey = @"width";
static NSString *const AdSyncServiceBodyDeviceHeightKey = @"height";
static NSString *const AdSyncServiceBodyDeviceOrientationKey = @"orientation";
static NSString *const AdSyncServiceBodyAssetKeyKey = @"asset_key";
static NSString *const AdSyncServiceBodyAssetTypeKey = @"asset_type";
static NSString *const AdSyncServiceBodyInstanceTokenKey = @"instance_token";
static NSString *const AdSyncServiceBodySDKKey = @"sdk";
static NSString *const AdSyncServiceBodyBundleIdKey = @"bundle_id";
static NSString *const AdSyncServiceBodyModuleVersionKey = @"module_version";
static NSString *const AdSyncServiceBodyOSKey = @"os";
static NSString *const AdSyncServiceBodyIOSValue = @"ios";
static NSString *const AdSyncServiceBodyOSVersionKey = @"os_version";
static NSString *const AdSyncServiceBodyManufacturerKey = @"manufacturer";
static NSString *const AdSyncServiceBodyModelKey = @"model";
static NSString *const AdSyncServiceBodyIsiOSAppOnMacKey = @"ios_app_on_mac";
static NSString *const AdSyncServiceBodyScreenKey = @"screen";
static NSString *const AdSyncServiceBodySettingsKey = @"settings";
static NSString *const AdSyncServiceBodyTimeZoneKey = @"time_zone";
static NSString *const AdSyncServiceBodyAdTrackingEnabledKey = @"is_ad_tracking_enabled";
static NSString *const AdSyncServiceBodyIDFAKey = @"device_id";
static NSString *const AdSyncServiceBodyIDFVKey = @"vendor_id";
static NSString *const AdSyncServiceBodyLanguageKey = @"language";
static NSString *const AdSyncServiceBodyLocaleKey = @"locale";
static NSString *const AdSyncServiceBodyWebviewKey = @"webview";
static NSString *const AdSyncServiceBodyUserAgentKey = @"user_agent";
static NSString *const AdSyncServiceBodyNetworkKey = @"network";
static NSString *const AdSyncServiceBodyMobileCountryKey = @"mobile_country";

static NSString *const AdSyncServiceBodyAdSyncKey = @"ad_sync";
static NSString *const AdSyncServiceBodyAdKey = @"ad";
static NSString *const AdSyncServiceBodyContentAdSyncTypeKey = @"type";
static NSString *const AdSyncServiceBodyContentAdSyncTypeLoadKey = @"load";
static NSString *const AdSyncServiceBodyContentAdUnitIdNameKey = @"ad_unit_id";
static NSString *const AdSyncServiceBodyCampaignToloadKey = @"campaign_id";
static NSString *const AdSyncServiceBodyCreativeIDKey = @"creative_id";
static NSString *const AdSyncServiceBodyLowBatteryModeKey = @"low_power_mode";

static NSString *const AdSyncServiceBodyDspKey = @"dsp";
static NSString *const AdSyncServiceBodyRegionKey = @"region";

static NSString *const AdSyncServiceBodyContentOmidIntegrationIsCompliantKey = @"is_compliant";
static NSString *const AdSyncServiceBodyContentOmidKey = @"omid";
static NSString *const AdSyncServiceBodyContentOmidIntegrationVersionKey = @"integration_version";

static NSString *const AdSyncServiceBodyContentIsMoatCompliantKey = @"is_moat_compliant";
static NSString *const AdSyncServiceBodyContentOverlayKey = @"overlay";
static NSString *const AdSyncServiceBodyContentOverlayMaximumSizeKey = @"overlay_max_size";
static NSString *const AdSyncServiceBodyContentOverlayMaximumSizeWidthKey = @"width";
static NSString *const AdSyncServiceBodyContentOverlayMaximumSizeHeightKey = @"height";
static NSString *const AdSyncServiceBodyContentOverlayMaximumSizeScaleKey = @"scaler";

#pragma mark - Methods

- (NSDictionary *)payloadForAdSyncWithAssetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                                         reachability:(OGAReachability *)reachability
                                    profigPersistence:(OGAProfigDao *)profigPersistence
                               isOmidFrameworkPresent:(BOOL)isOmidFrameworkPresent {
    return [self payloadForAdSyncWithAssetKeyManager:assetKeyManager
                                        reachability:reachability
                                   profigPersistence:profigPersistence
                              isOmidFrameworkPresent:isOmidFrameworkPresent
                                    userAgentService:[OGAWebViewUserAgentService shared]];
}

- (NSDictionary *)payloadForAdSyncWithAssetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                                         reachability:(OGAReachability *)reachability
                                    profigPersistence:(OGAProfigDao *)profigPersistence
                               isOmidFrameworkPresent:(BOOL)isOmidFrameworkPresent
                                     userAgentService:(OGAWebViewUserAgentService *)userAgentService {
    OGAAdPrivacyConfiguration *privacyConfiguration = [profigPersistence.profigFullResponse getPrivacyConfiguration];
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    body[AdSyncServiceBodyTimestampKey] = [NSDate timestampInMilliseconds];
    body[AdSyncServiceBodyRequestIdKey] = [[self requestId] lowercaseString];

    // Privacy
    body[OGARequestBodyPrivacyComplianceKey] = [NSMutableDictionary dictionary];
    body[OGARequestBodyPrivacyComplianceKey][OGARequestBodyPrivacyTCFKey] = [self tcfConsentString];
    body[OGARequestBodyPrivacyComplianceKey][OGARequestBodyPrivacyGPPKey] = [self gppConsentString];
    body[OGARequestBodyPrivacyComplianceKey][OGARequestBodyPrivacyGPPSIDKey] = [self gppSidConsentString];
    NSDictionary *privacyDatas = [self privacyDatas];
    [privacyDatas enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        body[OGARequestBodyPrivacyComplianceKey][key] = obj;
    }];

    // app
    body[AdSyncServiceBodyAppKey] = [@{} mutableCopy];
    body[AdSyncServiceBodyAppKey][AdSyncServiceBodyAssetKeyKey] = [assetKeyManager assetKey];
    body[AdSyncServiceBodyAppKey][AdSyncServiceBodyAssetTypeKey] = [OGAConfigurationUtils getDeviceOS];
    body[AdSyncServiceBodyAppKey][AdSyncServiceBodyBundleIdKey] = [OGAConfigurationUtils getAppBundleIdentifer];
    body[AdSyncServiceBodyAppKey][AdSyncServiceBodyVersionKey] = [NSString stringWithFormat:@"%@.%@", [OGAConfigurationUtils getAppMarketingVersion], [OGAConfigurationUtils getAppBuildVersion]];
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken]) {
        body[AdSyncServiceBodyAppKey][AdSyncServiceBodyInstanceTokenKey] = [OGAAdIdentifierService getInstanceToken];
    }

    // sdk
    body[AdSyncServiceBodySDKKey] = [@{} mutableCopy];
    body[AdSyncServiceBodySDKKey][AdSyncServiceBodyModuleVersionKey] = [self sdkVersion];

    // device
    body[AdSyncServiceBodyDeviceKey] = [@{} mutableCopy];
    body[AdSyncServiceBodyDeviceKey][AdSyncServiceBodyOSKey] = [OGAConfigurationUtils getDeviceOS];
    body[AdSyncServiceBodyDeviceKey][AdSyncServiceBodyOSVersionKey] = [OGAConfigurationUtils getDeviceOSVersion];
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionDeviceIds]) {
        body[AdSyncServiceBodyDeviceKey][AdSyncServiceBodyManufacturerKey] = [OGAConfigurationUtils getManufacturer];
        body[AdSyncServiceBodyDeviceKey][AdSyncServiceBodyModelKey] = [[self currentDevice] name];
    }
    body[AdSyncServiceBodyDeviceKey][AdSyncServiceBodyIsiOSAppOnMacKey] = @([OGAConfigurationUtils isiOSAppOnMac]);

    // screen
    NSMutableDictionary *screen = [@{} mutableCopy];
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionDeviceDimensions]) {
        CGSize screenSize = [self screenSize];
        NSInteger width = screenSize.width;
        NSInteger height = screenSize.height;
        screen[AdSyncServiceBodyDeviceWidthKey] = @(width);
        screen[AdSyncServiceBodyDeviceHeightKey] = @(height);
    }
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionDeviceOrientation]) {
        screen[AdSyncServiceBodyDeviceOrientationKey] = [self orientation];
    }
    if (screen.count > 0) {
        body[AdSyncServiceBodyDeviceKey][AdSyncServiceBodyScreenKey] = screen;
    }
    // settings
    NSMutableDictionary *settings = [@{} mutableCopy];
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionAdTracking]) {
        settings[AdSyncServiceBodyAdTrackingEnabledKey] = [OGAAdIdentifierService isAdOptin] ? @(YES) : @(NO);
    }
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionTimezone]) {
        NSInteger secondsFromGMT = [self secondsFromGMT];
        NSString *timeZone = [[NSString alloc] initWithFormat:@"%@%0.2ld:00", secondsFromGMT > 0 ? @"+" : @"-", secondsFromGMT / 3600];
        settings[AdSyncServiceBodyTimeZoneKey] = timeZone;
    }
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA]) {
        settings[AdSyncServiceBodyIDFAKey] = [OGAAdIdentifierService getAdIdentifier];
    }
    NSMutableDictionary *locale = [@{} mutableCopy];
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionLocaleLanguage]) {
        locale[AdSyncServiceBodyLanguageKey] = self.locale.languageCode;
    }
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionLocaleCountry]) {
        locale[AdSyncServiceBodyCountryKey] = self.locale.countryCode;
    }
    if (locale.count > 0) {
        settings[AdSyncServiceBodyLocaleKey] = locale;
    }
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFV]) {
        settings[AdSyncServiceBodyIDFVKey] = [OGAAdIdentifierService getVendorIdentifier];
    }
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionLowPowerMode]) {
        settings[AdSyncServiceBodyLowBatteryModeKey] = self.lowBatteryMode ? @(YES) : @(NO);
    }
    body[AdSyncServiceBodyDeviceKey][AdSyncServiceBodySettingsKey] = settings;
    // webview

    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionWebviewUserAgent] && userAgentService.webViewUserAgent && userAgentService.webViewUserAgent.length > 0) {
        body[AdSyncServiceBodyDeviceKey][AdSyncServiceBodyWebviewKey] = @{AdSyncServiceBodyUserAgentKey : userAgentService.webViewUserAgent};
    }
    // network
    NSMutableDictionary *network = [@{} mutableCopy];
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionConnectivity]) {
        network[AdSyncServiceBodyConnectivityeKey] = reachability.currentReachabilityNetwork;
    }
    if ([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionMobileCountry]) {
        network[AdSyncServiceBodyMobileCountryKey] = self.locale.countryCode;
    }
    if (network.count > 0) {
        body[AdSyncServiceBodyDeviceKey][AdSyncServiceBodyNetworkKey] = network;
    }

    // ad_sync
    NSMutableDictionary *adSync = [@{} mutableCopy];
    adSync[AdSyncServiceBodyNameKey] = [self getAdTypeString];
    adSync[AdSyncServiceBodyContentAdSyncTypeKey] = AdSyncServiceBodyContentAdSyncTypeLoadKey;

    NSMutableDictionary *ad = [@{} mutableCopy];
    ad[AdSyncServiceBodyContentAdUnitIdNameKey] = self.adUnitId;

    if (self.campaignId && ![self.campaignId isEqualToString:@""]) {
        ad[AdSyncServiceBodyCampaignToloadKey] = self.campaignId;
    }

    if (self.creativeId && ![self.creativeId isEqualToString:@""]) {
        ad[AdSyncServiceBodyCreativeIDKey] = self.creativeId;
    }

    if (self.adDsp) {
        NSMutableDictionary *adDsp = [@{} mutableCopy];
        if (self.adDsp.creativeId && ![self.adDsp.creativeId isEqualToString:@""]) {
            adDsp[AdSyncServiceBodyCreativeIDKey] = self.adDsp.creativeId;
        }
        if (self.adDsp.region && ![self.adDsp.region isEqualToString:@""]) {
            adDsp[AdSyncServiceBodyRegionKey] = self.adDsp.region;
        }
        ad[AdSyncServiceBodyDspKey] = adDsp;
    }
    adSync[AdSyncServiceBodyAdKey] = ad;

    BOOL isOMIDCompliant = (profigPersistence.profigFullResponse.isOmidEnabled && isOmidFrameworkPresent);
    adSync[AdSyncServiceBodyContentOmidKey] = @{
        AdSyncServiceBodyContentOmidIntegrationIsCompliantKey : isOMIDCompliant ? @(YES) : @(NO),
        AdSyncServiceBodyContentOmidIntegrationVersionKey : @([OGAOMIDService omidVersion])
    };

    if ([OGASKAdNetworkService sdkIsCompatibleWithSKAdNetwork]) {
        adSync[AdSyncServiceBodySKAdNetworkKey] = @{
            AdSyncServiceBodySKAdNetworkVersion : [OGASKAdNetworkService getSKAdNetworkVersion],
            AdSyncServiceBodySKAdNetworkIdentifierList : [OGASKAdNetworkService getInfoAdNetworkItems]
        };
    }
    if ([[self getAdTypeString] isEqualToString:OGAAdConfigurationAdTypeThumbnailAd]) {
        adSync[AdSyncServiceBodyContentOverlayKey] = @{
            AdSyncServiceBodyContentOverlayMaximumSizeKey : @{
                AdSyncServiceBodyContentOverlayMaximumSizeWidthKey : @(OGAThumbnailDefaultWidth),
                AdSyncServiceBodyContentOverlayMaximumSizeHeightKey : @(OGAThumbnailDefaultHeight),
                AdSyncServiceBodyContentOverlayMaximumSizeScaleKey : @([OGAConfigurationUtils screenScale])
            }
        };
    }
    body[AdSyncServiceBodyAdSyncKey] = adSync;

    return body;
}

- (NSString *)gppConsentString {
    return [OGAAdIdentifierService gppConsentString];
}

- (NSString *)gppSidConsentString {
    return [OGAAdIdentifierService gppSID];
}

- (NSString *)tcfConsentString {
    return [OGAAdIdentifierService tcfConsentString];
}

- (NSDictionary<NSString*, NSString*>*)privacyDatas {
    return @{};
}

- (NSString *)sdkVersion {
    return OGA_SDK_VERSION;
}

- (OGADevice *)currentDevice {
    return [[OGADevice alloc] init];
}

- (CGSize)screenSize {
    CGRect screenBounds = UIScreen.mainScreen.bounds;
    return CGSizeMake(screenBounds.size.width, screenBounds.size.height);
}

- (NSString *)orientation {
    return [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait ? OGAOrientationStringPortrait : OGAOrientationStringLandscape;
}

- (NSInteger)secondsFromGMT {
    return [[NSTimeZone systemTimeZone] secondsFromGMT];
}

+ (NSString *)countryCode {
    return [NSLocale.currentLocale objectForKey:NSLocaleCountryCode] ?: @"";
}

- (NSString *)requestId {
    return [[NSUUID new] UUIDString];
}

@end
