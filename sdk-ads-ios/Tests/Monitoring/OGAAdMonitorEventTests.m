//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAAdMonitorEvent.h"
#import "OGAMonitoringConstants.h"
#import "OguryError+utility.h"
#import "OGAAdMonitorEvent+Tests.h"
#import "OGAMonitorEventConfiguration.h"

@interface OGAMonitorEventTests : XCTestCase

@property(nonatomic, strong) OGMMonitorEvent *event;
@property(nonatomic, strong) OGAAdConfiguration *adConfiguration;

@end

static NSInteger const TestTimestamp = 1000;
static NSString *const TestSessionId = @"1001";
static NSString *const TestEventCode = @"LT-100";
static NSString *const TestEventName = @"test";
static OGMDispatchType const TestDispatchType = OGMDispatchTypeImmediate;
static NSString *const TestAdUnitId = @"testAdunitId";
static NSString *const TestCampaignId = @"testCampaignId";
static NSString *const TestCreativeId = @"testCreativeId";
static NSString *const TestDetail = @"detailTest";
static NSString *const TestContent = @"detailContentTest";

@interface OGAAdMonitorEvent ()
@property(nonatomic, retain) NSString *adUnitId;
@property(nonatomic, retain, nullable) NSString *campaignId;
@property(nonatomic, retain, nullable) NSString *creativeId;
@property(nonatomic, retain) NSNumber *timestamp;
@property(nonatomic, retain) NSString *sessionId;
@property(nonatomic, retain) NSString *eventCode;
@property(nonatomic, retain) NSString *eventName;
@property(nonatomic, retain, nullable) NSDictionary *details;
@property(nonatomic, retain, nullable) NSString *errorType;
@property(nonatomic, retain, nullable) NSDictionary *errorContent;
@property(nonatomic, retain, nullable) OguryMediation *mediation;
@end

@implementation OGAMonitorEventTests

- (void)setUp {
    NSDictionary *firstDictionnary = @{@"name" : @"dsp", @"value" : @"{\"creative_id\": \"123\", \"region\":\"east-us\"}", @"version" : @2};
    NSDictionary *secondDictionnary = @{@"name" : @"vast_version", @"value" : @"4.0", @"version" : @1};
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
    _adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(self.adConfiguration.adUnitId).andReturn(@"adUnitId");
    OCMStub(self.adConfiguration.campaignId).andReturn(@"campaignId");
    OCMStub(self.adConfiguration.creativeId).andReturn(@"creativeId");
    OGAMonitoringDetails *details = OCMClassMock([OGAMonitoringDetails class]);
    OCMStub(self.adConfiguration.monitoringDetails).andReturn(details);
    OCMStub(details.sessionId).andReturn(@"sessionId");
}

- (void)testAsDictionary {
    NSDictionary *dict = [self.event asDisctionary];

    XCTAssertEqualObjects(dict[OGAMonitorEventBodyTimestamp], @(TestTimestamp));
    XCTAssertEqualObjects(dict[OGAMonitorEventBodySessionId], TestSessionId);
    XCTAssertEqualObjects(dict[OGAMonitorEventBodyEventCode], TestEventCode);
    XCTAssertEqualObjects(dict[OGAMonitorEventBodyEventName], TestEventName);

    XCTAssertEqualObjects(dict[OGAMonitorEventBodyDispatchMethod], OGAMonitorEventBodyDispatchMethodImmediate);

    XCTAssertEqualObjects(dict[OGAAdMonitorEventBodyAdUnit][OGAAdMonitorEventBodyAdUnitId], TestAdUnitId);
    XCTAssertEqualObjects(dict[OGAAdMonitorEventBodyAd][OGAAdMonitorEventBodyAdCampaignId], TestCampaignId);
    XCTAssertEqualObjects(dict[OGAAdMonitorEventBodyAd][OGAAdMonitorEventBodyAdCreativeId], TestCreativeId);

    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{TestDetail : TestContent} options:0 error:&err];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    XCTAssertTrue([dict[OGAMonitorEventBodyDetails] isEqual:jsonString]);
}

- (void)testNSCoding {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.event];
    OGMMonitorEvent *retrievedEvent = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSMutableDictionary *mutableEventDict = [self.event.asDisctionary mutableCopy];
    mutableEventDict[OGAMonitorEventBodyDispatchMethod] = OGAMonitorEventBodyDispatchMethodDeferred;
    // event are always deferred when retrieved from persistance, hence this value is not encoded, but directly assigned in decoding phase

    XCTAssertTrue([mutableEventDict isEqualToDictionary:retrievedEvent.asDisctionary]);
}

