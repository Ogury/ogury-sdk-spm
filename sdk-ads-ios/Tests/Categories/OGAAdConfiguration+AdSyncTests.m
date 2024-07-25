//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "NSDate+OGAFormatter.h"
#import "NSDateFormatter+OGAUtils.h"
#import "OGAAdConfiguration+AdSync.h"
#import "OGAAdConfiguration.h"
#import "OGAAdIdentifierService.h"
#import "OGAConfigurationUtils.h"
#import "OGADevice.h"
#import "OGAProfigDao.h"
#import "OGAProfigManager.h"
#import "OGAReachability.h"
#import "OGASKAdNetworkService.h"
#import "OGAWebViewUserAgentService.h"

@interface OGAAdConfiguration ()

- (instancetype)initWithType:(OguryAdsADType)type
                    adUnitId:(NSString *)adUnitId
          delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
      viewControllerProvider:(OGAViewControllerProvider)viewControllerProvider
                viewProvider:(OGAViewProvider _Nullable)viewProvider
                      locale:(NSLocale *)locale;

- (NSDictionary *)payloadForAdSyncWithAssetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                                         reachability:(OGAReachability *)reachability
                                    profigPersistence:(OGAProfigDao *)profigPersistence
                               isOmidFrameworkPresent:(BOOL)isOmidFrameworkPresent
                                     userAgentService:(OGAWebViewUserAgentService *)userAgentService;
- (NSString *)sdkVersion;
- (OGADevice *)currentDevice;
- (CGSize)screenSize;
- (NSString *)orientation;
- (NSInteger)secondsFromGMT;
- (NSLocale *)locale;
- (NSString *)requestId;

@end

@interface OGAAdConfiguration_AdSyncTests : XCTestCase

#pragma mark - Properties

@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, strong) OGAReachability *reachability;
@property(nonatomic, strong) OGAProfigManager *profigManager;

@end

@implementation OGAAdConfiguration_AdSyncTests

#pragma mark - Constants

static NSString *const DefaultCampaignID = @"Campaign";
static NSString *const DefaultCreativeID = @"Creative";
static NSString *const DefaultDspRegion = @"dspRegion";
static NSString *const DefaultDspCreativeID = @"dspCreative";
static NSString *const DefaultAdUnitID = @"AdUnit";
static NSString *const DefaultUserID = @"User";

#pragma mark - Methods

- (void)setUp {
    self.assetKeyManager = OCMClassMock([OGAAssetKeyManager class]);

    self.reachability = OCMPartialMock([OGAReachability reachabilityForInternetConnection]);
    [self.reachability startNotifier];

    self.profigManager = [OGAProfigManager shared];
    [self.profigManager resetProfig];

    // Mock asset key and user agent
    OCMStub(self.assetKeyManager.assetKey).andReturn(@"OGY-XXXXXXXX");
    self.profigManager.currentUserAgent = @"User-Agent";
}

- (void)tearDown {
    [self.reachability stopNotifier];
}

- (void)testShouldReturnAdSyncPayload {
    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                                        adUnitId:DefaultAdUnitID
                                                              delegateDispatcher:delegateDispatcher
                                                          viewControllerProvider:nil
                                                                    viewProvider:nil];
    configuration.userId = DefaultUserID;

    NSDictionary *payload = [configuration payloadForAdSyncWithAssetKeyManager:self.assetKeyManager
                                                                  reachability:self.reachability
                                                             profigPersistence:[[OGAProfigDao alloc] init]
                                                        isOmidFrameworkPresent:YES];
    XCTAssertEqual(payload.count, 7);
}

