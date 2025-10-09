//
//  Copyright © 10/11/2020-present Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OguryNetworkClientError.h"
#import "OGCConstants.h"

@interface OguryNetworkClientErrorTests : XCTestCase

@end

@implementation OguryNetworkClientErrorTests

#pragma mark - Methods

- (void)testShouldInstantiateWithUnknownErrorType {
    NSError *error = [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeUnknown];

    XCTAssertEqual(error.domain, OguryNetworkClientErrorDomain);
    XCTAssertEqual(error.code, 100);
    XCTAssertTrue([error.localizedDescription isEqualToString: [OguryNetworkClientErrorLocalizedDescription stringByAppendingString: OguryNetworkClientErrorTypeUnknownLocalizedDescription]]);
    XCTAssertTrue([error.localizedRecoverySuggestion isEqualToString: OguryNetworkClientErrorTypeUnknowLocalizedRecoverySuggestion]);
}

- (void)testShouldInstantiateWithInvalidURLErrorType {
    NSError *error = [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeInvalidURL];

    XCTAssertEqual(error.domain, OguryNetworkClientErrorDomain);
    XCTAssertEqual(error.code, 101);
    XCTAssertTrue([error.localizedDescription isEqualToString: [OguryNetworkClientErrorLocalizedDescription stringByAppendingString: OguryNetworkClientErrorTypeInvalidURLLocalizedDescription]]);
    XCTAssertTrue([error.localizedRecoverySuggestion isEqualToString: OguryNetworkClientErrorTypeInvalidURLLocaliedRecoverySuggestion]);
}

- (void)testShouldInstantiateWithEmptyResponseErrorType {
    NSError *error = [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeEmptyResponse];

    XCTAssertEqual(error.domain, OguryNetworkClientErrorDomain);
    XCTAssertEqual(error.code, 102);
    XCTAssertTrue([error.localizedDescription isEqualToString: [OguryNetworkClientErrorLocalizedDescription stringByAppendingString: OguryNetworkClientErrorTypeEmptyResponseLocalizedDescription]]);
    XCTAssertTrue([error.localizedRecoverySuggestion isEqualToString: OguryNetworkClientErrorTypeEmptyResponseLocalizedRecoverySuggestion]);
}

- (void)testShouldInstantiateWithClientErrorType {
    NSError *error = [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeClientError];

    XCTAssertEqual(error.domain, OguryNetworkClientErrorDomain);
    XCTAssertEqual(error.code, 103);
    XCTAssertTrue([error.localizedDescription isEqualToString: [OguryNetworkClientErrorLocalizedDescription stringByAppendingString: OguryNetworkClientErrorTypeClientErrorLocalizedDescription]]);
    XCTAssertTrue([error.localizedRecoverySuggestion isEqualToString: OguryNetworkClientErrorTypeClientErrorLocalizedRecoverySuggestion]);
}

- (void)testShouldInstantiateWithServerErrorType {
    NSError *error = [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeServerError];

    XCTAssertEqual(error.domain, OguryNetworkClientErrorDomain);
    XCTAssertEqual(error.code, 104);
    XCTAssertTrue([error.localizedDescription isEqualToString: [OguryNetworkClientErrorLocalizedDescription stringByAppendingString: OguryNetworkClientErrorTypeServerErrorLocalizedDescription]]);
    XCTAssertTrue([error.localizedRecoverySuggestion isEqualToString: OguryNetworkClientErrorTypeServerErrorLocalizedRecoverySuggestion]);
}

- (void)testShouldInstantiateWithNotYetImplementedErrorType {
    NSError *error = [OguryNetworkClientError errorWithType:OguryNetworkClientErrorTypeNotYetImplemented];

    XCTAssertEqual(error.domain, OguryNetworkClientErrorDomain);
    XCTAssertEqual(error.code, 199);
    XCTAssertTrue([error.localizedDescription isEqualToString: [OguryNetworkClientErrorLocalizedDescription stringByAppendingString: OguryNetworkClientErrorTypeNotYetImplementedLocalizedDescription]]);
    XCTAssertTrue([error.localizedRecoverySuggestion isEqualToString: OguryNetworkClientErrorTypeNotYetImplementedLocalizedRecoverySuggestion]);
}

@end
