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
    OguryError *errorFailedModuleStart = [OguryError createFailedStartingOguryModuleError];
    XCTAssertEqual(errorFailedModuleStart.code, 1000);
    XCTAssertEqual(errorFailedModuleStart.localizedDescription, OGWErrorFailedStartingOguryModuleMessage);
}

- (void)testCreateNoSDKModuleFoundError {
    OguryError *errorFailedModuleStart = [OguryError createNoSDKModuleFoundError];
    XCTAssertEqual(errorFailedModuleStart.code, 1001);
    XCTAssertEqual(errorFailedModuleStart.localizedDescription, OGWErrorNoSdkModuleFoundMessage);
}

@end
