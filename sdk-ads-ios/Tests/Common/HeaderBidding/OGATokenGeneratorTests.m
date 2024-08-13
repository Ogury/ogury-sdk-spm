//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGATokenGenerator+Testing.h"
#import "OGAInternal.h"
#import "OGAAssetKeyManager.h"
#import "OGAAdIdentifierService.h"
#import "OGAConfigurationUtils.h"
#import "UIApplication+Orientation.h"
#import "OGADeviceService.h"
#import <OCMock/OCMock.h>
#import "OGATokenConstants.h"
#import "NSDictionary+OGABase64.h"
#import "OGAAdConfiguration.h"
#import "OGAConstants.h"
#import "OGAProfigManager.h"
#import "OGASKAdNetworkService.h"
#import "OGAConstants.h"
#import "OGAProfigManager.h"
#import "OGAAdPrivacyConfiguration.h"

@interface OGATokenGeneratorTests : XCTestCase

@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, strong) OGAInternal *internal;
@property(nonatomic, strong) OGADeviceService *deviceService;
@property(nonatomic, strong) OGATokenGenerator *tokenGenerator;
@property(nonatomic, strong) OGAAdPrivacyConfiguration *privacyConfiguration;
@property(nonatomic, strong) OGAProfigManager *profigManager;
@property(nonatomic, strong) id skAdNetworkService;
@property(nonatomic, strong) OGAOMIDService *omidService;
@property(nonatomic, strong) OGAProfigDao *profigDao;
@property(nonatomic, strong) OGAProfigFullResponse *profigResponse;

@end

@interface OGATokenGenerator ()
- (BOOL)canSendToken;
- (NSString *)gppConsentString;
- (NSString *)gppSidConsentString;
- (NSString *)tcfConsentString;
- (NSDictionary<NSString*, NSString*>*)privacyDatas;
@end

@interface OGAAdPrivacyConfiguration ()
@property NSUInteger adSyncPermissions;
@end

@implementation OGATokenGeneratorTests

- (void)setUp {
    self.assetKeyManager = OCMPartialMock([OGAAssetKeyManager new]);
    self.internal = OCMPartialMock([OGAInternal new]);
    self.deviceService = OCMPartialMock([OGADeviceService new]);
    self.skAdNetworkService = OCMPartialMock([OGASKAdNetworkService new]);
    self.profigManager = OCMPartialMock([OGAProfigManager new]);
    self.privacyConfiguration = OCMPartialMock([OGAAdPrivacyConfiguration new]);
    self.omidService = OCMClassMock([OGAOMIDService class]);
    self.profigDao = OCMPartialMock([OGAProfigDao new]);
    self.profigResponse = OCMPartialMock([OGAProfigFullResponse new]);
    self.tokenGenerator = OCMPartialMock([[OGATokenGenerator alloc] init:self.assetKeyManager
                                                                internal:self.internal
                                                           deviceService:self.deviceService
                                                           profigManager:self.profigManager
                                                               profigDao:self.profigDao
                                                             omidService:self.omidService]);
    OCMStub([self.profigManager currentPrivacyConfiguration]).andReturn(self.privacyConfiguration);
    OCMStub([self.profigDao profigFullResponse]).andReturn(self.profigResponse);
}

- (void)testInitAassetkeyInternalDeviceService {
    OGATokenGenerator *tokenGenerator = [[OGATokenGenerator alloc] init:self.assetKeyManager
                                                               internal:self.internal
                                                          deviceService:self.deviceService
                                                          profigManager:self.profigManager
                                                              profigDao:self.profigDao
                                                            omidService:self.omidService];
    XCTAssertNotNil(tokenGenerator);
    XCTAssertEqual(tokenGenerator.internal, self.internal);
    XCTAssertEqual(tokenGenerator.assetKeyManager, self.assetKeyManager);
    XCTAssertEqual(tokenGenerator.deviceService, self.deviceService);
}

- (void)testInit {
    OGATokenGenerator *tokenGenerator = [[OGATokenGenerator alloc] init];
    XCTAssertNotNil(tokenGenerator);
}

