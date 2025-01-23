//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock/OCMock.h"
#import "OGAAdMonitorEvent.h"
#import "OGAAdServerMonitorRequestBuilder.h"
#import "OGAAssetKeyManager.h"
#import "OGAConfigurationUtils.h"
#import "OGADevice.h"
#import "OGALog.h"
#import "OGAProfigDao.h"
#import "OGAWebViewUserAgentService.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface OGAAdServerMonitorRequestBuilder ()

@property(nonatomic, retain) NSString *userAgent;

- (instancetype)init:(NSURL *)url
            assetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                  profigDao:(OGAProfigDao *)profigDao
                        log:(OGALog *)log
    webViewUserAgentService:(OGAWebViewUserAgentService *)webViewUserAgentService
       telephonyNetworkInfo:(CTTelephonyNetworkInfo *)telephonyNetworkInfo;

- (NSDictionary *)buildBodyFromEvent:(NSArray<id<OGMEventMonitorable>> *)events;
- (OGADevice *)device;
- (NSString *)deviceOrientation;
- (NSLocale *)locale;
- (BOOL)isLowPowered;

@end

@interface OGMServerMonitorTest : XCTestCase

@property(nonatomic, strong) OGMMonitorEvent *event;
@property(nonatomic, strong) CTTelephonyNetworkInfo *telephonyNetworkInfo;

@end

@interface OGAAdPrivacyConfiguration (Test)

@property NSUInteger adSyncPermissions;
@property NSUInteger monitoringPermissions;

@end

@interface OGAAdMonitorEvent ()
- (instancetype)initWithTimestamp:(NSNumber *)timestamp
                        sessionId:(NSString *)sessionId
                        eventCode:(NSString *)eventCode
                        eventName:(NSString *)eventName
                     dispatchType:(OGMDispatchType)dispatchType
                         adUnitId:(NSString *)adUnitId
                       campaignId:(NSString *_Nullable)campaignId
                       creativeId:(NSString *_Nullable)creativeId
                           extras:(NSArray *_Nullable)extras
                detailsDictionary:(NSDictionary *_Nullable)detailsDictionary
                        errorType:(NSString *_Nullable)errorType
                     errorContent:(NSDictionary *)errorContent;
@end

@interface OGAAdMonitorEvent ()
- (instancetype)initWithTimestamp:(NSNumber *)timestamp
                        sessionId:(NSString *)sessionId
                        eventCode:(NSString *)eventCode
                        eventName:(NSString *)eventName
                     dispatchType:(OGMDispatchType)dispatchType
                         adUnitId:(NSString *)adUnitId
                        mediation:(OguryMediation *)mediation
                       campaignId:(NSString *_Nullable)campaignId
                       creativeId:(NSString *_Nullable)creativeId
                           extras:(NSArray *_Nullable)extras
                detailsDictionary:(NSDictionary *_Nullable)detailsDictionary
                        errorType:(NSString *_Nullable)errorType
                     errorContent:(NSDictionary *)errorContent;
@end

static NSInteger const TestTimestamp = 1000;
static NSString *const TestSessionId = @"SessionID1001";
static NSString *const TestEventCode = @"LT-100";
static NSString *const TestEventName = @"test";
static OGMDispatchType const TestDispatchType = OGMDispatchTypeImmediate;
static NSString *const TestAdUnitId = @"testAdunitId";
static NSString *const TestCampaignId = @"testCampaignId";
static NSString *const TestCreativeId = @"testCreativeId";
static NSString *const TestAssetKey = @"assetKey123";
static NSString *const TestDetail = @"detailTest";
static NSString *const TestContent = @"detailContentTest";

@implementation OGMServerMonitorTest

- (void)setUp {
    NSDictionary *firstDictionnary = @{@"name" : @"dsp", @"value" : @"{\"creative_id\": \"123\", \"region\":\"east-us\"}", @"version" : @2};
    NSDictionary *secondDictionnary = @{@"name" : @"vast_version", @"value" : @"4.0", @"version" : @1};
    self.telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSArray *extras = @[ firstDictionnary, secondDictionnary ];
    self.event = OCMPartialMock([[OGAAdMonitorEvent alloc] initWithTimestamp:[NSNumber numberWithInt:TestTimestamp]
                                                                   sessionId:TestSessionId
                                                                   eventCode:TestEventCode
                                                                   eventName:TestEventName
                                                                dispatchType:TestDispatchType
                                                                    adUnitId:TestAdUnitId
                                                                   mediation:nil
                                                                  campaignId:TestCampaignId
                                                                  creativeId:TestCreativeId
                                                                      extras:extras
                                                           detailsDictionary:@{TestDetail : TestContent}
                                                                   errorType:nil
                                                                errorContent:nil]);
}