- (void)testLowBatteryModeOn {
    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    NSLocale *locale = OCMClassMock([NSLocale class]);
    OGAAdConfiguration *configuration = OCMPartialMock([[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                                                       adUnitId:DefaultAdUnitID
                                                                             delegateDispatcher:delegateDispatcher
                                                                         viewControllerProvider:nil
                                                                                   viewProvider:nil
                                                                                         locale:locale]);
    configuration.userId = DefaultUserID;
    OGAProfigDao *dao = OCMPartialMock([[OGAProfigDao alloc] init]);
    OGAProfigFullResponse *profig = OCMClassMock([OGAProfigFullResponse class]);
    OGAAdPrivacyConfiguration *privacy = OCMClassMock([OGAAdPrivacyConfiguration class]);
    OCMStub([dao profigFullResponse]).andReturn(profig);
    OCMStub([profig getPrivacyConfiguration]).andReturn(privacy);
    OCMStub([privacy adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionLowPowerMode]).andReturn(YES);
    OCMStub([configuration lowBatteryMode]).andReturn(YES);

    NSDictionary *payload = [configuration payloadForAdSyncWithAssetKeyManager:self.assetKeyManager
                                                                  reachability:self.reachability
                                                             profigPersistence:dao
                                                        isOmidFrameworkPresent:YES];
    XCTAssertEqual(payload[@"device"][@"settings"][@"low_power_mode"], @YES);
}

- (void)testLowBatteryModeOff {
    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    NSLocale *locale = OCMClassMock([NSLocale class]);
    OGAAdConfiguration *configuration = OCMPartialMock([[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                                                       adUnitId:DefaultAdUnitID
                                                                             delegateDispatcher:delegateDispatcher
                                                                         viewControllerProvider:nil
                                                                                   viewProvider:nil
                                                                                         locale:locale]);
    configuration.userId = DefaultUserID;
    OGAProfigDao *dao = OCMPartialMock([[OGAProfigDao alloc] init]);
    OGAProfigFullResponse *profig = OCMClassMock([OGAProfigFullResponse class]);
    OGAAdPrivacyConfiguration *privacy = OCMClassMock([OGAAdPrivacyConfiguration class]);
    OCMStub([dao profigFullResponse]).andReturn(profig);
    OCMStub([profig getPrivacyConfiguration]).andReturn(privacy);
    OCMStub([privacy adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionLowPowerMode]).andReturn(YES);
    OCMStub([configuration lowBatteryMode]).andReturn(NO);

    NSDictionary *payload = [configuration payloadForAdSyncWithAssetKeyManager:self.assetKeyManager
                                                                  reachability:self.reachability
                                                             profigPersistence:dao
                                                        isOmidFrameworkPresent:YES];
    XCTAssertEqual(payload[@"device"][@"settings"][@"low_power_mode"], @NO);
}

- (void)testIsiOSAppRunningOnMacNO {
    OGAAdConfiguration *configuration = [self fullyMockedConfiguration];
    OGAProfigDao *dao = OCMPartialMock([[OGAProfigDao alloc] init]);
    NSDictionary *payload = [configuration payloadForAdSyncWithAssetKeyManager:self.assetKeyManager
                                                                  reachability:self.reachability
                                                             profigPersistence:dao
                                                        isOmidFrameworkPresent:YES];
    XCTAssertEqual(payload[@"device"][@"ios_app_on_mac"], @NO);
}

- (void)testIsiOSAppRunningOnMacYES {
    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    NSLocale *locale = OCMClassMock([NSLocale class]);
    OCMStub(locale.countryCode).andReturn(@"FR");
    OCMStub(locale.languageCode).andReturn(@"en-gb");
    OGAAdConfiguration *configuration = OCMPartialMock([[OGAAdConfiguration alloc] initWithType:OguryAdsTypeThumbnailAd
                                                                                       adUnitId:DefaultAdUnitID
                                                                             delegateDispatcher:delegateDispatcher
                                                                         viewControllerProvider:nil
                                                                                   viewProvider:nil
                                                                                         locale:locale]);
    configuration.userId = DefaultUserID;
    id configurationUtilsMock = OCMClassMock([OGAConfigurationUtils class]);
    if (@available(iOS 14.0, *)) {
        OCMStub(OCMClassMethod([configurationUtilsMock isiOSAppOnMac])).andReturn(YES);
    }
    OGAProfigDao *dao = OCMPartialMock([[OGAProfigDao alloc] init]);
    NSDictionary *payload = [configuration payloadForAdSyncWithAssetKeyManager:self.assetKeyManager
                                                                  reachability:self.reachability
                                                             profigPersistence:dao
                                                        isOmidFrameworkPresent:YES];
    XCTAssertEqual(payload[@"device"][@"ios_app_on_mac"], @YES);
}

- (OGAAdConfiguration *)fullyMockedConfiguration {
    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    NSLocale *locale = OCMClassMock([NSLocale class]);
    OCMStub(locale.countryCode).andReturn(@"FR");
    OCMStub(locale.languageCode).andReturn(@"en-gb");
    OGAAdConfiguration *configuration = OCMPartialMock([[OGAAdConfiguration alloc] initWithType:OguryAdsTypeThumbnailAd
                                                                                       adUnitId:DefaultAdUnitID
                                                                             delegateDispatcher:delegateDispatcher
                                                                         viewControllerProvider:nil
                                                                                   viewProvider:nil
                                                                                         locale:locale]);
    configuration.userId = DefaultUserID;
    id configurationUtilsMock = OCMClassMock([OGAConfigurationUtils class]);
    OCMStub(OCMClassMethod([configurationUtilsMock getDeviceOS])).andReturn(@"deviceOS");
    OCMStub(OCMClassMethod([configurationUtilsMock getManufacturer])).andReturn(@"deviceManufacturer");
    OCMStub(OCMClassMethod([configurationUtilsMock getDeviceOSVersion])).andReturn(@"deviceOSVersion");
    OCMStub(OCMClassMethod([configurationUtilsMock getAppBundleIdentifer])).andReturn(@"bundle");
    OCMStub(OCMClassMethod([configurationUtilsMock getAppBuildVersion])).andReturn(@"3");
    OCMStub(OCMClassMethod([configurationUtilsMock getAppMarketingVersion])).andReturn(@"1.2");
    OCMStub(OCMClassMethod([configurationUtilsMock screenScale])).andReturn(3);
    if (@available(iOS 14.0, *)) {
        OCMStub(OCMClassMethod([configurationUtilsMock isiOSAppOnMac])).andReturn(NO);
    }
    id adIdentifierService = OCMClassMock([OGAAdIdentifierService class]);
    OCMStub(OCMClassMethod([adIdentifierService getInstanceToken])).andReturn(@"XXXXX-XXXX-XXXXX-XX-XXX-XXXXX");
    OCMStub(OCMClassMethod([adIdentifierService getAdIdentifier])).andReturn(@"XXXX-XXXXX-XX-XXX-XXXXX");
    OCMStub(OCMClassMethod([adIdentifierService getVendorIdentifier])).andReturn(@"XXXXX-XX-XXX-XXXXX");
    OCMStub(OCMClassMethod([adIdentifierService getConsentToken])).andReturn(@"XXXXX-XX-XXXXXX-XXXXX");
    OCMStub(OCMClassMethod([adIdentifierService isAdOptin])).andReturn(YES);
    OCMStub([configuration sdkVersion]).andReturn(@"1.2.3.4.5");
    id deviceMock = OCMClassMock([OGADevice class]);
    OCMStub([configuration currentDevice]).andReturn(deviceMock);
    OCMStub([configuration requestId]).andReturn(@"requestId");
    OCMStub([configuration campaignId]).andReturn(@"campaignId");
    OCMStub([configuration creativeId]).andReturn(@"creativeId");
    OGAAdDsp *adDsp = [[OGAAdDsp alloc] initWithCreativeId:DefaultDspCreativeID region:DefaultDspRegion];
    OCMStub([configuration adDsp]).andReturn(adDsp);
    OCMStub([deviceMock name]).andReturn(@"deviceName");
    OCMStub([configuration screenSize]).andReturn(CGSizeMake(200, 300));
    OCMStub([configuration orientation]).andReturn(@"portrait");
    OCMStub([configuration secondsFromGMT]).andReturn(3600);
    OCMStub([self.reachability currentReachabilityNetwork]).andReturn(@"WIFI");
    OCMStub([configuration getAdTypeString]).andReturn(@"overlay_thumbnail");
    OCMStub([configuration lowBatteryMode]).andReturn(YES);
    OCMStub([configuration adUnitId]).andReturn(@"870897978070");
    id skAdNetworkService = OCMClassMock([OGASKAdNetworkService class]);
    OCMStub(OCMClassMethod([skAdNetworkService getSKAdNetworkVersion])).andReturn(@"4.0");
    OCMStub(OCMClassMethod([skAdNetworkService getInfoAdNetworkItems])).andReturn(@[ @"98768769" ]);
    return configuration;
}

- (OGAProfigDao *)mockedDaoWithFullPermissions {
    NSUInteger permission = 0;
    for (int index = 0; index < 16; index++) {
        permission += pow(2, index);
    }
    return [self mockedDaoWithPermission:permission];
}

- (OGAProfigDao *)mockedDaoWithPermission:(NSUInteger)permission {
    OGAProfigDao *dao = OCMClassMock([OGAProfigDao class]);
    OGAProfigFullResponse *profig = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub([dao profigFullResponse]).andReturn(profig);
    OCMStub([profig adsyncPermissions]).andReturn(@(permission));
    OCMStub([profig isOmidEnabled]).andReturn(YES);
    OGAAdPrivacyConfiguration *privacyConfiguration = OCMPartialMock([[OGAAdPrivacyConfiguration alloc] initWithAdSyncPermissionMask:permission monitoringMask:0]);
    OCMStub([profig getPrivacyConfiguration]).andReturn(privacyConfiguration);
    return dao;
}

- (void)testWhenAllFieldsAreProvidedThenEnvelopeIsValid {
    OGAProfigDao *dao = [self mockedDaoWithFullPermissions];
    OGAAdConfiguration *configuration = [self fullyMockedConfiguration];
    id dateClassMock = OCMClassMock([NSDate class]);
    OCMStub(OCMClassMethod([dateClassMock timestampInMilliseconds])).andReturn(@1684153251387);
    OGAWebViewUserAgentService *userAgentService = OCMClassMock([OGAWebViewUserAgentService class]);
    [OCMStub(userAgentService.webViewUserAgent) andReturn:@"USER_AGENT"];
    OCMStub([userAgentService webViewUserAgent]).andReturn(@"Mozilla/5.0");

    NSDictionary *payload = [configuration payloadForAdSyncWithAssetKeyManager:self.assetKeyManager
                                                                  reachability:self.reachability
                                                             profigPersistence:dao
                                                        isOmidFrameworkPresent:YES
                                                              userAgentService:userAgentService];
    // at
    XCTAssertEqualObjects(payload[@"sent_at"], @1684153251387);
    XCTAssertEqualObjects(payload[@"request_id"], @"requestid");
    // app
    XCTAssertEqualObjects(payload[@"app"][@"asset_key"], @"OGY-XXXXXXXX");
    XCTAssertEqualObjects(payload[@"app"][@"asset_type"], @"deviceOS");
    XCTAssertEqualObjects(payload[@"app"][@"bundle_id"], @"bundle");
    XCTAssertEqualObjects(payload[@"app"][@"version"], @"1.2.3");
    XCTAssertEqualObjects(payload[@"app"][@"instance_token"], @"XXXXX-XXXX-XXXXX-XX-XXX-XXXXX");
    // sdk
    XCTAssertEqualObjects(payload[@"sdk"][@"module_version"], @"1.2.3.4.5");
    XCTAssertEqualObjects(payload[@"sdk"][@"module_version"], @"1.2.3.4.5");
    // device
    XCTAssertEqualObjects(payload[@"device"][@"os"], @"deviceOS");
    XCTAssertEqualObjects(payload[@"device"][@"os_version"], @"deviceOSVersion");
    XCTAssertEqualObjects(payload[@"device"][@"manufacturer"], @"deviceManufacturer");
    XCTAssertEqualObjects(payload[@"device"][@"model"], @"deviceName");
    XCTAssertEqualObjects(payload[@"device"][@"screen"][@"width"], @200);
    XCTAssertEqualObjects(payload[@"device"][@"screen"][@"height"], @300);
    XCTAssertEqualObjects(payload[@"device"][@"screen"][@"orientation"], @"portrait");
    // settings
    XCTAssertEqualObjects(payload[@"device"][@"settings"][@"time_zone"], @"+01:00");
    XCTAssertEqualObjects(payload[@"device"][@"settings"][@"is_ad_tracking_enabled"], @1);
    XCTAssertEqualObjects(payload[@"device"][@"settings"][@"device_id"], @"XXXX-XXXXX-XX-XXX-XXXXX");
    XCTAssertEqualObjects(payload[@"device"][@"settings"][@"locale"][@"country"], @"FR");
    XCTAssertEqualObjects(payload[@"device"][@"settings"][@"locale"][@"language"], @"en-gb");
    XCTAssertEqualObjects(payload[@"device"][@"settings"][@"vendor_id"], @"XXXXX-XX-XXX-XXXXX");
    // webview
    XCTAssertEqualObjects(payload[@"device"][@"settings"][@"low_power_mode"], @1);
    // network
    XCTAssertEqualObjects(payload[@"device"][@"network"][@"connectivity"], @"WIFI");
    XCTAssertEqualObjects(payload[@"device"][@"network"][@"mobile_country"], @"FR");
    // webview user agent
    XCTAssertEqualObjects(payload[@"device"][@"webview"][@"user_agent"], @"USER_AGENT");
    // privacy_compliancy
    XCTAssertEqualObjects(payload[@"privacy_compliancy"][@"consent_token"], @"XXXXX-XX-XXXXXX-XXXXX");
    // ad_sync
    XCTAssertEqualObjects(payload[@"ad_sync"][@"name"], @"overlay_thumbnail");
    XCTAssertEqualObjects(payload[@"ad_sync"][@"type"], @"load");
    XCTAssertEqualObjects(payload[@"ad_sync"][@"ad"][@"ad_unit_id"], @"870897978070");
    XCTAssertEqualObjects(payload[@"ad_sync"][@"ad"][@"campaign_id"], @"campaignId");
    XCTAssertEqualObjects(payload[@"ad_sync"][@"ad"][@"creative_id"], @"creativeId");
    XCTAssertEqualObjects(payload[@"ad_sync"][@"ad"][@"dsp"][@"creative_id"], @"dspCreative");
    XCTAssertEqualObjects(payload[@"ad_sync"][@"ad"][@"dsp"][@"region"], @"dspRegion");
    XCTAssertEqualObjects(payload[@"ad_sync"][@"omid"][@"is_compliant"], @1);
    XCTAssertEqualObjects(payload[@"ad_sync"][@"omid"][@"integration_version"], @3);
    XCTAssertEqualObjects(payload[@"ad_sync"][@"skadnetwork"][@"version"], @"4.0");
    XCTAssertEqualObjects(payload[@"ad_sync"][@"skadnetwork"][@"identifier_list"], @[ @"98768769" ]);
    XCTAssertEqualObjects(payload[@"ad_sync"][@"overlay"][@"overlay_max_size"][@"height"], @180);
    XCTAssertEqualObjects(payload[@"ad_sync"][@"overlay"][@"overlay_max_size"][@"width"], @180);
    XCTAssertEqualObjects(payload[@"ad_sync"][@"overlay"][@"overlay_max_size"][@"scaler"], @3);
    [dateClassMock stopMocking];
}

- (NSDictionary *)adSyncPayloadWithPermissions:(NSUInteger)permissions {
    OGAProfigDao *dao = [self mockedDaoWithPermission:permissions];
    OGAAdConfiguration *configuration = [self fullyMockedConfiguration];
    OGAWebViewUserAgentService *userAgentService = OCMClassMock([OGAWebViewUserAgentService class]);
    OCMStub([userAgentService webViewUserAgent]).andReturn(@"Mozilla/5.0");

    return [configuration payloadForAdSyncWithAssetKeyManager:self.assetKeyManager
                                                 reachability:self.reachability
                                            profigPersistence:dao
                                       isOmidFrameworkPresent:YES
                                             userAgentService:userAgentService];
}

- (void)checkAdSyncPayloadWithPermissionMask:(NSUInteger)permission assertMessage:(NSString *)message {
    NSDictionary *payload = [self adSyncPayloadWithPermissions:permission];
    if (permission & 1) {
        XCTAssertNotNil(payload[@"device"][@"settings"][@"device_id"], @"%@", message);
    } else {
        XCTAssertNil(payload[@"device"][@"settings"][@"device_id"], @"%@", message);
    }
    if (permission & 2) {
        XCTAssertNotNil(payload[@"device"][@"settings"][@"is_ad_tracking_enabled"]);
    } else {
        XCTAssertNil(payload[@"device"][@"settings"][@"is_ad_tracking_enabled"]);
    }
    if (permission & 4) {
        XCTAssertNotNil(payload[@"app"][@"instance_token"], @"%@", message);
    } else {
        XCTAssertNil(payload[@"app"][@"instance_token"], @"%@", message);
    }
    if (permission & 8) {
        XCTAssertNotNil(payload[@"device"][@"model"], @"%@", message);
        XCTAssertNotNil(payload[@"device"][@"manufacturer"], @"%@", message);
    } else {
        XCTAssertNil(payload[@"device"][@"model"], @"%@", message);
        XCTAssertNil(payload[@"device"][@"manufacturer"], @"%@", message);
    }
    if (permission & 16) {
        XCTAssertNotNil(payload[@"device"][@"screen"][@"width"], @"%@", message);
        XCTAssertNotNil(payload[@"device"][@"screen"][@"height"], @"%@", message);
    } else {
        XCTAssertNil(payload[@"device"][@"screen"][@"width"], @"%@", message);
        XCTAssertNil(payload[@"device"][@"screen"][@"height"], @"%@", message);
    }
    if (permission & 32) {
        XCTAssertNotNil(payload[@"device"][@"screen"][@"orientation"], @"%@", message);
    } else {
        XCTAssertNil(payload[@"device"][@"screen"][@"orientation"], @"%@", message);
    }
    if (permission & 64) {
        // N/A, Android stuff
    } else {
        // N/A, Android stuff
    }
    if (permission & 128) {
        // N/A, Android stuff
    } else {
        // N/A, Android stuff
    }
    if (permission & 256) {
        XCTAssertNotNil(payload[@"device"][@"settings"][@"time_zone"], @"%@", message);
    } else {
        XCTAssertNil(payload[@"device"][@"settings"][@"time_zone"], @"%@", message);
    }
    if (permission & 512) {
        XCTAssertNotNil(payload[@"device"][@"settings"][@"locale"][@"language"], @"%@", message);
    } else {
        XCTAssertNil(payload[@"device"][@"settings"][@"locale"][@"language"], @"%@", message);
    }
    if (permission & 1024) {
        XCTAssertNotNil(payload[@"device"][@"settings"][@"locale"][@"country"], @"%@", message);
    } else {
        XCTAssertNil(payload[@"device"][@"settings"][@"locale"][@"country"], @"%@", message);
    }
    if (permission & 2048) {
        XCTAssertNotNil(payload[@"device"][@"network"][@"mobile_country"], @"%@", message);
    } else {
        XCTAssertNil(payload[@"device"][@"network"][@"mobile_country"], @"%@", message);
    }
    if (permission & 4096) {
        XCTAssertNotNil(payload[@"device"][@"network"][@"connectivity"], @"%@", message);
    } else {
        XCTAssertNil(payload[@"device"][@"network"][@"connectivity"], @"%@", message);
    }
    if (permission & 8192) {
        XCTAssertNotNil(payload[@"device"][@"webview"][@"user_agent"], @"%@", message);
    } else {
        XCTAssertNil(payload[@"device"][@"webview"][@"user_agent"], @"%@", message);
    }
    if (permission & 16384) {
        XCTAssertNotNil(payload[@"device"][@"settings"][@"vendor_id"], @"%@", message);
    } else {
        XCTAssertNil(payload[@"device"][@"settings"][@"vendor_id"], @"%@", message);
    }
    if (permission & 32768) {
        XCTAssertNotNil(payload[@"device"][@"settings"][@"low_power_mode"], @"%@", message);
    } else {
        XCTAssertNil(payload[@"device"][@"settings"][@"low_power_mode"], @"%@", message);
    }
}

- (NSString *)assertMessageForPermission:(NSUInteger)permission {
    if (permission == 1) {
        return @"Checking DeviceId permission";
    } else if (permission == 2) {
        return @"";
    } else if (permission == 4) {
        return @"Checking instance_token permission";
    } else if (permission == 8) {
        return @"Checking Device permission";
    } else if (permission == 16) {
        return @"Checking Screen permission";
    } else if (permission == 32) {
        return @"Checking Orientation permission";
    } else if (permission == 64) {
        return @"Checking LayoutSize permission";
    } else if (permission == 128) {
        return @"Checking UIMode permission";
    } else if (permission == 256) {
        return @"Checking Timezone permission";
    } else if (permission == 512) {
        return @"Checking Locale language permission";
    } else if (permission == 1024) {
        return @"Checking Locale country permission";
    } else if (permission == 2048) {
        return @"Checking mobile_country permission";
    } else if (permission == 4096) {
        return @"Checking connectivity permission";
    } else if (permission == 8192) {
        return @"Checking user_agent permission";
    } else if (permission == 16384) {
        return @"Checking vendor_id permission";
    } else if (permission == 32768) {
        return @"Checking low_power_mode permission";
    }
    return @"";
}

- (void)testWhenSingleRawPermissionIsUsedThenOnlyProperFieldIsSetInPayload {
    for (int index = 0; index < 15; index++) {
        NSUInteger permission = pow(2, index);
        [self checkAdSyncPayloadWithPermissionMask:permission assertMessage:[self assertMessageForPermission:permission]];
    }
}

- (void)testWhenSinglePermissionIsUsedThenOnlyProperFieldIsSetInPayload {
    NSArray *permissions = @[
        @(OGAAdPrivacyPermissionNone),
        @(OGAAdPrivacyPermissionIDFA),
        @(OGAAdPrivacyPermissionAdTracking),
        @(OGAAdPrivacyPermissionInstanceToken),
        @(OGAAdPrivacyPermissionDeviceIds),
        @(OGAAdPrivacyPermissionDeviceDimensions),
        @(OGAAdPrivacyPermissionDeviceOrientation),
        @(OGAAdPrivacyPermissionLayoutSize),
        @(OGAAdPrivacyPermissionUIMode),
        @(OGAAdPrivacyPermissionTimezone),
        @(OGAAdPrivacyPermissionLocaleLanguage),
        @(OGAAdPrivacyPermissionLocaleCountry),
        @(OGAAdPrivacyPermissionMobileCountry),
        @(OGAAdPrivacyPermissionConnectivity),
        @(OGAAdPrivacyPermissionWebviewUserAgent),
        @(OGAAdPrivacyPermissionIDFV),
        @(OGAAdPrivacyPermissionLowPowerMode)
    ];
    for (int index = 0; index < 16; index++) {
        NSUInteger permission = [permissions[index] intValue];
        [self checkAdSyncPayloadWithPermissionMask:permission assertMessage:[self assertMessageForPermission:permission]];
    }
}

- (void)testWhenComputedPermissionMaskIsUsedThenAllProperFieldsAreSetInPayload {
    [self checkAdSyncPayloadWithPermissionMask:4631 assertMessage:@"Testing permissions for deviceId, ad tracking, instance Token, locale language and connectivity"];
    [self checkAdSyncPayloadWithPermissionMask:16383 assertMessage:@"Testing all permissions but vendor Id"];
}

- (void)testWhenRequestsAreGeneratedThenRequestIdChanges {
    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    NSLocale *locale = OCMClassMock([NSLocale class]);
    OCMStub(locale.countryCode).andReturn(@"FR");
    OCMStub(locale.languageCode).andReturn(@"en-gb");
    OGAAdConfiguration *configuration = OCMPartialMock([[OGAAdConfiguration alloc] initWithType:OguryAdsTypeThumbnailAd
                                                                                       adUnitId:DefaultAdUnitID
                                                                             delegateDispatcher:delegateDispatcher
                                                                         viewControllerProvider:nil
                                                                                   viewProvider:nil
                                                                                         locale:locale]);
    OGAProfigDao *dao = [self mockedDaoWithPermission:65535];
    OGAWebViewUserAgentService *userAgentService = OCMClassMock([OGAWebViewUserAgentService class]);
    OCMStub([userAgentService webViewUserAgent]).andReturn(@"Mozilla/5.0");

    NSDictionary *payload = [configuration payloadForAdSyncWithAssetKeyManager:self.assetKeyManager
                                                                  reachability:self.reachability
                                                             profigPersistence:dao
                                                        isOmidFrameworkPresent:YES
                                                              userAgentService:userAgentService];
    NSDictionary *payload2 = [configuration payloadForAdSyncWithAssetKeyManager:self.assetKeyManager
                                                                   reachability:self.reachability
                                                              profigPersistence:dao
                                                         isOmidFrameworkPresent:YES
                                                               userAgentService:userAgentService];
    NSString *requestId = payload[@"request_id"];
    NSString *requestId2 = payload2[@"request_id"];
    XCTAssertFalse([requestId isEqualToString:requestId2]);
}

@end