- (void)testGenerateBidderTokenCampaignIdCreativeIdDspCreativeIdDspRegion {
    OCMStub([self.assetKeyManager checkAssetKeyIsValid:[OCMArg anyObjectRef]]).andReturn(YES);
    [self mockDataWithPermissions:65535 skanEnabled:YES assetKeyEnabled:YES instanceTokenEnabled:YES lowBatteryMode:YES];
    NSString *encodedBidderToken = [self.tokenGenerator generateBidderToken:@"campaign" creativeId:@"creativeId" dspCreativeId:@"dspCreativeId" dspRegion:@"dspRegion"];
    XCTAssertNotNil(encodedBidderToken);
    NSError *error = nil;
    NSDictionary *token = [NSDictionary ogaDecodeFromBase64:encodedBidderToken error:&error];
    XCTAssertNotNil(token);
    XCTAssertNotNil(token[@"ad_sync"][@"ad"][@"campaign_id"]);
    XCTAssertNotNil(token[@"ad_sync"][@"ad"][@"creative_id"]);
    XCTAssertEqualObjects(token[@"ad_sync"][@"ad"][@"campaign_id"], @"campaign");
    XCTAssertEqualObjects(token[@"ad_sync"][@"ad"][@"creative_id"], @"creativeId");
    XCTAssertEqualObjects(token[@"ad_sync"][@"ad"][@"dsp"][@"creative_id"], @"dspCreativeId");
    XCTAssertEqualObjects(token[@"ad_sync"][@"ad"][@"dsp"][@"region"], @"dspRegion");
}

- (void)testGenerateBidderTokenWithCampaignId {
    OCMStub([self.assetKeyManager checkAssetKeyIsValid:[OCMArg anyObjectRef]]).andReturn(YES);
    [self mockDataWithPermissions:65535 skanEnabled:YES assetKeyEnabled:YES instanceTokenEnabled:YES lowBatteryMode:YES];
    NSString *encodedBidderToken = [self.tokenGenerator generateBidderToken:@"campaign"];
    XCTAssertNotNil(encodedBidderToken);
    NSError *error = nil;
    NSDictionary *token = [NSDictionary ogaDecodeFromBase64:encodedBidderToken error:&error];
    XCTAssertNotNil(token);
    XCTAssertNotNil(token[@"ad_sync"][@"ad"][@"campaign_id"]);
    XCTAssertNil(token[@"ad_sync"][@"ad"][@"creative_id"]);
    XCTAssertEqualObjects(token[@"ad_sync"][@"ad"][@"campaign_id"], @"campaign");
    XCTAssertNil(token[@"ad_sync"][@"ad"][@"dsp"]);
}

- (void)testWhenLowBatteryModeIsOnThenTrueIsSet {
    OCMStub([self.assetKeyManager checkAssetKeyIsValid:[OCMArg anyObjectRef]]).andReturn(YES);
    [self mockDataWithPermissions:65535 skanEnabled:YES assetKeyEnabled:YES instanceTokenEnabled:YES lowBatteryMode:YES];
    NSDictionary *token = [self.tokenGenerator collectBidderTokenData];
    XCTAssertEqual([token[@"device"][@"settings"][@"low_power_mode"] intValue], 1);
}

- (void)testWhenLowBatteryModeIsOffThenFalseIsSet {
    [self mockDataWithPermissions:65535 skanEnabled:YES assetKeyEnabled:YES instanceTokenEnabled:YES lowBatteryMode:NO];
    NSDictionary *token = [self.tokenGenerator collectBidderTokenData];
    XCTAssertEqual([token[@"device"][@"settings"][@"low_power_mode"] intValue], 0);
}

- (void)testCollectBidderTokenDataNoAssetKey {
    [self mockDataWithPermissions:65535 skanEnabled:YES assetKeyEnabled:NO instanceTokenEnabled:YES lowBatteryMode:YES];
    NSDictionary *token = [self.tokenGenerator collectBidderTokenData];
    XCTAssertNil(token[@"app"][@"asset_key"]);
}