- (void)testWhenUsingCustomSessionIdThenItHasPrecedenceOverAdConfiguration {
    OGAMonitorEventConfiguration *eventConfiguration = [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"code"
                                                                                                     eventName:@"name"
                                                                                                permissionMask:OGAAdIdMaskNone];
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithEventConfiguration:eventConfiguration
                                                                     adConfiguration:self.adConfiguration
                                                                     customSessionId:@"customSessionId"
                                                                   detailsDictionary:nil
                                                                        errorContent:nil];
    XCTAssertEqualObjects(event.sessionId, @"customSessionId");
}

- (void)testWhenNotUsingCustomSessionIdThenSessionIdFromAdConfigurationIsUsed {
    OGAMonitorEventConfiguration *eventConfiguration = [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"code"
                                                                                                     eventName:@"name"
                                                                                                permissionMask:OGAAdIdMaskNone];
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithEventConfiguration:eventConfiguration
                                                                     adConfiguration:self.adConfiguration
                                                                     customSessionId:nil
                                                                   detailsDictionary:nil
                                                                        errorContent:nil];
    XCTAssertEqualObjects(event.sessionId, @"sessionId");
}

- (void)testWhenCampaignIdShouldBeUsedThenItIsSaved {
    OGAMonitorEventConfiguration *eventConfiguration = [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"code"
                                                                                                     eventName:@"name"
                                                                                                permissionMask:OGAAdIdMaskCampaignId];
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithEventConfiguration:eventConfiguration
                                                                     adConfiguration:self.adConfiguration
                                                                     customSessionId:nil
                                                                   detailsDictionary:nil
                                                                        errorContent:nil];
    XCTAssertEqualObjects(event.campaignId, @"campaignId");
    XCTAssertNil(event.creativeId);
}

- (void)testWhenCreativeIdShouldBeUsedThenItIsSaved {
    OGAMonitorEventConfiguration *eventConfiguration = [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"code"
                                                                                                     eventName:@"name"
                                                                                                permissionMask:OGAAdIdMaskCreativeId];
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithEventConfiguration:eventConfiguration
                                                                     adConfiguration:self.adConfiguration
                                                                     customSessionId:nil
                                                                   detailsDictionary:nil
                                                                        errorContent:nil];
    XCTAssertEqualObjects(event.creativeId, @"creativeId");
    XCTAssertNil(event.campaignId);
}

- (void)testWhenCampaignIdAndCreativeIdShouldBeUsedThenTheyAreSaved {
    OGAMonitorEventConfiguration *eventConfiguration = [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"code"
                                                                                                     eventName:@"name"
                                                                                                permissionMask:OGAAdIdMaskCreativeId | OGAAdIdMaskCampaignId];
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithEventConfiguration:eventConfiguration
                                                                     adConfiguration:self.adConfiguration
                                                                     customSessionId:nil
                                                                   detailsDictionary:nil
                                                                        errorContent:nil];
    XCTAssertEqualObjects(event.creativeId, @"creativeId");
    XCTAssertEqualObjects(event.creativeId, @"creativeId");
}

- (void)testWhenCampaignIdAndCreativeIdShouldNotBeUsedThenTheyAreNotSaved {
    OGAMonitorEventConfiguration *eventConfiguration = [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"code"
                                                                                                     eventName:@"name"
                                                                                                permissionMask:OGAAdIdMaskNone];
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithEventConfiguration:eventConfiguration
                                                                     adConfiguration:self.adConfiguration
                                                                     customSessionId:nil
                                                                   detailsDictionary:nil
                                                                        errorContent:nil];
    XCTAssertNil(event.campaignId);
    XCTAssertNil(event.creativeId);
}

- (void)testWhenIntializingFromEventConfigurationThenAllFieldsAreSaved {
    OGAMonitorEventConfiguration *eventConfiguration = [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"code"
                                                                                                     eventName:@"name"
                                                                                                permissionMask:OGAAdIdMaskNone];
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithEventConfiguration:eventConfiguration
                                                                     adConfiguration:self.adConfiguration
                                                                     customSessionId:nil
                                                                   detailsDictionary:nil
                                                                        errorContent:nil];
    XCTAssertEqualObjects(event.sessionId, @"sessionId");
    XCTAssertEqualObjects(event.eventCode, @"code");
    XCTAssertEqualObjects(event.eventName, @"name");
    XCTAssertNil(event.details);
    XCTAssertNil(event.errorType);
    XCTAssertNil(event.errorContent);
}

