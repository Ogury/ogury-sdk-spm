//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAConfigurationUtils.h"
#import "OGAReachability.h"

@interface OGAConfigurationUtilsTests : XCTestCase

@end

@implementation OGAConfigurationUtilsTests

NSString *const OGAOGAConfigurationUtilsSDKType = @"ads";
NSString *const OGAOGAConfigurationUtilsDeviceOS = @"ios";

- (void)testTimeZone {
    NSString *timeZone = [OGAConfigurationUtils timeZone];
    XCTAssertNotEqual([timeZone length], 0);
}

- (void)testCpuArchitecture {
    NSString *cpuArchitecture = [OGAConfigurationUtils cpuArchitecture];
    XCTAssertNotEqual([cpuArchitecture length], 0);
}

- (void)testScreenDensity {
    double screenDensity = [OGAConfigurationUtils screenDensity];
    XCTAssertNotEqual(screenDensity, 0);
}

- (void)testCountryCode {
    NSString *countryCode = [OGAConfigurationUtils countryCode];
    XCTAssertNotNil(countryCode);
}

- (void)testGetSDKType {
    NSString *sdkType = [OGAConfigurationUtils getSDKType];
    XCTAssertNotEqual([sdkType length], 0);
    XCTAssertEqualObjects(sdkType, OGAOGAConfigurationUtilsSDKType);
}

- (void)testGetDeviceOS {
    NSString *deviceOS = [OGAConfigurationUtils getDeviceOS];
    XCTAssertNotEqual([deviceOS length], 0);
    XCTAssertEqualObjects(deviceOS, OGAOGAConfigurationUtilsDeviceOS);
}

- (void)testIsConnectedToInternet {
    BOOL isConnectedToInternet = [OGAConfigurationUtils isConnectedToInternet];
    NetworkStatus networkStatus = [[OGAReachability reachabilityForInternetConnection] currentReachabilityStatus];
    BOOL isReachable = networkStatus != NotReachable;
    XCTAssertEqual(isConnectedToInternet, isReachable);
}

- (void)testCurrentNetwork {
    NSString *currentNetwork = [OGAConfigurationUtils currentNetwork];
    XCTAssertNotEqual([currentNetwork length], 0);
}

- (void)testCurrentCellularNetwork {
    NSString *currentCellularNetwork = [OGAConfigurationUtils currentCellularNetwork];
    XCTAssertNotEqual([currentCellularNetwork length], 0);
}

- (void)test_ShouldReturnMarketingVersion {
    NSString *marketingVersion = [OGAConfigurationUtils getAppMarketingVersion];

    XCTAssertTrue(marketingVersion.length > 0);
}

- (void)test_ShouldReturnBuildVersion {
    NSString *buildVersion = [OGAConfigurationUtils getAppBuildVersion];

    XCTAssertTrue(buildVersion.length > 0);
}

- (void)test_ShouldReturnBuildIdentifier {
    NSString *buildId = [OGAConfigurationUtils getAppBundleIdentifer];
    XCTAssertEqualObjects(buildId, @"com.ogury.OguryAdsTests");
}

@end