- (void)testCollectBidderTokenDataNoInstanceToken {
    [self mockDataWithPermissions:65535 skanEnabled:YES assetKeyEnabled:YES instanceTokenEnabled:NO lowBatteryMode:YES];
    NSDictionary *token = [self.tokenGenerator collectBidderTokenData];
    XCTAssertNil(token[@"app"][@"instance_token"]);
}

- (void)testCollectBidderTokenDataNoInstanceTokenNoAssetKey {
    [self mockDataWithPermissions:65535 skanEnabled:YES assetKeyEnabled:NO instanceTokenEnabled:NO lowBatteryMode:YES];
    NSDictionary *token = [self.tokenGenerator collectBidderTokenData];
    XCTAssertNil(token[@"app"][@"asset_key"]);
    XCTAssertNil(token[@"app"][@"instance_token"]);
}

- (void)testWhenAdTrackingIsDisabledThenNoBidderTokenIsGenerated {
    OCMStub([self.profigResponse adsEnabled]).andReturn(NO);
    NSDictionary *bidderToken = [self.tokenGenerator collectBidderTokenData];
    XCTAssertNil(bidderToken);
    NSString *bidderTokenString = [self.tokenGenerator generateBidderToken];
    XCTAssertNil(bidderTokenString);
    bidderTokenString = [self.tokenGenerator generateBidderToken:@"campaign" creativeId:@"creativeId" dspCreativeId:@"dspCreativeId" dspRegion:@"dspRegion"];
    XCTAssertNil(bidderTokenString);
    bidderTokenString = [self.tokenGenerator generateBidderToken:@"campaign"];
    XCTAssertNil(bidderTokenString);
}

- (void)testWhenAdAssetNotInitAndAdsDisabled {
    OCMStub([self.assetKeyManager checkAssetKeyIsValid:[OCMArg anyObjectRef]]).andReturn(NO);
    OCMStub([self.profigResponse adsEnabled]).andReturn(NO);
    XCTAssertFalse([self.tokenGenerator canSendToken]);
}

- (void)testWhenAdAssetInitAndAdsDisabled {
    OCMStub([self.assetKeyManager checkAssetKeyIsValid:[OCMArg anyObjectRef]]).andReturn(YES);
    OCMStub([self.profigResponse adsEnabled]).andReturn(NO);
    XCTAssertFalse([self.tokenGenerator canSendToken]);
}

- (void)testWhenAdAssetInitAndAdsEnabled {
    OCMStub([self.assetKeyManager checkAssetKeyIsValid:[OCMArg anyObjectRef]]).andReturn(YES);
    OCMStub([self.profigResponse adsEnabled]).andReturn(YES);
    XCTAssertTrue([self.tokenGenerator canSendToken]);
}

- (NSUInteger)fullPermissions {
    NSUInteger permission = 0;
    for (int index = 0; index < 16; index++) {
        permission += pow(2, index);
    }
    return permission;
}