- (void)testWhenIntializingWithDetailThenDetailIsSaved {
    OGAMonitorEventConfiguration *eventConfiguration = [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"code"
                                                                                                     eventName:@"name"
                                                                                                permissionMask:OGAAdIdMaskNone];
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithEventConfiguration:eventConfiguration
                                                                     adConfiguration:self.adConfiguration
                                                                     customSessionId:nil
                                                                   detailsDictionary:@{@"key" : @"value"}
                                                                        errorContent:nil];
    XCTAssertEqualObjects(event.details, @{@"key" : @"value"});
    XCTAssertNil(event.errorType);
    XCTAssertNil(event.errorContent);
}

- (void)testWhenIntializingFromErrorThenAllFieldsSaved {
    OGAMonitorEventConfiguration *eventConfiguration = [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"code"
                                                                                                     eventName:@"name"
                                                                                                     errorType:@"errorType"
                                                                                              errorDescription:@"errorDescription"
                                                                                                permissionMask:OGAAdIdMaskNone];
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithEventConfiguration:eventConfiguration
                                                                     adConfiguration:self.adConfiguration
                                                                     customSessionId:nil
                                                                   detailsDictionary:@{@"key" : @"value"}
                                                                        errorContent:@{@"errorKey" : eventConfiguration.errorDescription}];
    XCTAssertEqualObjects(event.details, @{@"key" : @"value"});
    XCTAssertEqualObjects(event.errorType, @"errorType");
    XCTAssertEqualObjects(event.errorContent, @{@"errorKey" : @"errorDescription"});
}

- (void)testWhenMediationIsProvidedThenItIsSaved {
    OGAMonitorEventConfiguration *eventConfiguration = [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"code"
                                                                                                     eventName:@"name"
                                                                                                     errorType:@"errorType"
                                                                                              errorDescription:@"errorDescription"
                                                                                                permissionMask:OGAAdIdMaskNone];
    OguryMediation *mediation = [[OguryMediation alloc] initWithName:@"name" version:@"version"];
    OGAMonitoringDetails *details = [OGAMonitoringDetails new];
    details.mediation = mediation;
    OGAAdConfiguration *conf = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                               adUnitId:@"adUnit"
                                                     delegateDispatcher:nil
                                                 viewControllerProvider:nil];
    conf.monitoringDetails = details;
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithEventConfiguration:eventConfiguration
                                                                     adConfiguration:conf
                                                                     customSessionId:nil
                                                                   detailsDictionary:@{@"key" : @"value"}
                                                                        errorContent:@{@"errorKey" : eventConfiguration.errorDescription}];
    XCTAssertEqualObjects(event.mediation, mediation);
}

- (void)testWhenEventWithMediationIsArchivedThenItIsUnarchivedProperly {
    OGAMonitorEventConfiguration *eventConfiguration = [[OGAMonitorEventConfiguration alloc] initWithEventCode:@"code"
                                                                                                     eventName:@"name"
                                                                                                     errorType:@"errorType"
                                                                                              errorDescription:@"errorDescription"
                                                                                                permissionMask:OGAAdIdMaskNone];
    OguryMediation *mediation = [[OguryMediation alloc] initWithName:@"name" version:@"version"];
    OGAMonitoringDetails *details = [OGAMonitoringDetails new];
    details.mediation = mediation;
    OGAAdConfiguration *conf = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                               adUnitId:@"adUnit"
                                                     delegateDispatcher:nil
                                                 viewControllerProvider:nil];
    conf.monitoringDetails = details;
    OGAAdMonitorEvent *event = [[OGAAdMonitorEvent alloc] initWithEventConfiguration:eventConfiguration
                                                                     adConfiguration:conf
                                                                     customSessionId:nil
                                                                   detailsDictionary:@{@"key" : @"value"}
                                                                        errorContent:@{@"errorKey" : eventConfiguration.errorDescription}];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:event];
    OGAAdMonitorEvent *retrievedEvent = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(retrievedEvent.mediation, mediation);
}

@end
