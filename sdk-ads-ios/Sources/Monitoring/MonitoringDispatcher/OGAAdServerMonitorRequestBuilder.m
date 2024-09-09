//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGAAdServerMonitorRequestBuilder.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <OguryCore/OguryNetworkRequestBuilder.h>
#import "NSDate+OGAFormatter.h"
#import "OGAAdPrivacyConfiguration.h"
#import "OGAAssetKeyManager.h"
#import "OGAConfigurationUtils.h"
#import "OGADevice.h"
#import "OGADeviceOrientationConstants.h"
#import "OGALog.h"
#import "OGAProfigDao.h"
#import "OGAWebViewUserAgentService.h"
#import "UIDevice+Orientation.h"
#import "OguryAdsError+Internal.h"

@interface OGAAdServerMonitorRequestBuilder ()

@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, retain) NSURL *url;
@property(nonatomic, retain) OGAProfigDao *profigDao;
@property(nonatomic, retain) OGAWebViewUserAgentService *webViewUserAgentService;

@end

#pragma mark - Constants

static NSString *const MonitoringServiceBodyTimestamp = @"sent_at";
static NSString *const MonitoringServiceBodyRequestId = @"request_id";

// app
static NSString *const MonitoringServiceBodyAppDictionary = @"app";
static NSString *const MonitoringServiceBodyAppAssetKey = @"asset_key";
static NSString *const MonitoringServiceBodyAppAssetType = @"asset_type";
static NSString *const MonitoringServiceBodyAppBundleId = @"bundle_id";
static NSString *const MonitoringServiceBodyAppVersion = @"version";

// sdk
static NSString *const MonitoringServiceBodySdkDictionary = @"sdk";
static NSString *const MonitoringServiceBodySdkModuleVersion = @"module_version";

static NSString *const MonitoringServiceBodyDeviceDictionary = @"device";
static NSString *const MonitoringServiceBodyEventsArray = @"events";

static NSString *const MonitoringServiceBodyDeviceOs = @"os";
static NSString *const MonitoringServiceBodyDeviceOsVersion = @"os_version";
static NSString *const MonitoringServiceBodyDeviceManufacturer = @"manufacturer";
static NSString *const MonitoringServiceBodyDeviceModel = @"model";

// screen
static NSString *const MonitoringServiceBodyDeviceScreen = @"screen";
static NSString *const MonitoringServiceBodyDeviceScreenWidth = @"width";
static NSString *const MonitoringServiceBodyDeviceScreenHeight = @"height";
static NSString *const MonitoringServiceBodyDeviceScreenOrientation = @"orientation";

// settings
static NSString *const MonitoringServiceBodyDeviceSettings = @"settings";
static NSString *const MonitoringServiceBodyDeviceTimezone = @"time_zone";
static NSString *const MonitoringServiceBodyDeviceLowPowerMode = @"low_power_mode";

// settings -> local
static NSString *const MonitoringServiceBodyDeviceSettingsLocale = @"locale";
static NSString *const MonitoringServiceBodyDeviceSettingsLocaleCountry = @"country";
static NSString *const MonitoringServiceBodyDeviceSettingsLocaleLanguage = @"language";

// network
static NSString *const MonitoringServiceBodyDeviceNetwork = @"network";
static NSString *const MonitoringServiceBodyDeviceNetworkMobileCountry = @"mobile_country";
static NSString *const MonitoringServiceBodyDeviceNetworkConnectivity = @"connectivity";

// webview
static NSString *const MonitoringServiceBodyDeviceWebview = @"webview";
static NSString *const MonitoringServiceBodyDeviceWebviewUserAgent = @"user_agent";

static NSString *const MonitoringServiceBodyDeviceAssetType = @"ios";

@implementation OGAAdServerMonitorRequestBuilder

- (instancetype)initWithUrl:(NSURL *)url {
    return [self init:url
                assetKeyManager:[OGAAssetKeyManager shared]
                      profigDao:[OGAProfigDao shared]
                            log:[OGALog shared]
        webViewUserAgentService:[OGAWebViewUserAgentService shared]];
}

- (instancetype)init:(NSURL *)url
            assetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                  profigDao:(OGAProfigDao *)profigDao
                        log:(OGALog *)log
    webViewUserAgentService:(OGAWebViewUserAgentService *)webViewUserAgentService {
    if (self = [super init]) {
        _url = url;
        _log = log;
        _assetKeyManager = assetKeyManager;
        _profigDao = profigDao;
        _webViewUserAgentService = webViewUserAgentService;
    }
    return self;
}

- (NSURLRequest *_Nullable)buildRequestWithEvents:(NSArray<id<OGMEventMonitorable>> *)events {
    NSDictionary *body = [self buildBodyFromEvent:events];
    OguryNetworkRequestBuilder *requestBuilder = [[OguryNetworkRequestBuilder alloc] initWithHTTPMethod:OguryNetworkRequestHTTPMethodPOST andURL:self.url];

    NSError *serializationError;
    NSData *payload = [NSJSONSerialization dataWithJSONObject:body options:0 error:&serializationError];
    if (serializationError) {
        [self.log logError:serializationError message:@"Monitoring - Failed to serialize metrics in [buildRequestWithEvent]"];
        return nil;
    } else if (payload == nil) {
        [self.log logError:[OguryError createOguryErrorWithCode:OGAInternalUnknownError] message:@"Monitoring - Failed to serialize metrics in [buildRequestWithEvent] - Payload is nil"];
        return nil;
    }

    [requestBuilder setPayload:payload];

    return [requestBuilder build];
}