- (void)mockDataWithPermissions:(NSUInteger)permissions
                    skanEnabled:(BOOL)skanEnabled
                assetKeyEnabled:(BOOL)assetKeyEnabled
           instanceTokenEnabled:(BOOL)instanceTokenEnabled
                 lowBatteryMode:(BOOL)lowBatteryMode {
    self.privacyConfiguration.adSyncPermissions = permissions;
    id classMock = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(ClassMethod([classMock isOnLowPowerMode])).andReturn(lowBatteryMode);
    id configurationUtilsMock = OCMClassMock([OGAConfigurationUtils class]);
    OCMStub(OCMClassMethod([configurationUtilsMock timeZone])).andReturn(@"+00:00");
    OCMStub(OCMClassMethod([configurationUtilsMock getAppMarketingVersion])).andReturn(@"2.2.2");
    OCMStub(OCMClassMethod([configurationUtilsMock getDeviceOS])).andReturn(@"deviceOS");
    OCMStub(OCMClassMethod([configurationUtilsMock getAppBundleIdentifer])).andReturn(@"bundle_id");
    OCMStub(OCMClassMethod([configurationUtilsMock getVendorId])).andReturn(@"vendorId");
    id adIdentifierServiceMock = OCMClassMock([OGAAdIdentifierService class]);
    OCMStub(OCMClassMethod([adIdentifierServiceMock getInstanceToken])).andReturn(instanceTokenEnabled ? @"instanceToken" : nil);
    OCMStub(OCMClassMethod([adIdentifierServiceMock getAdIdentifier])).andReturn(@"deviceId");
    OCMStub(self.assetKeyManager.assetKey).andReturn(assetKeyEnabled ? @"AssetKey" : nil);
    OCMStub([self.internal getVersion]).andReturn(@"5.5.5");
    OCMStub([self.internal getBuildVersion]).andReturn(@"1234");
    OCMStub([self.deviceService interfaceOrientation]).andReturn(@"portrait");
    OCMStub([self.omidService isOMIDFrameworkPresent]).andReturn(NO);
    [[[[self.skAdNetworkService stub] classMethod] andReturnValue:OCMOCK_VALUE(skanEnabled)] sdkIsCompatibleWithSKAdNetwork];
    [[[[self.skAdNetworkService stub] classMethod] andReturn:@"skanVersion"] getSKAdNetworkVersion];
    NSArray *items = @[ @"1", @"2" ];
    [[[[self.skAdNetworkService stub] classMethod] andReturn:items] getInfoAdNetworkItems];
    OCMStub([self.profigResponse adsEnabled]).andReturn(YES);
}

- (NSDictionary *)fullyMockedTokenWithPermissions:(NSUInteger)permissions skanEnabled:(BOOL)skanEnabled {
    [self mockDataWithPermissions:permissions skanEnabled:skanEnabled assetKeyEnabled:YES instanceTokenEnabled:YES lowBatteryMode:YES];
    return [self.tokenGenerator collectBidderTokenData];
}

- (void)testWhenAllPermissionsAreSetThenTokenEnvelopeIsValid {
    OCMStub([self.assetKeyManager checkAssetKeyIsValid:[OCMArg anyObjectRef]]).andReturn(YES);
    NSDictionary *token = [self fullyMockedTokenWithPermissions:[self fullPermissions] skanEnabled:YES];
    // App
    XCTAssertEqualObjects(token[@"app"][@"asset_key"], @"AssetKey");
    XCTAssertEqualObjects(token[@"app"][@"asset_type"], @"deviceOS");
    XCTAssertEqualObjects(token[@"app"][@"bundle_id"], @"bundle_id");
    XCTAssertEqualObjects(token[@"app"][@"instance_token"], @"instanceToken");
    XCTAssertEqualObjects(token[@"app"][@"version"], @"2.2.2");
    // device
    XCTAssertEqualObjects(token[@"device"][@"screen"][@"orientation"], @"portrait");
    XCTAssertEqualObjects(token[@"device"][@"settings"][@"device_id"], @"deviceId");
    XCTAssertEqualObjects(token[@"device"][@"settings"][@"low_power_mode"], @1);
    XCTAssertEqualObjects(token[@"device"][@"settings"][@"time_zone"], @"+00:00");
    XCTAssertEqualObjects(token[@"device"][@"settings"][@"vendor_id"], @"vendorId");
    // sdk
    XCTAssertEqualObjects(token[@"sdk"][@"build_version"], @"1234");
    XCTAssertEqualObjects(token[@"sdk"][@"module_version"], @"5.5.5");
    // skan
    XCTAssertEqualObjects(token[@"ad_sync"][@"skadnetwork"][@"version"], @"skanVersion");
    NSArray *items = @[ @"1", @"2" ];
    XCTAssertEqualObjects(token[@"ad_sync"][@"skadnetwork"][@"identifier_list"], items);
    XCTAssertNil(token[@"ad_sync"][@"ad"][@"campaign_id"]);
    XCTAssertNil(token[@"ad_sync"][@"ad"][@"creative_id"]);
    XCTAssertNil(token[@"ad_sync"][@"ad"][@"dsp"]);
    // omid
    XCTAssertEqualObjects(token[@"ad_sync"][@"omid"][@"is_compliant"], @(NO));
    XCTAssertEqualObjects(token[@"ad_sync"][@"omid"][@"integration_version"], @(3));
}

