//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdDisplayerUserCloseStoreKitInformation.h"
#import "OguryError+utility.h"

@interface OGAAdDisplayerUserCloseStoreKitInformationTests : XCTestCase

@end

@implementation OGAAdDisplayerUserCloseStoreKitInformationTests

- (void)testShouldInstantiate {
    OGAAdDisplayerUserCloseStoreKitInformation *information = [[OGAAdDisplayerUserCloseStoreKitInformation alloc] init];

    XCTAssertNotNil(information);
    XCTAssertNil(information.errorCode);
}

- (void)testShouldInstantiateError {
    OGAAdDisplayerUserCloseStoreKitInformation *information = [[OGAAdDisplayerUserCloseStoreKitInformation alloc] initWithErrorCode:@(5)];

    XCTAssertNotNil(information);
    XCTAssertEqual(information.errorCode, @(5));
}

- (void)testShouldReturnJavascriptCommand {
    OGAAdDisplayerUserCloseStoreKitInformation *information = [[OGAAdDisplayerUserCloseStoreKitInformation alloc] init];

    NSString *command = [information toJavascriptCommand];

    XCTAssertTrue([command isEqualToString:@"ogySdkMraidGateway.ogyCloseStoreKit()"]);
}

- (void)testShouldReturnJavascriptCommandError {
    OGAAdDisplayerUserCloseStoreKitInformation *information = [[OGAAdDisplayerUserCloseStoreKitInformation alloc] initWithErrorCode:@(5)];

    NSString *command = [information toJavascriptCommand];

    XCTAssertTrue([command isEqualToString:@"ogySdkMraidGateway.ogyCloseStoreKit({error_code:5})"]);
}

@end
