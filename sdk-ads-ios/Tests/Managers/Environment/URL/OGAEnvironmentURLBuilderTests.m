//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAEnvironmentURLLegacyBuilder.h"
#import "OGAEnvironmentURLBuilder.h"
#import <OCMock/OCMock.h>
#import "OGAEnvironmentURLConstants.h"

@interface OGAEnvironmentURLBuilder ()

@property(nonatomic, strong) NSString *baseURL;
@property(nonatomic, strong) NSString *domain;
@property(nonatomic, strong) NSString *adSyncService;
@property(nonatomic, strong) NSString *profigService;
@property(nonatomic, strong) NSString *monitoringService;
@property(nonatomic, strong) NSString *adSyncPath;
@property(nonatomic, strong) NSString *profigPath;
@property(nonatomic, strong) NSString *monitoringPath;
@property(nonatomic, strong) NSString *monitoringVersion;
@property(nonatomic, strong) NSString *adSyncVersion;
@property(nonatomic, strong) NSString *profigVersion;
@property(nonatomic, strong) OGAEnvironmentURLLegacyBuilder *environmentURLLegacyBuilder;

- (instancetype)initWith:(OGAEnvironment)environment legacyBuilder:(OGAEnvironmentURLLegacyBuilder *)legacyBuilder;

- (void)setupServiceWith:(OGAEnvironment)environment;

- (void)setupPath;

- (void)setupDomainWith:(OGAEnvironment)environment;

- (void)setupVersion;

- (void)updateEnvironment:(OGAEnvironment)environment;

@end

@interface OGAEnvironmentURLLegacyBuilder ()
- (void)updateEnvironment:(OGAEnvironment)environment;
@end

@interface OGAEnvironmentURLBuilderTests : XCTestCase

@property(atomic, strong) OGAEnvironmentURLLegacyBuilder *environmentURLLegacyBuilder;
@property(atomic, strong) OGAEnvironmentURLBuilder *environmentURLBuilder;

@end

@implementation OGAEnvironmentURLBuilderTests

- (void)setUp {
    self.environmentURLLegacyBuilder = OCMClassMock([OGAEnvironmentURLLegacyBuilder class]);
    self.environmentURLBuilder = OCMPartialMock([[OGAEnvironmentURLBuilder alloc] initWith:OGAEnvironmentDevC legacyBuilder:self.environmentURLLegacyBuilder]);
}

- (void)testInitWith {
    OGAEnvironmentURLBuilder *environmentURLBuilder = [[OGAEnvironmentURLBuilder alloc] initWith:OGAEnvironmentProd];
    XCTAssertNotNil(environmentURLBuilder);
    XCTAssertNotNil(environmentURLBuilder.environmentURLLegacyBuilder);
}

- (void)testInitWithLegacyBuilder {
    OGAEnvironmentURLLegacyBuilder *environmentURLLegacyBuilder = OCMClassMock([OGAEnvironmentURLLegacyBuilder class]);
    OGAEnvironmentURLBuilder *environmentURLBuilder = OCMPartialMock([OGAEnvironmentURLBuilder alloc]);
    XCTAssertNotNil([environmentURLBuilder initWith:OGAEnvironmentDevC legacyBuilder:environmentURLLegacyBuilder]);
    XCTAssertNotNil(environmentURLBuilder.environmentURLLegacyBuilder);
    XCTAssertEqual(environmentURLBuilder.environmentURLLegacyBuilder, environmentURLLegacyBuilder);
    OCMVerify([environmentURLBuilder setupPath]);
    OCMVerify([environmentURLBuilder setupDomainWith:OGAEnvironmentDevC]);
    OCMVerify([environmentURLBuilder setupVersion]);
    OCMVerify([environmentURLBuilder setupServiceWith:OGAEnvironmentDevC]);
}

- (void)testSetupURLServiceWithDevc {
    [self.environmentURLBuilder setupServiceWith:OGAEnvironmentDevC];
    XCTAssertEqual(self.environmentURLBuilder.profigService, OGAServiceProfig);
    XCTAssertEqual(self.environmentURLBuilder.monitoringService, OGAServiceMonitoringDevcStaging);
    XCTAssertEqual(self.environmentURLBuilder.adSyncService, OGAServiceAdSync);
}