- (void)testWhenNoPermissionsAreSetThenTokenEnvelopeIsValid {
    OCMStub([self.assetKeyManager checkAssetKeyIsValid:[OCMArg anyObjectRef]]).andReturn(YES);
    NSDictionary *token = [self fullyMockedTokenWithPermissions:OGAAdPrivacyPermissionAdTracking skanEnabled:YES];
    // App
    XCTAssertNotNil(token[@"app"][@"asset_key"]);
    XCTAssertNotNil(token[@"app"][@"asset_type"]);
    XCTAssertNotNil(token[@"app"][@"bundle_id"]);
    XCTAssertNil(token[@"app"][@"instance_token"]);
    XCTAssertNotNil(token[@"app"][@"version"]);
    // device
    XCTAssertNil(token[@"device"][@"screen"][@"orientation"]);
    XCTAssertNil(token[@"device"][@"settings"][@"device_id"]);
    XCTAssertNil(token[@"device"][@"settings"][@"low_power_mode"]);
    XCTAssertNil(token[@"device"][@"settings"][@"time_zone"]);
    XCTAssertNil(token[@"device"][@"settings"][@"vendor_id"]);
    // sdk
    XCTAssertNotNil(token[@"sdk"][@"build_version"]);
    XCTAssertNotNil(token[@"sdk"][@"module_version"]);
    // skan
    XCTAssertNotNil(token[@"ad_sync"][@"skadnetwork"][@"version"]);
    XCTAssertNotNil(token[@"ad_sync"][@"skadnetwork"][@"identifier_list"]);
    XCTAssertNil(token[@"ad_sync"][@"ad"][@"campaign_id"]);
    XCTAssertNil(token[@"ad_sync"][@"ad"][@"creative_id"]);
    XCTAssertNil(token[@"ad_sync"][@"ad"][@"dsp"]);
}

- (void)testWhenSKNetworkIsUnavailabkeThenTokenEnvelopeIsValid {
    NSDictionary *token = [self fullyMockedTokenWithPermissions:OGAAdPrivacyPermissionAdTracking skanEnabled:NO];
    // skan
    XCTAssertNil(token[@"ad_sync"][@"skadnetwork"][@"version"]);
    XCTAssertNil(token[@"ad_sync"][@"skadnetwork"][@"identifier_list"]);
}

- (void)checkTokenWithPermissionMask:(NSUInteger)permission assertMessage:(NSString *)message {
    OCMStub([self.assetKeyManager checkAssetKeyIsValid:[OCMArg anyObjectRef]]).andReturn(YES);
    NSDictionary *token = [self fullyMockedTokenWithPermissions:permission skanEnabled:YES];
    if (permission & 1) {
        XCTAssertNotNil(token[@"device"][@"settings"][@"device_id"], @"%@", message);
    } else {
        XCTAssertNil(token[@"device"][@"settings"][@"device_id"], @"%@", message);
    }
    if (permission & 2) {
        // N/A, AdSync permission
    } else {
        // N/A, AdSync permission
    }
    if (permission & 4) {
        XCTAssertNotNil(token[@"app"][@"instance_token"], @"%@", message);
    } else {
        XCTAssertNil(token[@"app"][@"instance_token"], @"%@", message);
    }
    if (permission & 8) {
        // N/A, AdSync permission
    } else {
        // N/A, AdSync permission
    }
    if (permission & 16) {
        // N/A, AdSync permission
    } else {
        // N/A, AdSync permission
    }
    if (permission & 32) {
        XCTAssertNotNil(token[@"device"][@"screen"][@"orientation"], @"%@", message);
    } else {
        XCTAssertNil(token[@"device"][@"screen"][@"orientation"], @"%@", message);
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
        XCTAssertNotNil(token[@"device"][@"settings"][@"time_zone"], @"%@", message);
    } else {
        XCTAssertNil(token[@"device"][@"settings"][@"time_zone"], @"%@", message);
    }
    if (permission & 512) {
        // N/A, AdSync permission
    } else {
        // N/A, AdSync permission
    }
    if (permission & 1024) {
        // N/A, AdSync permission
    } else {
        // N/A, AdSync permission
    }
    if (permission & 2048) {
        // N/A, AdSync permission
    } else {
        // N/A, AdSync permission
    }
    if (permission & 4096) {
        // N/A, AdSync permission
    } else {
        // N/A, AdSync permission
    }
    if (permission & 8192) {
        // N/A, AdSync permission
    } else {
        // N/A, AdSync permission
    }
    if (permission & 16384) {
        XCTAssertNotNil(token[@"device"][@"settings"][@"vendor_id"], @"%@", message);
    } else {
        XCTAssertNil(token[@"device"][@"settings"][@"vendor_id"], @"%@", message);
    }
    if (permission & 32768) {
        XCTAssertNotNil(token[@"device"][@"settings"][@"low_power_mode"], @"%@", message);
    } else {
        XCTAssertNil(token[@"device"][@"settings"][@"low_power_mode"], @"%@", message);
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
    } else if (permission == 16384) {
        return @"Checking low_power_mode permission";
    }
    return @"";
}

