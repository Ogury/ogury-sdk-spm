//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <OguryCore/OGCInternal.h>

#import "OGWMonitoringInfoFetcher.h"
#import "OGWModules.h"
#import "OguryConfigurationPrivate.h"

extern NSString * const OGWMonitoringInfoFetcherAssetKeyKey;
extern NSString * const OGWMonitoringInfoFetcherDeviceOSKey;
extern NSString * const OGWMonitoringInfoFetcherAppVersionKey;
extern NSString * const OGWMonitoringInfoFetcherSdkVersionKey;
extern NSString * const OGWMonitoringInfoFetcherCoreVersionKey;
extern NSString * const OGWMonitoringInfoFetcherAdsVersionKey;
extern NSString * const OGWMonitoringInfoFetcherChoiceManagerVersionKey;

extern NSString * const OGWMonitoringInfoFetcherDeviceOSValue;

NSString * const OGWMonitoringInfoFetcherTestsAssetKey = @"asset-key";
NSString * const OGWMonitoringInfoFetcherTestsVersion = @"1.0.0";
NSString * const OGWMonitoringInfoFetcherTestsValue = @"test-value";
NSString * const OGWMonitoringInfoFetcherTestsKey = @"test-key";

@interface OGWMonitoringInfoFetcher (Testing)

- (instancetype)initWithModules:(OGWModules *)modules
                   internalCore:(OGCInternal *)internalCore
                     mainBundle:(NSBundle *)mainBundle;

- (void)populateAssetKey:(OGWMonitoringInfo *)monitoringInfo configuration:(OguryConfiguration *)configuration;

- (void)populateDeviceOS:(OGWMonitoringInfo *)monitoringInfo;

- (void)populateAppVersion:(OGWMonitoringInfo *)monitoringInfo;

- (void)populateSdkVersion:(OGWMonitoringInfo *)monitoringInfo;

- (void)populateCoreVersion:(OGWMonitoringInfo *)monitoringInfo;

- (void)populateAdsVersion:(OGWMonitoringInfo *)monitoringInfo;

- (void)populateChoiceManagerVersion:(OGWMonitoringInfo *)monitoringInfo;

@end

@interface OGWMonitoringInfoFetcherTests : XCTestCase

@property (nonatomic, strong) OGWModules *modules;
@property (nonatomic, strong) OGCInternal *internalCore;
@property (nonatomic, strong) NSBundle *mainBundle;

@property (nonatomic, strong) OGWMonitoringInfoFetcher *populator;

@end

@implementation OGWMonitoringInfoFetcherTests

- (void)setUp {
    self.modules = OCMClassMock([OGWModules class]);
    self.internalCore = OCMClassMock([OGCInternal class]);
    self.mainBundle = OCMClassMock([NSBundle class]);

    self.populator = [[OGWMonitoringInfoFetcher alloc] initWithModules:self.modules
                                                                             internalCore:self.internalCore
                                                                               mainBundle:self.mainBundle];
}

#pragma mark - Methods

- (void)testFetch {
    id mock = OCMPartialMock(self.populator);
    OguryConfiguration *configuration = OCMClassMock([OguryConfiguration class]);
    OGWMonitoringInfo *configurationMonitoringInfo = [[OGWMonitoringInfo alloc] init];
    [configurationMonitoringInfo putValue:OGWMonitoringInfoFetcherTestsValue key:OGWMonitoringInfoFetcherTestsKey];
    OCMStub(configuration.monitoringInfo).andReturn(configurationMonitoringInfo);

    OCMExpect([mock populateAssetKey:[OCMArg any] configuration:configuration]);
    OCMExpect([mock populateDeviceOS:[OCMArg any]]);
    OCMExpect([mock populateAppVersion:[OCMArg any]]);
    OCMExpect([mock populateSdkVersion:[OCMArg any]]);
    OCMExpect([mock populateCoreVersion:[OCMArg any]]);
    OCMExpect([mock populateAdsVersion:[OCMArg any]]);
    OCMExpect([mock populateChoiceManagerVersion:[OCMArg any]]);

    OGWMonitoringInfo *monitoringInfo = [mock populate:configuration];

    OCMVerifyAll(mock);
    XCTAssertTrue([monitoringInfo containsAll:configurationMonitoringInfo]);
}

