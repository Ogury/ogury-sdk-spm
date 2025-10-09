//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAConfigurationUtils.h"
#import "OGAPreCacheEvent.h"
#import "OGAMetricsRequestBuilder.h"
#import "OGATrackEvent.h"
#import "OGAAdHistoryEvent.h"
#import "OGAAssetKeyManager.h"
#import "OGAEnvironmentManager.h"
#import "OGALog.h"
#import "OGAProfigDao.h"

NSString *const OGAMetricsRequestBuilderTestsContentKey = @"content";

@interface OGAMetricsRequestBuilder (Testing)

- (instancetype)initWithAssetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                            environment:(OGAEnvironmentManager *)environment
                                    log:(OGALog *)log
                              profigDao:(OGAProfigDao *)profigDao;

- (NSURL *)buildUrl:(OGAMetricEvent *)event;

- (NSDictionary<NSString *, id> *)buildBody:(OGAMetricEvent *)event;

- (NSDictionary<NSString *, id> *)buildBodyForAdHistoryEvent:(OGAAdHistoryEvent *)event;

- (NSDictionary<NSString *, id> *)buildBodyForPreCacheEvent:(OGAPreCacheEvent *)event;

- (NSDictionary<NSString *, id> *)buildBodyForTrackEvent:(OGATrackEvent *)event;

- (NSMutableDictionary<NSString *, id> *)trackAndAdHistoryBody;

@end

@interface OGAMetricsRequestBuilderTests : XCTestCase

@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, strong) OGAEnvironmentManager *environment;
@property(nonatomic, strong) OGAMetricsRequestBuilder *builder;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAProfigDao *profigDao;
@property(nonatomic, strong) OGAAdPrivacyConfiguration *privacyCofiguration;
@property(nonatomic, strong) OGAProfigFullResponse *profigFullResponse;

@end

@implementation OGAMetricsRequestBuilderTests

- (void)setUp {
    self.log = OCMClassMock([OGALog class]);
    self.assetKeyManager = OCMClassMock([OGAAssetKeyManager class]);
    self.environment = OCMClassMock([OGAEnvironmentManager class]);
    self.profigDao = OCMClassMock([OGAProfigDao class]);
    self.privacyCofiguration = OCMClassMock([OGAAdPrivacyConfiguration class]);
    self.profigFullResponse = OCMClassMock([OGAProfigFullResponse class]);
    OCMStub(self.profigDao.profigFullResponse).andReturn(self.profigFullResponse);
    OCMStub([self.profigFullResponse getPrivacyConfiguration]).andReturn(self.privacyCofiguration);
    OGAMetricsRequestBuilder *builder = [[OGAMetricsRequestBuilder alloc] initWithAssetKeyManager:self.assetKeyManager
                                                                                      environment:self.environment
                                                                                              log:self.log
                                                                                        profigDao:self.profigDao];
    self.builder = OCMPartialMock(builder);
}

- (void)testBuildUrl_adHistoryEvent {
    NSURL *adHistoryURL = OCMClassMock([NSURL class]);
    OCMStub(self.environment.adHistoryURL).andReturn(adHistoryURL);
    OGAAdHistoryEvent *event = OCMClassMock([OGAAdHistoryEvent class]);

    NSURL *url = [self.builder buildUrl:event];

    XCTAssertEqual(url, adHistoryURL);
}

- (void)testBuildUrl_preCacheEvent {
    NSURL *preCacheURL = OCMClassMock([NSURL class]);
    OCMStub(self.environment.preCacheURL).andReturn(preCacheURL);
    OGAPreCacheEvent *event = OCMClassMock([OGAPreCacheEvent class]);

    NSURL *url = [self.builder buildUrl:event];

    XCTAssertEqual(url, preCacheURL);
}

- (void)testBuildUrl_trackEvent {
    NSURL *trackURL = OCMClassMock([NSURL class]);
    OCMStub(self.environment.trackURL).andReturn(trackURL);
    OGATrackEvent *event = OCMClassMock([OGATrackEvent class]);

    NSURL *url = [self.builder buildUrl:event];

    XCTAssertEqual(url, trackURL);
}

- (void)testBuildUrl_nil {
    XCTAssertNil([self.builder buildUrl:nil]);
}

- (void)testBuildBody_adHistoryEvent {
    OGAAdHistoryEvent *event = OCMClassMock([OGAAdHistoryEvent class]);
    NSDictionary<NSString *, id> *expectedBody = OCMClassMock([NSDictionary class]);
    OCMStub([self.builder buildBodyForAdHistoryEvent:[OCMArg any]]).andReturn(expectedBody);

    NSDictionary *body = [self.builder buildBody:event];

    XCTAssertEqual(body, expectedBody);
    OCMVerify([self.builder buildBodyForAdHistoryEvent:event]);
}

