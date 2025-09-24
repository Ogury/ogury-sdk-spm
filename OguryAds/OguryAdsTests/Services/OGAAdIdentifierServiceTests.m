//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OGAAdIdentifierService.h"
#import "OGAAssetKeyManager.h"

@interface OGAAdIdentifierServiceTests : XCTestCase

@end

@implementation OGAAdIdentifierServiceTests

static NSString *const OGAEmptyIDFA = @"00000000-0000-0000-0000-000000000000";

- (void)testGetAdIdentifier {
    NSString *idfa = [OGAAdIdentifierService getAdIdentifier];
    XCTAssertEqual(idfa.length, 36);
}

- (void)testGetInstanceToken {
    NSString *idfa = [OGAAdIdentifierService getInstanceToken];
    XCTAssertEqual(idfa.length, 36);
}

- (void)testIsAdOptin {
    if ([[OGAAdIdentifierService getAdIdentifier] isEqualToString:OGAEmptyIDFA]) {
        XCTAssertFalse([OGAAdIdentifierService isAdOptin]);
    } else {
        XCTAssertTrue([OGAAdIdentifierService isAdOptin]);
    }
}

- (void)testUpdateInstanceToken;
{
    [OGAAdIdentifierService updateInstanceToken];
    NSString *idfa = [OGAAdIdentifierService getAdIdentifier];
    XCTAssertEqual(idfa.length, 36);
    NSString *instanceToken = [OGAAdIdentifierService getInstanceToken];
    XCTAssertEqual(instanceToken.length, 36);
}

- (void)testGetUserAgent {
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@/%@", OGA_SDK_VERSION, OGAAssetKeyManager.shared.assetKey, UIDevice.currentDevice.systemVersion];
    XCTAssertEqualObjects([OGAAdIdentifierService getUserAgent], userAgent);
}

@end
