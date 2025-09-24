//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OguryError+internal.h"
#import "OGCConstants.h"

@interface OguryErrorTests : XCTestCase

@end

@implementation OguryErrorTests

- (void)testCreateOguryErrorWithCode {
    OguryError *myOguryError = [OguryError createOguryErrorWithCode:OguryCoreErrorTypeNoInternetConnection];

    XCTAssertEqual(myOguryError.code, 0);
    XCTAssertEqualObjects(myOguryError.localizedDescription, @"");
    XCTAssertEqualObjects(myOguryError.domain, OguryErrorCoreDomain);
}

- (void)testCreateOguryErrorWithCodeAndLocalizedDescription {
    OguryError *myOguryError = [OguryError createOguryErrorWithCode:OguryCoreErrorTypeNoInternetConnection localizedDescription:OguryCoreErrorTypeNoInternetConnectionDesc];

    XCTAssertEqual(myOguryError.code, 0);
    XCTAssertEqualObjects(myOguryError.localizedDescription, OguryCoreErrorTypeNoInternetConnectionDesc);
    XCTAssertEqualObjects(myOguryError.domain, OguryErrorCoreDomain);
}

- (void)testCreateOguryErrorWithCodeAndInvalidLocalizedDescription {
    OguryError *myOguryError = [OguryError createOguryErrorWithCode:OguryCoreErrorTypeNoInternetConnection localizedDescription:nil];

    XCTAssertEqual(myOguryError.code, 0);
    XCTAssertEqualObjects(myOguryError.localizedDescription, @"");
    XCTAssertEqualObjects(myOguryError.domain, OguryErrorCoreDomain);
}

- (void)testCreateOguryErrorWithCodeAndLocalizedDescriptionAndResolution {
    OguryError *myOguryError = [OguryError createOguryErrorWithCode:OguryCoreErrorTypeNoInternetConnection
                                               localizedDescription:OguryCoreErrorTypeNoInternetConnectionDesc
                                        localizedRecoverySuggestion:OguryCoreErrorTypeNoInternetConnectionRecoverySugg];

    XCTAssertEqual(myOguryError.code, 0);
    XCTAssertEqualObjects(myOguryError.localizedDescription, OguryCoreErrorTypeNoInternetConnectionDesc);
    XCTAssertEqualObjects(myOguryError.localizedRecoverySuggestion, OguryCoreErrorTypeNoInternetConnectionRecoverySugg);
    XCTAssertEqualObjects(myOguryError.domain, OguryErrorCoreDomain);
}

- (void)testGetOguryErrorDomain {
    NSString *domain = [OguryError getOguryErrorDomain];

    XCTAssertEqualObjects(domain, OguryErrorCoreDomain);
}

- (void)testCreateNoInternetConnectionError {
    OguryError *error = [OguryError noInternetConnectionError];

    XCTAssertEqual(error.code, 0);
    XCTAssertEqualObjects(error.localizedDescription, OguryCoreErrorTypeNoInternetConnectionDesc);
    XCTAssertEqualObjects(error.localizedRecoverySuggestion, OguryCoreErrorTypeNoInternetConnectionRecoverySugg);
    XCTAssertEqualObjects(error.domain, OguryErrorCoreDomain);
}

@end