- (void)testFetchAssetKey {
    OguryConfiguration *configuration = OCMClassMock([OguryConfiguration class]);
    OCMStub(configuration.assetKey).andReturn(OGWMonitoringInfoFetcherTestsAssetKey);
    OGWMonitoringInfo *monitoringInfo = [[OGWMonitoringInfo alloc] init];

    [self.populator populateAssetKey:monitoringInfo configuration:configuration];

    XCTAssertEqualObjects([monitoringInfo getValueForKey:OGWMonitoringInfoFetcherAssetKeyKey], OGWMonitoringInfoFetcherTestsAssetKey);
}

- (void)testFetchDeviceOS {
    OGWMonitoringInfo *monitoringInfo = [[OGWMonitoringInfo alloc] init];

    [self.populator populateDeviceOS:monitoringInfo];

    XCTAssertEqualObjects([monitoringInfo getValueForKey:OGWMonitoringInfoFetcherDeviceOSKey], OGWMonitoringInfoFetcherDeviceOSValue);
}

- (void)testFetchAppVersion {
    OGWMonitoringInfo *monitoringInfo = [[OGWMonitoringInfo alloc] init];
    OCMStub(self.mainBundle.infoDictionary).andReturn(@{
            @"CFBundleVersion": OGWMonitoringInfoFetcherTestsVersion
    });

    [self.populator populateAppVersion:monitoringInfo];

    XCTAssertEqualObjects([monitoringInfo getValueForKey:OGWMonitoringInfoFetcherAppVersionKey], OGWMonitoringInfoFetcherTestsVersion);
}

- (void)testFetchSdkVersion {
    OGWMonitoringInfo *monitoringInfo = [[OGWMonitoringInfo alloc] init];

    [self.populator populateSdkVersion:monitoringInfo];

    XCTAssertEqualObjects([monitoringInfo getValueForKey:OGWMonitoringInfoFetcherSdkVersionKey], SDK_VERSION);
}

- (void)testFetchCoreVersion {
    OGWModule *module = OCMClassMock([OGWModule class]);
    OCMStub(module.isPresent).andReturn(YES);
    OCMStub([module getVersion]).andReturn(OGWMonitoringInfoFetcherTestsVersion);
    OCMStub(self.modules.coreModule).andReturn(module);
    OGWMonitoringInfo *monitoringInfo = [[OGWMonitoringInfo alloc] init];

    [self.populator populateCoreVersion:monitoringInfo];

    XCTAssertEqualObjects([monitoringInfo getValueForKey:OGWMonitoringInfoFetcherCoreVersionKey], OGWMonitoringInfoFetcherTestsVersion);
}

- (void)testFetchAdsVersion {
    OGWModule *module = OCMClassMock([OGWModule class]);
    OCMStub(module.isPresent).andReturn(YES);
    OCMStub([module getVersion]).andReturn(OGWMonitoringInfoFetcherTestsVersion);
    OCMStub(self.modules.adsModule).andReturn(module);
    OGWMonitoringInfo *monitoringInfo = [[OGWMonitoringInfo alloc] init];

    [self.populator populateAdsVersion:monitoringInfo];

    XCTAssertEqualObjects([monitoringInfo getValueForKey:OGWMonitoringInfoFetcherAdsVersionKey], OGWMonitoringInfoFetcherTestsVersion);
}

- (void)testFetchChoiceManagerVersion {
    OGWModule *module = OCMClassMock([OGWModule class]);
    OCMStub(module.isPresent).andReturn(YES);
    OCMStub([module getVersion]).andReturn(OGWMonitoringInfoFetcherTestsVersion);
    OCMStub(self.modules.choiceManagerModule).andReturn(module);
    OGWMonitoringInfo *monitoringInfo = [[OGWMonitoringInfo alloc] init];

    [self.populator populateChoiceManagerVersion:monitoringInfo];

    XCTAssertEqualObjects([monitoringInfo getValueForKey:OGWMonitoringInfoFetcherChoiceManagerVersionKey], OGWMonitoringInfoFetcherTestsVersion);
}

@end
