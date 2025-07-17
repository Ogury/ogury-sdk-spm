//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAAdMonitorEvent.h"
#import "OGAAdServerMonitorRequestBuilder.h"
#import "OGAAdMonitorEvent+Tests.h"
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
#import "OguryAdError+Internal.h"

@interface OGAAdServerMonitorRequestBuilder ()

- (instancetype)init:(NSURL *)url
            assetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                  profigDao:(OGAProfigDao *)profigDao
                        log:(OGALog *)log
    webViewUserAgentService:(OGAWebViewUserAgentService *)webViewUserAgentService
       telephonyNetworkInfo:(CTTelephonyNetworkInfo *)telephonyNetworkInfo;

- (NSString *)getSimCardCountry;

@end

@interface OGAAdServerMonitorRequestBuilderTests : XCTestCase

@property(nonatomic) OGAAdServerMonitorRequestBuilder *requestBuilder;
@property(nonatomic) OGAProfigDao *profigDao;
@property(nonatomic) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic) OGALog *log;
@property(nonatomic) NSURL *url;
@property(nonatomic) OGAWebViewUserAgentService *webViewUserAgentService;
@property(nonatomic) CTTelephonyNetworkInfo *telephonyNetworkInfo;

@end

@implementation OGAAdServerMonitorRequestBuilderTests

- (void)setUp {
    self.url = [[NSURL alloc] initWithString:@"http://www.dummy.fr"];
    self.assetKeyManager = OCMClassMock([OGAAssetKeyManager class]);
    self.webViewUserAgentService = OCMClassMock([OGAWebViewUserAgentService class]);
    self.telephonyNetworkInfo = OCMClassMock([CTTelephonyNetworkInfo class]);
    self.requestBuilder = OCMPartialMock([[OGAAdServerMonitorRequestBuilder alloc] init:self.url
                                                                        assetKeyManager:self.assetKeyManager
                                                                              profigDao:self.profigDao
                                                                                    log:self.log
                                                                webViewUserAgentService:self.webViewUserAgentService
                                                                   telephonyNetworkInfo:self.telephonyNetworkInfo]);
}

- (void)testWhenRequestIsBuilt_ThenDeviceNameIsNeverCalled {
    NSDictionary *firstDictionnary = @{@"name" : @"dsp", @"value" : @"{\"creative_id\": \"123\", \"region\":\"east-us\"}", @"version" : @2};
    NSDictionary *secondDictionnary = @{@"name" : @"vast_version", @"value" : @"4.0", @"version" : @1};
    NSArray *extras = @[ firstDictionnary, secondDictionnary ];
    id currentDevice = OCMPartialMock([UIDevice currentDevice]);

    OguryMediation *mediation = [[OguryMediation alloc] initWithName:@"Mediation" version:@"1.0.0" adapterVersion:@"4.0.0.1"];

    OCMReject([currentDevice name]);
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithTimestamp:@1000
                                                                  sessionId:@"session"
                                                                  eventCode:@"eventCode"
                                                                  eventName:@"event"
                                                               dispatchType:OGMDispatchTypeImmediate
                                                                   adUnitId:@"adUnit"
                                                                  mediation:mediation
                                                                 campaignId:@"campaignId"
                                                                 creativeId:@"creativeId"
                                                                     extras:extras
                                                          detailsDictionary:@{@"Dictionary" : @YES}
                                                                  errorType:nil
                                                               errorContent:nil];
    [self.requestBuilder buildRequestWithEvents:@[ event ]];
    [currentDevice stopMocking];
}

- (void)testWhenRequestIsBuilt_ThenDeviceNameIsNeverCalled_NoAdapterVersion {
    NSDictionary *firstDictionnary = @{@"name" : @"dsp", @"value" : @"{\"creative_id\": \"123\", \"region\":\"east-us\"}", @"version" : @2};
    NSDictionary *secondDictionnary = @{@"name" : @"vast_version", @"value" : @"4.0", @"version" : @1};
    NSArray *extras = @[ firstDictionnary, secondDictionnary ];
    id currentDevice = OCMPartialMock([UIDevice currentDevice]);

    OguryMediation *mediation = [[OguryMediation alloc] initWithName:@"Mediation" version:@"1.0.0"];

    OCMReject([currentDevice name]);
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithTimestamp:@1000
                                                                  sessionId:@"session"
                                                                  eventCode:@"eventCode"
                                                                  eventName:@"event"
                                                               dispatchType:OGMDispatchTypeImmediate
                                                                   adUnitId:@"adUnit"
                                                                  mediation:mediation
                                                                 campaignId:@"campaignId"
                                                                 creativeId:@"creativeId"
                                                                     extras:extras
                                                          detailsDictionary:@{@"Dictionary" : @YES}
                                                                  errorType:nil
                                                               errorContent:nil];
    [self.requestBuilder buildRequestWithEvents:@[ event ]];
    [currentDevice stopMocking];
}

- (void)testGetSimCardCountry_iOS16AndAbove {
    if (@available(iOS 16, *)) {
        NSString *result = [self.requestBuilder getSimCardCountry];
        XCTAssertEqualObjects(result, @"--", @"Expected '--' for iOS 16 and above.");
    }
}

@end