- (void)testSetupURLServiceWithStaging {
    [self.environmentURLBuilder setupServiceWith:OGAEnvironmentStaging];
    XCTAssertEqual(self.environmentURLBuilder.profigService, OGAServiceProfig);
    XCTAssertEqual(self.environmentURLBuilder.monitoringService, OGAServiceMonitoringDevcStaging);
    XCTAssertEqual(self.environmentURLBuilder.adSyncService, OGAServiceAdSync);
}

- (void)testSetupURLServiceWithProd {
    [self.environmentURLBuilder setupServiceWith:OGAEnvironmentProd];
    XCTAssertEqual(self.environmentURLBuilder.profigService, OGAServiceProfig);
    XCTAssertEqual(self.environmentURLBuilder.monitoringService, OGAServiceMonitoringProd);
    XCTAssertEqual(self.environmentURLBuilder.adSyncService, OGAServiceAdSyncProd);
}

- (void)testSetupPathWith {
    [self.environmentURLBuilder setupPath];
    XCTAssertEqual(self.environmentURLBuilder.profigPath, OGAPathProfig);
    XCTAssertEqual(self.environmentURLBuilder.monitoringPath, OGAPathMonitoring);
    XCTAssertEqual(self.environmentURLBuilder.adSyncPath, OGAPathAdSync);
}

- (void)testSetupDomainWithDevc {
    [self.environmentURLBuilder setupDomainWith:OGAEnvironmentDevC];
    XCTAssertEqual(self.environmentURLBuilder.domain, OGADomainDevc);
}

- (void)testSetupDomainWithStaging {
    [self.environmentURLBuilder setupDomainWith:OGAEnvironmentStaging];
    XCTAssertEqual(self.environmentURLBuilder.domain, OGADomainStaging);
}

- (void)testSetupDomainWithProd {
    [self.environmentURLBuilder setupDomainWith:OGAEnvironmentProd];
    XCTAssertEqual(self.environmentURLBuilder.domain, OGADomainProd);
}

- (void)testSetupVersionWith {
    [self.environmentURLBuilder setupVersion];
    XCTAssertEqual(self.environmentURLBuilder.profigVersion, OGAApiV1);
    XCTAssertEqual(self.environmentURLBuilder.monitoringVersion, OGAApiV1);
    XCTAssertEqual(self.environmentURLBuilder.adSyncVersion, OGAApiV2);
}

- (void)testBuildAdSyncURLProd {
    OGAEnvironmentURLBuilder *environmentURLBuilder = [[OGAEnvironmentURLBuilder alloc] initWith:OGAEnvironmentProd];
    NSURL *adSyncURL = [environmentURLBuilder buildAdSyncURL];
    XCTAssertEqualObjects(adSyncURL.absoluteString, @"https://sy.presage.io/v2/ad_sync");
}

- (void)testBuildAdSyncURLDevc {
    OGAEnvironmentURLBuilder *environmentURLBuilder = [[OGAEnvironmentURLBuilder alloc] initWith:OGAEnvironmentDevC];
    NSURL *adSyncURL = [environmentURLBuilder buildAdSyncURL];
    XCTAssertEqualObjects(adSyncURL.absoluteString, @"https://ms-bidder-adsync.devc.cloud.ogury.io/v2/ad_sync");
}

- (void)testBuildAdSyncURLStaging {
    OGAEnvironmentURLBuilder *environmentURLBuilder = [[OGAEnvironmentURLBuilder alloc] initWith:OGAEnvironmentStaging];
    NSURL *adSyncURL = [environmentURLBuilder buildAdSyncURL];
    XCTAssertEqualObjects(adSyncURL.absoluteString, @"https://ms-bidder-adsync.staging.cloud.ogury.io/v2/ad_sync");
}

- (void)testBuildMonitoringURLDevc {
    OGAEnvironmentURLBuilder *environmentURLBuilder = [[OGAEnvironmentURLBuilder alloc] initWith:OGAEnvironmentDevC];
    NSURL *monitoringURL = [environmentURLBuilder buildMonitoringURL];
    XCTAssertEqualObjects(monitoringURL.absoluteString, @"https://ms-ads-monitoring-events.devc.cloud.ogury.io/v1/sdk-ads-monitoring");
}

- (void)testBuildMonitoringURLStaging {
    OGAEnvironmentURLBuilder *environmentURLBuilder = [[OGAEnvironmentURLBuilder alloc] initWith:OGAEnvironmentStaging];
    NSURL *monitoringURL = [environmentURLBuilder buildMonitoringURL];
    XCTAssertEqualObjects(monitoringURL.absoluteString, @"https://ms-ads-monitoring-events.staging.cloud.ogury.io/v1/sdk-ads-monitoring");
}

