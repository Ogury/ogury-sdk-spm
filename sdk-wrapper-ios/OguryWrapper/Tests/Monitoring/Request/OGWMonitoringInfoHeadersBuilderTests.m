//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "OGWMonitoringInfoHeadersBuilder.h"

NSString * const OGWMonitoringInfoHeadersBuilderTestsAssetKey = @"asset-key";
NSString * const OGWMonitoringInfoHeadersBuilderTestsPackageName = @"com.example";

extern NSString * const OGWMonitoringInfoHeadersAssetKeyHeader;
extern NSString * const OGWMonitoringInfoHeadersPackageNameHeader;

@interface OGWMonitoringInfoHeadersBuilder (Testing)

- (instancetype)initWithMainBundle:(NSBundle *)mainBundle;

@end

@interface OGWMonitoringInfoHeadersBuilderTests : XCTestCase

@property (nonatomic, strong) NSBundle *mainBundle;

@property (nonatomic, strong) OGWMonitoringInfoHeadersBuilder *builder;

@end

@implementation OGWMonitoringInfoHeadersBuilderTests

- (void)setUp {
    self.mainBundle = OCMClassMock([NSBundle class]);

    self.builder = [[OGWMonitoringInfoHeadersBuilder alloc] initWithMainBundle:self.mainBundle];
}

#pragma mark - Methods

- (void)testBuild {
    OGWMonitoringInfo *monitoringInfo = OCMClassMock([OGWMonitoringInfo class]);
    OCMStub(monitoringInfo.assetKey).andReturn(OGWMonitoringInfoHeadersBuilderTestsAssetKey);
    OCMStub(self.mainBundle.bundleIdentifier).andReturn(OGWMonitoringInfoHeadersBuilderTestsPackageName);

    NSDictionary<NSString *, NSString *> *headers = [self.builder build:monitoringInfo];

    XCTAssertEqualObjects(headers[OGWMonitoringInfoHeadersAssetKeyHeader], OGWMonitoringInfoHeadersBuilderTestsAssetKey);
    XCTAssertEqualObjects(headers[OGWMonitoringInfoHeadersPackageNameHeader], OGWMonitoringInfoHeadersBuilderTestsPackageName);
}

@end
