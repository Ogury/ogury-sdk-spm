//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAEnvironmentURLLegacyBuilder.h"
#import "OGAEnvironmentURLConstants.h"
#import <OCMock/OCMock.h>

@interface OGAEnvironmentURLLegacyBuilder ()

@property(nonatomic, strong) NSString *baseLegacyURL;

- (NSURL *)buildURLWithService:(NSString *)service
                        server:(NSString *)server
                       version:(NSString *)apiVersion;
- (void)updateEnvironment:(OGAEnvironment)environment;

@end

@interface OGAEnvironmentURLLegacyBuilderTests : XCTestCase

@property(nonatomic, strong) OGAEnvironmentURLLegacyBuilder *legacyBuilder;

@end

@implementation OGAEnvironmentURLLegacyBuilderTests

- (void)setUp {
    self.legacyBuilder = OCMPartialMock([[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentDevC]);
}

- (void)testInitWithDevc {
    XCTAssertNotNil(self.legacyBuilder);
    XCTAssertEqual(self.legacyBuilder.baseLegacyURL, OGADevCURL);
}

- (void)testWhenUpdateEnvironmentIsCalledThenBaseUrlIsUpdated {
    [self.legacyBuilder updateEnvironment:OGAEnvironmentProd];
    XCTAssertEqual(self.legacyBuilder.baseLegacyURL, OGAProductionURL);
    [self.legacyBuilder updateEnvironment:OGAEnvironmentStaging];
    XCTAssertEqual(self.legacyBuilder.baseLegacyURL, OGAStagingURL);
    [self.legacyBuilder updateEnvironment:OGAEnvironmentDevC];
    XCTAssertEqual(self.legacyBuilder.baseLegacyURL, OGADevCURL);
}

- (void)testInitWithProd {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentProd];
    XCTAssertNotNil(legacyBuilder);
    XCTAssertEqual(legacyBuilder.baseLegacyURL, OGAProductionURL);
}

- (void)testInitWithStaging {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentStaging];
    XCTAssertNotNil(legacyBuilder);
    XCTAssertEqual(legacyBuilder.baseLegacyURL, OGAStagingURL);
}

- (void)testBuildLaunchURLDevC {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentDevC];
    NSURL *urlLaunch = [legacyBuilder buildLaunchURL];
    XCTAssertEqualObjects(urlLaunch.absoluteString, @"https://l-v1.devc.cloud.ogury.io/v1/launch");
}

- (void)testBuildLaunchURLStaging {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentStaging];
    NSURL *urlLaunch = [legacyBuilder buildLaunchURL];
    XCTAssertEqualObjects(urlLaunch.absoluteString, @"https://l-v1.staging.presage.io/v1/launch");
}

- (void)testBuildLaunchURLProd {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentProd];
    NSURL *urlLaunch = [legacyBuilder buildLaunchURL];
    XCTAssertEqualObjects(urlLaunch.absoluteString, @"https://l-v1.presage.io/v1/launch");
}

- (void)testBuildPreCacheURLProd {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentProd];
    NSURL *preCacheURL = [legacyBuilder buildPreCacheURL];
    XCTAssertEqualObjects(preCacheURL.absoluteString, @"https://pl-v2.presage.io/v2/pl");
}

- (void)testBuildPreCacheURLStaging {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentStaging];
    NSURL *preCacheURL = [legacyBuilder buildPreCacheURL];
    XCTAssertEqualObjects(preCacheURL.absoluteString, @"https://pl-v2.staging.presage.io/v2/pl");
}

- (void)testBuildPreCacheURLDevc {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentDevC];
    NSURL *preCacheURL = [legacyBuilder buildPreCacheURL];
    XCTAssertEqualObjects(preCacheURL.absoluteString, @"https://pl-v2.devc.cloud.ogury.io/v2/pl");
}

- (void)testBuildTrackURLDevc {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentDevC];
    NSURL *trackURL = [legacyBuilder buildTrackURL];
    XCTAssertEqualObjects(trackURL.absoluteString, @"https://tr-v1.devc.cloud.ogury.io/v1/track");
}

- (void)testBuildTrackURLStaging {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentStaging];
    NSURL *trackURL = [legacyBuilder buildTrackURL];
    XCTAssertEqualObjects(trackURL.absoluteString, @"https://tr-v1.staging.presage.io/v1/track");
}

- (void)testBuildTrackURLProd {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentProd];
    NSURL *trackURL = [legacyBuilder buildTrackURL];
    XCTAssertEqualObjects(trackURL.absoluteString, @"https://tr-v1.presage.io/v1/track");
}

- (void)testBuildAdHistoryURLDevc {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentDevC];
    NSURL *adHistoryURL = [legacyBuilder buildAdHistoryURL];
    XCTAssertEqualObjects(adHistoryURL.absoluteString, @"https://ah-v1.devc.cloud.ogury.io/v1/ad_history");
}

- (void)testBuildAdHistoryURLStaging {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentStaging];
    NSURL *adHistoryURL = [legacyBuilder buildAdHistoryURL];
    XCTAssertEqualObjects(adHistoryURL.absoluteString, @"https://ah-v1.staging.presage.io/v1/ad_history");
}

- (void)testBuildAdHistoryURLProd {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentProd];
    NSURL *adHistoryURL = [legacyBuilder buildAdHistoryURL];
    XCTAssertEqualObjects(adHistoryURL.absoluteString, @"https://ah-v1.presage.io/v1/ad_history");
}

- (void)testBuildURLWithServiceDevc {
    NSURL *builtURL = [self.legacyBuilder buildURLWithService:@"SERVICE" server:@"SERVER" version:@"VERSION"];
    XCTAssertEqualObjects(builtURL.absoluteString, @"https://SERVER-VERSION.devc.cloud.ogury.io/VERSION/SERVICE");
}

- (void)testBuildURLWithServiceStaging {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentStaging];
    NSURL *builtURL = [legacyBuilder buildURLWithService:@"SERVICE" server:@"SERVER" version:@"VERSION"];
    XCTAssertEqualObjects(builtURL.absoluteString, @"https://SERVER-VERSION.staging.presage.io/VERSION/SERVICE");
}

- (void)testBuildURLWithServiceProd {
    OGAEnvironmentURLLegacyBuilder *legacyBuilder = [[OGAEnvironmentURLLegacyBuilder alloc] initWith:OGAEnvironmentProd];
    NSURL *builtURL = [legacyBuilder buildURLWithService:@"SERVICE" server:@"SERVER" version:@"VERSION"];
    XCTAssertEqualObjects(builtURL.absoluteString, @"https://SERVER-VERSION.presage.io/VERSION/SERVICE");
}

@end