- (void)testWhenIteratingThroughRawPermissionsThenOnlyAwaitedFieldsAreSet {
    for (int index = 0; index < 16; index++) {
        NSUInteger permission = pow(2, index);
        if (permission == OGAAdPrivacyPermissionAdTracking) {
            continue;
        }
        permission += OGAAdPrivacyPermissionAdTracking;
        [self checkTokenWithPermissionMask:permission assertMessage:[self assertMessageForPermission:permission]];
    }
}

- (void)testWhenIteratingThroughPermissionsThenOnlyAwaitedFieldsAreSet {
    NSArray *permissions = @[
        @(OGAAdPrivacyPermissionNone),
        @(OGAAdPrivacyPermissionIDFA),
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
        permission += OGAAdPrivacyPermissionAdTracking;
        [self checkTokenWithPermissionMask:permission assertMessage:[self assertMessageForPermission:permission]];
    }
}

- (void)testWhenRetrievingGPPDataThenAllDataIsSetCorrectly {
    OCMStub([self.tokenGenerator gppConsentString]).andReturn(@"gppConsentString");
    OCMStub([self.tokenGenerator gppSidConsentString]).andReturn(@"gppSidConsentString");
    OCMStub([self.tokenGenerator tcfConsentString]).andReturn(@"tcfConsentString");
    NSDictionary *privacyDatas = @{ @"us_optout" : @(YES), @"customKey" : @"customValue" };
    OCMStub([self.tokenGenerator privacyDatas]).andReturn(privacyDatas);
    OCMStub([self.assetKeyManager checkAssetKeyIsValid:[OCMArg anyObjectRef]]).andReturn(YES);
    [self mockDataWithPermissions:0 skanEnabled:NO assetKeyEnabled:NO instanceTokenEnabled:NO lowBatteryMode:NO];
    NSDictionary *token = [self.tokenGenerator collectBidderTokenData];
    XCTAssertNotNil(token[@"privacy_compliancy"][@"tcf"]);
    XCTAssertNotNil(token[@"privacy_compliancy"][@"gpp"]);
    XCTAssertNotNil(token[@"privacy_compliancy"][@"gpp_sid"]);
    XCTAssertNotNil(token[@"privacy_compliancy"][@"us_optout"]);
    XCTAssertNotNil(token[@"privacy_compliancy"][@"customKey"]);
    XCTAssertEqualObjects(token[@"privacy_compliancy"][@"tcf"], @"tcfConsentString");
    XCTAssertEqualObjects(token[@"privacy_compliancy"][@"gpp"], @"gppConsentString");
    XCTAssertEqualObjects(token[@"privacy_compliancy"][@"gpp_sid"], @"gppSidConsentString");
    XCTAssertTrue(token[@"privacy_compliancy"][@"us_optout"]);
    XCTAssertEqualObjects(token[@"privacy_compliancy"][@"customKey"], @"customValue");
}

@end