- (void)testBuildMonitoringURLProd {
    OGAEnvironmentURLBuilder *environmentURLBuilder = [[OGAEnvironmentURLBuilder alloc] initWith:OGAEnvironmentProd];
    NSURL *monitoringURL = [environmentURLBuilder buildMonitoringURL];
    XCTAssertEqualObjects(monitoringURL.absoluteString, @"https://am-V1.presage.io/v1/sdk-ads-monitoring");
}

- (void)testBuildProfigURLProd {
    OGAEnvironmentURLBuilder *environmentURLBuilder = [[OGAEnvironmentURLBuilder alloc] initWith:OGAEnvironmentProd];
    NSURL *monitoringURL = [environmentURLBuilder buildProfigURL];
    XCTAssertEqualObjects(monitoringURL.absoluteString, @"https://sac.presage.io/v1/inapp/config");
}

- (void)testBuildProfigURLStaging {
    OGAEnvironmentURLBuilder *environmentURLBuilder = [[OGAEnvironmentURLBuilder alloc] initWith:OGAEnvironmentStaging];
    NSURL *monitoringURL = [environmentURLBuilder buildProfigURL];
    XCTAssertEqualObjects(monitoringURL.absoluteString, @"https://sac.staging.cloud.ogury.io/v1/inapp/config");
}

- (void)testBuildProfigURLdevc {
    OGAEnvironmentURLBuilder *environmentURLBuilder = [[OGAEnvironmentURLBuilder alloc] initWith:OGAEnvironmentDevC];
    NSURL *monitoringURL = [environmentURLBuilder buildProfigURL];
    XCTAssertEqualObjects(monitoringURL.absoluteString, @"https://sac.devc.cloud.ogury.io/v1/inapp/config");
}

- (void)testBuildLaunchURL {
    NSURL *launchURL = OCMClassMock([NSURL class]);
    OCMStub([self.environmentURLLegacyBuilder buildLaunchURL]).andReturn(launchURL);
    XCTAssertEqual([self.environmentURLBuilder buildLaunchURL], launchURL);
    OCMVerify([self.environmentURLLegacyBuilder buildLaunchURL]);
}

- (void)testBuildPreCacheURL {
    NSURL *preCacheURL = OCMClassMock([NSURL class]);
    OCMStub([self.environmentURLLegacyBuilder buildPreCacheURL]).andReturn(preCacheURL);
    XCTAssertEqual([self.environmentURLBuilder buildPreCacheURL], preCacheURL);
    OCMVerify([self.environmentURLLegacyBuilder buildPreCacheURL]);
}

- (void)testBuildTrackURL {
    NSURL *trackURL = OCMClassMock([NSURL class]);
    OCMStub([self.environmentURLLegacyBuilder buildTrackURL]).andReturn(trackURL);
    XCTAssertEqual([self.environmentURLBuilder buildTrackURL], trackURL);
    OCMVerify([self.environmentURLLegacyBuilder buildTrackURL]);
}

- (void)testBuildAdHistoryURL {
    NSURL *adHistoryURL = OCMClassMock([NSURL class]);
    OCMStub([self.environmentURLLegacyBuilder buildAdHistoryURL]).andReturn(adHistoryURL);
    XCTAssertEqual([self.environmentURLBuilder buildAdHistoryURL], adHistoryURL);
    OCMVerify([self.environmentURLLegacyBuilder buildAdHistoryURL]);
}

- (void)testWhenUpdateEnvironmentIsCalledThenNewEnvironementIsDispatched {
    [self.environmentURLBuilder updateEnvironment:OGAEnvironmentProd];
    OCMVerify([self.environmentURLBuilder setupPath]);
    OCMVerify([self.environmentURLBuilder setupDomainWith:OGAEnvironmentProd]);
    OCMVerify([self.environmentURLBuilder setupVersion]);
    OCMVerify([self.environmentURLBuilder setupServiceWith:OGAEnvironmentProd]);
}

- (void)testWhenTheEnvironmentIsUpdatedThenLegacyBuilderUpdateIsCalled {
    [self.environmentURLBuilder updateEnvironment:OGAEnvironmentProd];
    OCMVerify([self.environmentURLLegacyBuilder updateEnvironment:OGAEnvironmentProd]);
}

@end
