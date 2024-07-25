//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAMraidDownloadHeaderBuilder.h"

@interface OGAProfigHeaderBuilderTests : XCTestCase

@end

@implementation OGAProfigHeaderBuilderTests

#pragma mark - Constants

static NSString *const OGAProfigHeaderBuilderTestUser = @"User";
static NSString *const OGAProfigHeaderBuilderTestInstanceToken = @"Instance-Token";
static NSString *const OGAProfigHeaderBuilderTestDeviceOS = @"Device-OS";
static NSString *const OGAProfigHeaderBuilderTestUserAgent = @"User-Agent";
static NSString *const OGAProfigHeaderBuilderTestPackageNAme = @"Package-Name";
static NSString *const OGAProfigHeaderBuilderTestsSDKVersionType = @"sdk-Version-Type";
static NSString *const OGAProfigHeaderBuilderTestsSDKVersion = @"sdk-Version";
static NSString *const OGAProfigHeaderBuilderTestsSDKType = @"Sdk-Type";
static NSString *const OGAProfigHeaderBuilderTestsMediation = @"Mediation";
static NSString *const OGAProfigHeaderBuilderTestsFramework = @"Framework";
static NSString *const OGAProfigHeaderBuilderTestsTimeZone = @"Timezone";
static NSString *const OGAProfigHeaderBuilderTestsConnectivity = @"Connectivity";
static NSString *const OGAProfigHeaderBuilderTestsApiKey = @"Api-Key";

#pragma mark - Methods

- (void)testShouldBuildWithProfigHeaders {
    NSDictionary *dictionnary = [OGAMraidDownloadHeaderBuilder build];

    XCTAssertNotNil(dictionnary);
    XCTAssertEqual([[dictionnary allKeys] count], 12);
    XCTAssertNotNil([dictionnary valueForKey:OGAProfigHeaderBuilderTestInstanceToken]);
    XCTAssertNotNil([dictionnary valueForKey:OGAProfigHeaderBuilderTestDeviceOS]);
    XCTAssertNotNil([dictionnary valueForKey:OGAProfigHeaderBuilderTestUserAgent]);
    XCTAssertNotNil([dictionnary valueForKey:OGAProfigHeaderBuilderTestPackageNAme]);
    XCTAssertNotNil([dictionnary valueForKey:OGAProfigHeaderBuilderTestsSDKVersionType]);
    XCTAssertNotNil([dictionnary valueForKey:OGAProfigHeaderBuilderTestsSDKVersion]);
    XCTAssertNotNil([dictionnary valueForKey:OGAProfigHeaderBuilderTestsSDKType]);
    XCTAssertNotNil([dictionnary valueForKey:OGAProfigHeaderBuilderTestsMediation]);
    XCTAssertNotNil([dictionnary valueForKey:OGAProfigHeaderBuilderTestsFramework]);
    XCTAssertNotNil([dictionnary valueForKey:OGAProfigHeaderBuilderTestsTimeZone]);
    XCTAssertNotNil([dictionnary valueForKey:OGAProfigHeaderBuilderTestsConnectivity]);
    XCTAssertNotNil([dictionnary valueForKey:OGAProfigHeaderBuilderTestsApiKey]);
}

@end
