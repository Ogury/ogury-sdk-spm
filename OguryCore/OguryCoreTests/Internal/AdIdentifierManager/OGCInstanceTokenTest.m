//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGCNSProcessInfoMock.h"
#import "OGCInstanceToken.h"

static NSString * const instanceTokenString = @"00000000-1111-3333-1598-000000000000";

@interface OGCInstanceTokenTest : XCTestCase

@end

@interface OGCInstanceToken()

@property (readwrite, strong, nullable) NSDate *expirationDate;
@property (readwrite, copy, nullable) NSString *idfaHash;
@property (readwrite, copy, nullable) NSString *salt;

- (id)initWithInstanceToken:(NSString *)instanceTokenID andProcessInfo:(NSProcessInfo *)processInfo;

@end

@implementation OGCInstanceTokenTest

- (void)testInitWithInstanceToken {
    OGCInstanceToken *instanceToken = [[OGCInstanceToken alloc] initWithInstanceToken:instanceTokenString];
    XCTAssertNotNil(instanceToken);
    XCTAssertEqualObjects([instanceToken instanceTokenID], instanceTokenString);
}

- (void)testRequireIOS14Migration {
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    OGCInstanceToken *instanceToken = [[OGCInstanceToken alloc] initWithInstanceToken:instanceTokenString andProcessInfo:processInfo];
    XCTAssertFalse([instanceToken requireIOS14MigrationWith:processInfo]);
    [processInfo updateMajorVersion:14];
    XCTAssertTrue([instanceToken requireIOS14MigrationWith:processInfo]);
}

- (void)testUpdateIOSVersion {
    OGCNSProcessInfoMock *processInfo = [[OGCNSProcessInfoMock alloc] initWithMajorVersion:13];
    OGCInstanceToken *instanceToken = [[OGCInstanceToken alloc] initWithInstanceToken:instanceTokenString andProcessInfo:processInfo];
    XCTAssertEqual([instanceToken iosVersion], 13);
    [processInfo updateMajorVersion:14];
    XCTAssertEqual([instanceToken iosVersion], 13);
    [instanceToken updateIOSVersionWith:processInfo];
    XCTAssertEqual([instanceToken iosVersion], 14);
    [processInfo updateMajorVersion:17];
    XCTAssertEqual([instanceToken iosVersion], 14);
    [instanceToken updateIOSVersionWith:processInfo];
    XCTAssertEqual([instanceToken iosVersion], 17);
}

- (void)testSupportsSecureCoding {
    XCTAssertTrue([OGCInstanceToken supportsSecureCoding]);
}


@end