- (void)testBuildBody_preCacheEvent {
    OGAPreCacheEvent *event = OCMClassMock([OGAPreCacheEvent class]);
    NSDictionary<NSString *, id> *expectedBody = OCMClassMock([NSDictionary class]);
    OCMStub([self.builder buildBodyForPreCacheEvent:[OCMArg any]]).andReturn(expectedBody);

    NSDictionary *body = [self.builder buildBody:event];

    XCTAssertEqual(body, expectedBody);
    OCMVerify([self.builder buildBodyForPreCacheEvent:event]);
}

- (void)testBuildBody_trackEvent {
    OGATrackEvent *event = OCMClassMock([OGATrackEvent class]);
    NSDictionary<NSString *, id> *expectedBody = OCMClassMock([NSDictionary class]);
    OCMStub([self.builder buildBodyForTrackEvent:[OCMArg any]]).andReturn(expectedBody);

    NSDictionary *body = [self.builder buildBody:event];

    XCTAssertEqual(body, expectedBody);
    OCMVerify([self.builder buildBodyForTrackEvent:event]);
}

- (void)testBuildBody_nil {
    XCTAssertNil([self.builder buildBody:nil]);
}

- (void)testBuildBodyForTrackEvent {
    NSMutableDictionary<NSString *, id> *commonBody = [[NSMutableDictionary alloc] init];
    OCMStub([self.builder trackAndAdHistoryBody]).andReturn(commonBody);
    OGATrackEvent *event = OCMClassMock([OGATrackEvent class]);
    NSDictionary<NSString *, id> *eventBody = [[NSDictionary alloc] init];
    OCMStub([event toDictionary]).andReturn(eventBody);

    NSDictionary *body = [self.builder buildBodyForTrackEvent:event];

    XCTAssertEqual(body, commonBody);
    XCTAssertEqual(body[OGAMetricsRequestBuilderTestsContentKey], eventBody);
}

- (void)testBuildBodyForPreCacheEvent {
    OGAPreCacheEvent *event = OCMClassMock([OGAPreCacheEvent class]);
    NSDictionary<NSString *, id> *eventBody = [[NSDictionary alloc] init];
    OCMStub([event toDictionary]).andReturn(eventBody);

    NSDictionary *body = [self.builder buildBodyForPreCacheEvent:event];

    XCTAssertTrue([body[OGAMetricsRequestBuilderTestsContentKey] isKindOfClass:[NSArray class]]);
    XCTAssertEqual(body[OGAMetricsRequestBuilderTestsContentKey][0], eventBody);
}

- (void)testBuildBodyForAdHistoryEvent {
    NSMutableDictionary<NSString *, id> *commonBody = [[NSMutableDictionary alloc] init];
    OCMStub([self.builder trackAndAdHistoryBody]).andReturn(commonBody);
    OGAAdHistoryEvent *event = OCMClassMock([OGAAdHistoryEvent class]);
    NSDictionary<NSString *, id> *eventBody = [[NSDictionary alloc] init];
    OCMStub([event toDictionary]).andReturn(eventBody);

    NSDictionary *body = [self.builder buildBodyForAdHistoryEvent:event];

    XCTAssertEqual(body, commonBody);
    XCTAssertEqual(body[OGAMetricsRequestBuilderTestsContentKey], eventBody);
}

- (void)testCommonBodyNoPermission {
    OCMStub(self.assetKeyManager.assetKey).andReturn(@"asset-key");
    NSMutableDictionary<NSString *, id> *body = [self.builder trackAndAdHistoryBody];
    XCTAssertNotNil(body[@"at"]);
    XCTAssertEqualObjects(body[@"apps_publishers"], @[ @"asset-key" ]);
    XCTAssertEqualObjects(body[@"version"], OGA_SDK_VERSION);
    NSString *buildVersionString = OGA_SDK_BUILD_VERSION;
    XCTAssertEqualObjects(body[@"build"], [NSNumber numberWithInt:[buildVersionString intValue]]);
    XCTAssertNil(body[@"connectivity"]);
}

- (void)testCommonBodyNoPersmissionConnectivity {
    OCMStub(self.assetKeyManager.assetKey).andReturn(@"asset-key");
    OCMStub([self.privacyCofiguration monitoringPermissionIsEnabledFor:OGAAdPrivacyPermissionConnectivity]).andReturn(YES);
    NSMutableDictionary<NSString *, id> *body = [self.builder trackAndAdHistoryBody];
    XCTAssertNotNil(body[@"at"]);
    XCTAssertEqualObjects(body[@"apps_publishers"], @[ @"asset-key" ]);
    XCTAssertEqualObjects(body[@"version"], OGA_SDK_VERSION);
    NSString *buildVersionString = OGA_SDK_BUILD_VERSION;
    XCTAssertEqualObjects(body[@"build"], [NSNumber numberWithInt:[buildVersionString intValue]]);
    XCTAssertNotNil(body[@"connectivity"]);
}

@end
