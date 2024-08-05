//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAConfigurationUtils+Profig.h"
#import "OGAProfigFullResponse+Parser.h"
#import <OCMock/OCMock.h>

@interface OGAConfigurationUtilsProfigTests : XCTestCase

@property(atomic, strong) NSURLResponse *urlResponse;

@end

@implementation OGAConfigurationUtilsProfigTests

- (void)setUp {
    self.urlResponse = OCMClassMock([NSURLResponse class]);
}

- (void)testProfigParams {
    NSMutableDictionary *profigParam = [OGAConfigurationUtils profigParams];
    XCTAssertNotNil(profigParam);
    XCTAssertEqual([[profigParam allKeys] count], 3);
    XCTAssertNotNil(profigParam[@"device"]);
    XCTAssertNotNil(profigParam[@"device"][@"os"]);
    XCTAssertNotNil(profigParam[@"device"][@"os_version"]);
    XCTAssertNotNil(profigParam[@"app"]);
    XCTAssertNotNil(profigParam[@"app"][@"bundle_id"]);
    XCTAssertNotNil(profigParam[@"app"][@"asset_type"]);
    XCTAssertNotNil(profigParam[@"app"][@"version"]);
    XCTAssertNotNil(profigParam[@"sdk"]);
    XCTAssertNotNil(profigParam[@"sdk"][@"module_version"]);
}

- (void)testErrorForServerProfigError {
    NSError *error = [OGAConfigurationUtils errorForOGAProfigError:OGAProfigExternalErrorNoInternet];
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, @"OguryAds");
    XCTAssertEqual(error.code, OGAProfigExternalErrorNoInternet);
    NSDictionary *userInfo = error.userInfo;
    XCTAssertNotNil(userInfo);
    XCTAssertEqual([[userInfo allKeys] count], 1);
    XCTAssertNotNil(userInfo[NSLocalizedDescriptionKey]);
    XCTAssertEqualObjects(userInfo[NSLocalizedDescriptionKey], @"No Internet Connection.");

    error = [OGAConfigurationUtils errorForOGAProfigError:OGAProfigExternalErrorAlreadyLoading];
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, @"OguryAds");
    XCTAssertEqual(error.code, OGAProfigExternalErrorAlreadyLoading);
    userInfo = error.userInfo;
    XCTAssertNotNil(userInfo);
    XCTAssertEqual([[userInfo allKeys] count], 1);
    XCTAssertNotNil(userInfo[NSLocalizedDescriptionKey]);
    XCTAssertEqualObjects(userInfo[NSLocalizedDescriptionKey], @"Ogury Ads Setup already loading.");

    error = [OGAConfigurationUtils errorForOGAProfigError:OGAProfigExternalErrorSetupFailed];
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, @"OguryAds");
    XCTAssertEqual(error.code, OGAProfigExternalErrorSetupFailed);
    userInfo = error.userInfo;
    XCTAssertNotNil(userInfo);
    XCTAssertEqual([[userInfo allKeys] count], 1);
    XCTAssertNotNil(userInfo[NSLocalizedDescriptionKey]);
    XCTAssertEqualObjects(userInfo[NSLocalizedDescriptionKey], @"Ogury Ads Setup Failed !");

    error = [OGAConfigurationUtils errorForOGAProfigError:100000000];
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, @"OguryAds");
    XCTAssertEqual(error.code, 100000000);
    userInfo = error.userInfo;
    XCTAssertNotNil(userInfo);
    XCTAssertEqual([[userInfo allKeys] count], 1);
    XCTAssertNotNil(userInfo[NSLocalizedDescriptionKey]);
    XCTAssertEqualObjects(userInfo[NSLocalizedDescriptionKey], @"Internal error");
}

- (void)testErrorForOGAProfigError {
    NSString *profigJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testProfigError" ofType:@"json"];
    NSData *profigJsonData = [NSData dataWithContentsOfFile:profigJson];
    OGAProfigFullResponse *profigResponse = [OGAProfigFullResponse parseProfigResponseWithData:profigJsonData urlResponse:self.urlResponse];
    NSError *error = [OGAConfigurationUtils errorForServerProfigError:profigResponse];
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, @"OguryAds");
    XCTAssertEqual(error.code, OGAProfigExternalErrorSetupFailed);
    NSDictionary *userInfo = error.userInfo;
    XCTAssertNotNil(userInfo);
    XCTAssertEqual([[userInfo allKeys] count], 1);
    XCTAssertNotNil(userInfo[NSLocalizedDescriptionKey]);
    XCTAssertEqualObjects(userInfo[NSLocalizedDescriptionKey], @"VALIDATION : missing body");
}

@end
