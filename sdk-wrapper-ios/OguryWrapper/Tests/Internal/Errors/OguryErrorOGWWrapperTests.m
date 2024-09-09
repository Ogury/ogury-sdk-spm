//
//  OguryErrorOGWWrapper.m
//

#import <XCTest/XCTest.h>
#import "OguryError+OGWWrapper.h"
#import "OGWErrorMessage.h"

@interface OguryErrorOGWWrapperTests : XCTestCase

@end

@implementation OguryErrorOGWWrapperTests

- (void)testCreateFailedStartingOguryModuleError {
    NSString *longMessage = @"long message";
    OguryError *errorFailedModuleStart = [OguryError createFailedStartingOguryModuleError:longMessage];
    XCTAssertEqual(errorFailedModuleStart.code, 1000);
    XCTAssertEqualObjects(errorFailedModuleStart.localizedDescription, longMessage);
}

- (void)testCreateNoSDKModuleFoundError {
    OguryError *errorFailedModuleStart = [OguryError createNoSDKModuleFoundError];
    XCTAssertEqual(errorFailedModuleStart.code, 1001);
    XCTAssertEqual(errorFailedModuleStart.localizedDescription, OGWErrorNoSdkModuleFoundMessage);
}

@end