- (NSDictionary *)buildBodyFromEvent:(NSArray<id<OGMEventMonitorable>> *)events {
    OGAAdPrivacyConfiguration *privacyConfiguration = [self.profigDao.profigFullResponse getPrivacyConfiguration];
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];

    body[MonitoringServiceBodyTimestamp] = [NSDate timestampInMilliseconds];

    body[MonitoringServiceBodyRequestId] = [[[NSUUID UUID] UUIDString] lowercaseString];

    body[MonitoringServiceBodyAppDictionary] = [[NSMutableDictionary alloc] init];
    body[MonitoringServiceBodyAppDictionary][MonitoringServiceBodyAppAssetKey] = [self.assetKeyManager assetKey];
    body[MonitoringServiceBodyAppDictionary][MonitoringServiceBodyAppAssetType] = MonitoringServiceBodyDeviceAssetType;

    body[MonitoringServiceBodyAppDictionary][MonitoringServiceBodyAppBundleId] = [OGAConfigurationUtils getAppBundleIdentifer];
    body[MonitoringServiceBodyAppDictionary][MonitoringServiceBodyAppVersion] = [OGAConfigurationUtils getAppMarketingVersion];

    body[MonitoringServiceBodySdkDictionary] = [[NSMutableDictionary alloc] init];
    body[MonitoringServiceBodySdkDictionary][MonitoringServiceBodySdkModuleVersion] = OGA_SDK_VERSION;

    NSMutableDictionary *deviceDict = [[NSMutableDictionary alloc] init];
    body[MonitoringServiceBodyDeviceDictionary] = deviceDict;

    OGADevice *device = [self device];
    deviceDict[MonitoringServiceBodyDeviceOs] = [OGAConfigurationUtils getDeviceOS];
    deviceDict[MonitoringServiceBodyDeviceOsVersion] = [device osVersion];
    if ([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionDeviceIds]) {
        deviceDict[MonitoringServiceBodyDeviceManufacturer] = @"Apple";
        deviceDict[MonitoringServiceBodyDeviceModel] = [device name];
    }

    NSMutableDictionary *screenDictionary = [[NSMutableDictionary alloc] init];
    if ([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionDeviceDimensions]) {
        screenDictionary[MonitoringServiceBodyDeviceScreenWidth] = device.screen.width;
        screenDictionary[MonitoringServiceBodyDeviceScreenHeight] = device.screen.height;
    }
    if ([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionDeviceOrientation]) {
        screenDictionary[MonitoringServiceBodyDeviceScreenOrientation] = [self deviceOrientation];
    }
    if (screenDictionary.count > 0) {
        deviceDict[MonitoringServiceBodyDeviceScreen] = screenDictionary;
    }

    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    if ([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionTimezone]) {
        settings[MonitoringServiceBodyDeviceTimezone] = [OGAConfigurationUtils timeZone];
    }
    if ([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionLowPowerMode]) {
        settings[MonitoringServiceBodyDeviceLowPowerMode] = @([self isLowPowered]);
    }
    NSMutableDictionary *locale = [[NSMutableDictionary alloc] init];
    if ([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionLocaleCountry]) {
        locale[MonitoringServiceBodyDeviceSettingsLocaleCountry] = self.locale.countryCode;
    }
    if ([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionLocaleLanguage]) {
        locale[MonitoringServiceBodyDeviceSettingsLocaleLanguage] = self.locale.languageCode;
    }
    if (locale.count > 0) {
        settings[MonitoringServiceBodyDeviceSettingsLocale] = locale;
    }
    if (settings.count > 0) {
        deviceDict[MonitoringServiceBodyDeviceSettings] = settings;
    }

    NSMutableDictionary *network = [[NSMutableDictionary alloc] init];
    if ([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionConnectivity]) {
        network[MonitoringServiceBodyDeviceNetworkConnectivity] = [OGAConfigurationUtils currentNetwork];
    }

    if ([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionMobileCountry]) {
        NSString *simCardCountry = [self getSimCardCountry];
        if (simCardCountry) {
            network[MonitoringServiceBodyDeviceNetworkMobileCountry] = simCardCountry;
        }
    }
    if (network.count > 0) {
        deviceDict[MonitoringServiceBodyDeviceNetwork] = network;
    }

    if ([privacyConfiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionWebviewUserAgent]) {
        if (self.webViewUserAgentService.webViewUserAgent && self.webViewUserAgentService.webViewUserAgent.length > 0) {
            deviceDict[MonitoringServiceBodyDeviceWebview] = [[NSMutableDictionary alloc] init];
            deviceDict[MonitoringServiceBodyDeviceWebview][MonitoringServiceBodyDeviceWebviewUserAgent] = self.webViewUserAgentService.webViewUserAgent;
        }
    }

    NSMutableArray<NSDictionary *> *eventDictArray = [[NSMutableArray alloc] init];
    for (id<OGMEventMonitorable> event in events) {
        [eventDictArray addObject:[event asDisctionary]];
    }
    body[MonitoringServiceBodyEventsArray] = eventDictArray;
    return body;
}

- (BOOL)isLowPowered {
    return [OGAAdConfiguration isOnLowPowerMode];
}

- (NSString *)getSimCardCountry {
    CTCarrier *carrier = [[CTTelephonyNetworkInfo new] subscriberCellularProvider];
    return carrier.isoCountryCode;
}

- (OGADevice *)device {
    return [[OGADevice alloc] init];
}

- (NSString *)deviceOrientation {
    return [UIDevice.currentDevice ogaOrientationString];
}

- (NSLocale *)locale {
    return NSLocale.currentLocale;
}

@end
