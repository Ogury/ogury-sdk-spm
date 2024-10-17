//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAMraidEnviromentBuilder.h"
#import "OGAAdConfiguration.h"
#import "OGAAdUnit.h"
#import <OCMock/OCMock.h>

@interface OGAMraidEnviromentBuilderTests : XCTestCase

@end

@implementation OGAMraidEnviromentBuilderTests

- (void)testbuildMraidEnvironmentRewardedAdVideo {
    NSString *type = OGAAdConfigurationAdTypeRewarded;
    NSString *rewardName = @"rewardName";
    NSString *rewardValue = @"rewardValue";
    NSString *rewardLaunch = @"rewardLaunch";

    OGAAdUnit *adUnit = OCMClassMock([OGAAdUnit class]);
    OCMStub(adUnit.type).andReturn(type);
    OCMStub(adUnit.rewardName).andReturn(rewardName);
    OCMStub(adUnit.rewardValue).andReturn(rewardValue);
    OCMStub(adUnit.rewardLaunch).andReturn(rewardLaunch);

    NSString *expectedResult = [NSString stringWithFormat:@"window.MRAID_ENV =  { version: '%@', sdk: 'Presage', sdkVersion: '%@',adUnit: { type: '%@', reward : { name: '%@', value: '%@', launch: '%@'}}};",
                                                          OGA_SDK_VERSION,
                                                          OGA_SDK_VERSION,
                                                          type,
                                                          rewardName,
                                                          rewardValue,
                                                          rewardLaunch];

    NSString *result = [OGAMraidEnviromentBuilder generateMraidEnviroment:adUnit];
    XCTAssertTrue([result isEqualToString:expectedResult]);
}

- (void)testbuildMraidEnvironmentInter {
    NSString *type = OGAAdConfigurationAdTypeInterstitial;

    OGAAdUnit *adUnit = OCMClassMock([OGAAdUnit class]);
    OCMStub(adUnit.type).andReturn(type);

    NSString *expectedResult = [NSString stringWithFormat:@"window.MRAID_ENV =  { version: '%@', sdk: 'Presage', sdkVersion: '%@'};", OGA_SDK_VERSION, OGA_SDK_VERSION];

    NSString *result = [OGAMraidEnviromentBuilder generateMraidEnviroment:adUnit];
    XCTAssertTrue([result isEqualToString:expectedResult]);
}

- (void)testbuildMraidEnvironmentBanner {
    NSString *type = OGAAdConfigurationAdTypeSmallBanner;

    OGAAdUnit *adUnit = OCMClassMock([OGAAdUnit class]);
    OCMStub(adUnit.type).andReturn(type);

    NSString *expectedResult = [NSString stringWithFormat:@"window.MRAID_ENV =  { version: '%@', sdk: 'Presage', sdkVersion: '%@'};", OGA_SDK_VERSION, OGA_SDK_VERSION];

    NSString *result = [OGAMraidEnviromentBuilder generateMraidEnviroment:adUnit];
    XCTAssertTrue([result isEqualToString:expectedResult]);
}

- (void)testbuildMraidEnvironmentMPU {
    NSString *type = OGAAdConfigurationAdTypeMPU;

    OGAAdUnit *adUnit = OCMClassMock([OGAAdUnit class]);
    OCMStub(adUnit.type).andReturn(type);

    NSString *expectedResult = [NSString stringWithFormat:@"window.MRAID_ENV =  { version: '%@', sdk: 'Presage', sdkVersion: '%@'};", OGA_SDK_VERSION, OGA_SDK_VERSION];

    NSString *result = [OGAMraidEnviromentBuilder generateMraidEnviroment:adUnit];
    XCTAssertTrue([result isEqualToString:expectedResult]);
}

- (void)testbuildMraidEnvironmentThumbnail {
    NSString *type = OGAAdConfigurationAdTypeThumbnailAd;

    OGAAdUnit *adUnit = OCMClassMock([OGAAdUnit class]);
    OCMStub(adUnit.type).andReturn(type);

    NSString *expectedResult = [NSString stringWithFormat:@"window.MRAID_ENV =  { version: '%@', sdk: 'Presage', sdkVersion: '%@'};", OGA_SDK_VERSION, OGA_SDK_VERSION];

    NSString *result = [OGAMraidEnviromentBuilder generateMraidEnviroment:adUnit];
    XCTAssertTrue([result isEqualToString:expectedResult]);
}

@end
