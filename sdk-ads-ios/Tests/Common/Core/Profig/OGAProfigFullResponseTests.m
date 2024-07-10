//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAProfigFullResponse.h"
#import "OGAJSONModel.h"
#import "OGAProfigFullResponse+Parser.h"
#import <OCMock/OCMock.h>

@interface OGAProfigFullResponse ()

+ (OGAJSONKeyMapper *)keyMapper;

- (BOOL)is:(NSString *)firstString equalTo:(NSString *)secondString;

@end

@interface OGAProfigFullResponseTests : XCTestCase

@property(atomic, strong) NSURLResponse *urlResponse;

@end

@implementation OGAProfigFullResponseTests

- (void)setUp {
    self.urlResponse = OCMClassMock([NSURLResponse class]);
}

- (void)testKeyMapper {
    OGAJSONKeyMapper *keymapper = [OGAProfigFullResponse keyMapper];
    XCTAssertNotNil(keymapper);
    XCTAssertTrue([[keymapper convertValue:@"requestTimeout"] isEqualToString:@"response.global.request_timeout"]);
    XCTAssertTrue([[keymapper convertValue:@"childrenRequestPermissionsFilter"] isEqualToString:@"response.global.children_request_permissions_filter"]);
    XCTAssertTrue([[keymapper convertValue:@"maxProfigApiCallsPerDay"] isEqualToString:@"response.config_pull.limit_per_day"]);
    XCTAssertTrue([[keymapper convertValue:@"adsEnabled"] isEqualToString:@"response.ad_serving.enabled"]);
    XCTAssertTrue([[keymapper convertValue:@"monitoringPermissions"] isEqualToString:@"response.monitoring.request_permissions"]);
    XCTAssertTrue([[keymapper convertValue:@"adsyncPermissions"] isEqualToString:@"response.ad_serving.request_permissions"]);
    XCTAssertTrue([[keymapper convertValue:@"adExpirationTime"] isEqualToString:@"response.ad_serving.ad_expiration_time"]);
    XCTAssertTrue([[keymapper convertValue:@"backButtonEnabled"] isEqualToString:@"response.ad_serving.webview.back_button_enabled"]);
    XCTAssertTrue([[keymapper convertValue:@"closeAdWhenLeavingApp"] isEqualToString:@"response.ad_serving.webview.close_ad_when_leaving_app"]);
    XCTAssertTrue([[keymapper convertValue:@"webviewLoadTimeout"] isEqualToString:@"response.ad_serving.webview.webview_load_timeout"]);
    XCTAssertTrue([[keymapper convertValue:@"showCloseButtonDelay"] isEqualToString:@"response.ad_serving.webview.show_close_button_delay"]);
    XCTAssertTrue([[keymapper convertValue:@"disablingReason"] isEqualToString:@"response.ad_serving.disabling_reason"]);
    XCTAssertTrue([[keymapper convertValue:@"monitoringPermissions"] isEqualToString:@"response.monitoring.request_permissions"]);
    XCTAssertTrue([[keymapper convertValue:@"cacheLogsEnabled"] isEqualToString:@"response.monitoring.tracks.enabled"]);
    XCTAssertTrue([[keymapper convertValue:@"precachingLogsEnabled"] isEqualToString:@"response.monitoring.precaching_logs.enabled"]);
    XCTAssertTrue([[keymapper convertValue:@"adLifeCycleLogsEnabled"] isEqualToString:@"response.monitoring.ad_life_cycle.enabled"]);
    XCTAssertTrue([[keymapper convertValue:@"blacklistedTracks"] isEqualToString:@"response.monitoring.ad_life_cycle.blacklist"]);
    XCTAssertTrue([[keymapper convertValue:@"omidEnabled"] isEqualToString:@"response.omid.enabled"]);
}

- (void)testAdSyncPermissionsEnabled {
    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON1_permission" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    OGAProfigFullResponse *profig = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];
    OGAAdPrivacyConfiguration *privacyConfiguration = [profig getPrivacyConfiguration];
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionAdTracking]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionDeviceIds]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionDeviceDimensions]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionDeviceOrientation]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionLayoutSize]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionUIMode]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionTimezone]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionLocaleLanguage]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionLocaleCountry]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionMobileCountry]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionConnectivity]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionWebviewUserAgent]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFV]);
    XCTAssertTrue([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionLowPowerMode]);
}

- (void)testAdSyncNoPermissions {
    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON1_NoPermission" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    OGAProfigFullResponse *profig = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];
    OGAAdPrivacyConfiguration *privacyConfiguration = [profig getPrivacyConfiguration];
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFA]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionAdTracking]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionInstanceToken]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionDeviceIds]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionDeviceDimensions]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionDeviceOrientation]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionLayoutSize]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionUIMode]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionTimezone]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionLocaleLanguage]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionLocaleCountry]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionMobileCountry]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionConnectivity]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionWebviewUserAgent]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionIDFV]);
    XCTAssertFalse([privacyConfiguration adSyncPermissionIsEnabledFor:OGAAdPrivacyPermissionLowPowerMode]);
}

- (void)testIsAdsEnabled {
    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON1" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    OGAProfigFullResponse *profig = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];
    XCTAssertTrue([profig isAdsEnabled]);

    profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON2" ofType:@"json"];
    profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    profig = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];
    XCTAssertFalse([profig isAdsEnabled]);
}

- (void)testIsOmidEnabled {
    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON1" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    OGAProfigFullResponse *profig = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];
    XCTAssertTrue([profig isOmidEnabled]);

    profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON2" ofType:@"json"];
    profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    profig = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];
    XCTAssertFalse([profig isOmidEnabled]);
}

- (void)testWhenErrorIsReceivedThenErrorFieldsAreSet {
    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigError" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    OGAProfigFullResponse *profig = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];
    XCTAssertEqualObjects(profig.errorType, @"VALIDATION");
    XCTAssertEqualObjects(profig.errorMessage, @"missing body");
    XCTAssertEqualObjects(profig.retryInterval, @(43200));
}

- (void)testIsFirstStringEqualToSecondString {
    NSString *string1;
    NSString *string2;
    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigJSON1" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    OGAProfigFullResponse *profig = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];
    XCTAssertTrue([profig is:string1 equalTo:string2]);
    string1 = @"test";
    string2 = @"test";
    XCTAssertTrue([profig is:string1 equalTo:string2]);
    string1 = @"test";
    string2 = @"not_test";
    XCTAssertFalse([profig is:string1 equalTo:string2]);
    string1 = @"test";
    string2 = string1;
    XCTAssertTrue([profig is:string1 equalTo:string2]);
}

@end