- (OGAAdServerMonitorRequestBuilder *)mockedRequestBuilderWithPermissions:(NSUInteger)permissions {
    id logMock = OCMClassMock([OGALog class]);
    OGAAssetKeyManager *assetKeyManagerMock = OCMClassMock([OGAAssetKeyManager class]);
    OCMStub([assetKeyManagerMock assetKey]).andReturn(TestAssetKey);
    OGAAdPrivacyConfiguration *privacyConfiguration = OCMPartialMock([[OGAAdPrivacyConfiguration alloc] initWithAdSyncPermissionMask:permissions monitoringMask:permissions]);
    OGAProfigFullResponse *profigFullResponse = OCMClassMock([OGAProfigFullResponse class]);
    OGAProfigDao *profigDao = OCMClassMock([OGAProfigDao class]);
    OGAWebViewUserAgentService *webViewUserAgentService = OCMClassMock([OGAWebViewUserAgentService class]);
    OCMStub(webViewUserAgentService.webViewUserAgent).andReturn(@"USER_AGENT");
    OCMStub([profigDao profigFullResponse]).andReturn(profigFullResponse);
    OCMStub([profigFullResponse getPrivacyConfiguration]).andReturn(privacyConfiguration);
    OGAAdServerMonitorRequestBuilder *requestBuilder = OCMPartialMock([[OGAAdServerMonitorRequestBuilder alloc] init:[NSURL URLWithString:@"https://www.google.com/"]
                                                                                                     assetKeyManager:assetKeyManagerMock
                                                                                                           profigDao:profigDao
                                                                                                                 log:logMock
                                                                                             webViewUserAgentService:webViewUserAgentService
                                                                                                telephonyNetworkInfo:self.telephonyNetworkInfo]);
    OGADevice *device = OCMPartialMock([OGADevice new]);
    OCMStub([device name]).andReturn(@"deviceName");
    OCMStub([device osVersion]).andReturn(@"osVersion");
    OCMStub([device osVersion]).andReturn(@"osVersion");
    OCMStub([device name]).andReturn(@"deviceName");
    OGAScreen *screen = OCMClassMock([OGAScreen class]);
    OCMStub([device screen]).andReturn(screen);
    OCMStub(screen.width).andReturn(@200);
    OCMStub(screen.height).andReturn(@200);
    OCMStub([requestBuilder device]).andReturn(device);
    OCMStub([requestBuilder deviceOrientation]).andReturn(@"portrait");
    OCMStub([requestBuilder isLowPowered]).andReturn(YES);
    NSLocale *locale = OCMClassMock([NSLocale class]);
    OCMStub([requestBuilder locale]).andReturn(locale);
    OCMStub([locale languageCode]).andReturn(@"fr");
    OCMStub([locale countryCode]).andReturn(@"FRA");

    return requestBuilder;
}

- (NSDictionary *)payloadWithPermissions:(NSUInteger)permissions {
    OGAAdServerMonitorRequestBuilder *requestBuilder = [self mockedRequestBuilderWithPermissions:permissions];
    return [requestBuilder buildBodyFromEvent:@[ self.event ]];
}

- (void)checkAdSyncPayloadWithPermissionMask:(NSUInteger)permission assertMessage:(NSString *)message {
    NSDictionary *payload = [self payloadWithPermissions:permission];
    if (permission & 1) {
        // n/a
    } else {
        // n/a
    }
    if (permission & 2) {
        // n/a
    } else {
        // n/a
    }
    if (permission & 4) {
        // n/a
    } else {
        // n/a
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
        // n/a
    } else {
        // n/a
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
    for (int index = 0; index < permissions.count; index++) {
        NSUInteger permission = [permissions[index] intValue];
        [self checkAdSyncPayloadWithPermissionMask:permission assertMessage:[self assertMessageForPermission:permission]];
    }
}

- (void)testWhenComputedPermissionMaskIsUsedThenAllProperFieldsAreSetInPayload {
    [self checkAdSyncPayloadWithPermissionMask:16383 assertMessage:@"Testing all permissions but vendor Id"];
}

- (void)testWhenSendingEventEnvelopeThenAllUUIDsAreLowercased {
    OGAAdServerMonitorRequestBuilder *builder = [self mockedRequestBuilderWithPermissions:0];
    NSDictionary *body = [builder buildBodyFromEvent:@[ self.event ]];
    NSString *requestId = body[@"request_id"];
    XCTAssertTrue([requestId compare:requestId.lowercaseString] == NSOrderedSame);
    NSString *sessionId = body[@"events"][0][@"session_id"];
    XCTAssertTrue([sessionId compare:sessionId.lowercaseString] == NSOrderedSame);
}

@end
