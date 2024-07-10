//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGWMonitoringInfoFetcher.h"

#import <OguryCore/OGCInternal.h>

#import "OGWModules.h"
#import "OguryConfigurationPrivate.h"

@interface OGWMonitoringInfoFetcher ()

@property (nonatomic, strong) OGWModules *modules;
@property (nonatomic, copy) OGCInternal *internalCore;
@property (nonatomic, strong) NSBundle *mainBundle;

@end

NSString * const OGWMonitoringInfoFetcherAssetKeyKey = @"asset_key";
NSString * const OGWMonitoringInfoFetcherDeviceOSKey = @"device_os";
NSString * const OGWMonitoringInfoFetcherAppVersionKey = @"app_version";
NSString * const OGWMonitoringInfoFetcherSdkVersionKey = @"sdk_version";
NSString * const OGWMonitoringInfoFetcherCoreVersionKey = @"core_version";
NSString * const OGWMonitoringInfoFetcherAdsVersionKey = @"ads_version";
NSString * const OGWMonitoringInfoFetcherChoiceManagerVersionKey = @"cm_version";
NSString * const OGWMonitoringInfoFetcherFrameworkKey = @"framework";

NSString * const OGWMonitoringInfoFetcherDeviceOSValue = @"IOS";

NSString * const OGWMonitoringInfoFetcherFrameworkNativeKey = @"Native";
NSString * const OGWMonitoringInfoFetcherFrameworkUnityKey = @"Unity";
NSString * const OGWMonitoringInfoFetcherFrameworkCordovaKey = @"Cordova";
NSString * const OGWMonitoringInfoFetcherFrameworkXamarinKey = @"Xamarin";
NSString * const OGWMonitoringInfoFetcherFrameworkAdobeAirKey = @"AdobeAir";
NSString * const OGWMonitoringInfoFetcherFrameworkUnknownKey = @"Unknown";

@implementation OGWMonitoringInfoFetcher

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithModules:[OGWModules shared]
                    internalCore:[OGCInternal shared]
                      mainBundle:NSBundle.mainBundle];
}

- (instancetype)initWithModules:(OGWModules *)modules
                    internalCore:(OGCInternal *)internalCore
                      mainBundle:(NSBundle *)mainBundle {
    if (self = [super init]) {
        _modules = modules;
        _internalCore = internalCore;
        _mainBundle = mainBundle;
    }
    return self;
}

#pragma mark - Methods

- (OGWMonitoringInfo *)populate:(OguryConfiguration *)configuration {
    OGWMonitoringInfo *monitoringInfo = [[OGWMonitoringInfo alloc] init];
    [self populateAssetKey:monitoringInfo configuration:configuration];
    [self populateDeviceOS:monitoringInfo];
    [self populateAppVersion:monitoringInfo];
    [self populateSdkVersion:monitoringInfo];
    [self populateCoreVersion:monitoringInfo];
    [self populateAdsVersion:monitoringInfo];
    [self populateChoiceManagerVersion:monitoringInfo];
    [self populateFramework:monitoringInfo];

    [monitoringInfo putAll:configuration.monitoringInfo];

    return monitoringInfo;
}

- (void)populateAssetKey:(OGWMonitoringInfo *)monitoringInfo configuration:(OguryConfiguration *)configuration {
    [monitoringInfo putValue:configuration.assetKey key:OGWMonitoringInfoFetcherAssetKeyKey];
}

- (void)populateDeviceOS:(OGWMonitoringInfo *)monitoringInfo {
    [monitoringInfo putValue:OGWMonitoringInfoFetcherDeviceOSValue key:OGWMonitoringInfoFetcherDeviceOSKey];
}

- (void)populateAppVersion:(OGWMonitoringInfo *)monitoringInfo {
    [monitoringInfo putValue:self.mainBundle.infoDictionary[@"CFBundleVersion"] key:OGWMonitoringInfoFetcherAppVersionKey];
};

- (void)populateSdkVersion:(OGWMonitoringInfo *)monitoringInfo {
    [monitoringInfo putValue:SDK_VERSION key:OGWMonitoringInfoFetcherSdkVersionKey];
}

- (void)populateFramework:(OGWMonitoringInfo *)monitoringInfo {
    [monitoringInfo putValue:[self getFrameworkStringValue:[self.internalCore getFrameworkType]] key:OGWMonitoringInfoFetcherFrameworkKey];
}

- (void)populateCoreVersion:(OGWMonitoringInfo *)monitoringInfo {
    [self populateModuleVersion:self.modules.coreModule
                         key:OGWMonitoringInfoFetcherCoreVersionKey
              monitoringInfo:monitoringInfo];
}

- (void)populateAdsVersion:(OGWMonitoringInfo *)monitoringInfo {
    [self populateModuleVersion:self.modules.adsModule
                         key:OGWMonitoringInfoFetcherAdsVersionKey
              monitoringInfo:monitoringInfo];
}

- (void)populateChoiceManagerVersion:(OGWMonitoringInfo *)monitoringInfo {
    [self populateModuleVersion:self.modules.choiceManagerModule
                         key:OGWMonitoringInfoFetcherChoiceManagerVersionKey
              monitoringInfo:monitoringInfo];
}

- (void)populateModuleVersion:(OGWModule *)module key:(NSString *)key monitoringInfo:(OGWMonitoringInfo *)monitoringInfo {
    if (module && module.isPresent) {
        [monitoringInfo putValue:[module getVersion] key:key];
    }
}

- (NSString *)getFrameworkStringValue:(OGCSDKType)type {
    switch (type) {
        case OGCSDKTypeNative:
            return OGWMonitoringInfoFetcherFrameworkNativeKey;
        case OGCSDKTypeUnity:
            return OGWMonitoringInfoFetcherFrameworkUnityKey;
        case OGCSDKTypeCordova:
            return OGWMonitoringInfoFetcherFrameworkCordovaKey;
        case OGCSDKTypeXamarin:
            return OGWMonitoringInfoFetcherFrameworkXamarinKey;
        case OGCSDKTypeAdobeAir:
            return OGWMonitoringInfoFetcherFrameworkAdobeAirKey;
        case OGCSDKEnumCount:
            return OGWMonitoringInfoFetcherFrameworkUnknownKey;
    }
    return OGWMonitoringInfoFetcherFrameworkUnknownKey;
}


@end
