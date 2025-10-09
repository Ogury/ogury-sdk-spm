//
//  OguryErrorOGWWrapper.m
//

#import <XCTest/XCTest.h>
#import "OguryError+OGWWrapper.h"
#import "OGWErrorMessage.h"

@interface OguryErrorOGWWrapperTests : XCTestCase

@end

@implementation OguryErrorOGWWrapperTests

- (void)testCreateModuleFailedToStartError {
    NSString *longMessage = @"long message";
    OguryError *errorFailedModuleStart = [OguryError createModuleFailedToStartError:longMessage];
    XCTAssertEqual(errorFailedModuleStart.code, 1001);
    XCTAssertEqualObjects(errorFailedModuleStart.localizedDescription, longMessage);
}

- (void)testCreateModuleMissingError {
    OguryError *errorFailedModuleStart = [OguryError createModuleMissingError];
    XCTAssertEqual(errorFailedModuleStart.code, 1000);
    XCTAssertEqual(errorFailedModuleStart.localizedDescription, OguryStartErrorCodeModuleMissingDescription);
}

@end
