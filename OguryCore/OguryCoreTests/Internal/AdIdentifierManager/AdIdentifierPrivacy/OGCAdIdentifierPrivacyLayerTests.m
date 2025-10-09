//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGCAdIdentifierPrivacyLayer.h"
#import "OGCASIdentifierManagerMock.h"

@interface OGCAdIdentifierPrivacyLayerTests : XCTestCase

@end

@interface OGCAdIdentifierPrivacyLayer()

- (id)initAdIdentifierManager:(ASIdentifierManager *)identifierManager;

@end

@implementation OGCAdIdentifierPrivacyLayerTests

- (void)testAdIdentifier {
    OGCASIdentifierManagerMock *identifierManagerMock = [[OGCASIdentifierManagerMock alloc] init];
    identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:@"00000000-1111-3333-1598-000000000000"];
    OGCAdIdentifierPrivacyLayer *privacyLayer = [[OGCAdIdentifierPrivacyLayer alloc] initAdIdentifierManager:identifierManagerMock];
    NSString *adIdentifier = [privacyLayer adIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertEqualObjects(adIdentifier, @"00000000-1111-3333-1598-000000000000");
}

- (void)testGenerateInstanceToken {
    OGCAdIdentifierPrivacyLayer *privacyLayer = [[OGCAdIdentifierPrivacyLayer alloc] init];
    NSString *generatedInstanceToken1 = [privacyLayer generateToken];
    XCTAssertEqual(generatedInstanceToken1.length, 36);
    NSString *generatedInstanceToken2 = [privacyLayer generateToken];
    XCTAssertEqual(generatedInstanceToken2.length, 36);
    NSString *generatedInstanceToken3 = [privacyLayer generateToken];
    XCTAssertEqual(generatedInstanceToken3.length, 36);
    XCTAssertFalse([generatedInstanceToken1 isEqualToString:generatedInstanceToken2]);
    XCTAssertFalse([generatedInstanceToken3 isEqualToString:generatedInstanceToken2]);
    XCTAssertFalse([generatedInstanceToken1 isEqualToString:generatedInstanceToken3]);
}

- (void)testIsEmptyIDFA {
    OGCASIdentifierManagerMock *identifierManagerMock = [[OGCASIdentifierManagerMock alloc] init];
    identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"];
    OGCAdIdentifierPrivacyLayer *privacyLayer = [[OGCAdIdentifierPrivacyLayer alloc] initAdIdentifierManager:identifierManagerMock];
    NSString *adIdentifier = [privacyLayer adIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertTrue([privacyLayer isEmptyIDFA]);
    identifierManagerMock.customIDFA = [[NSUUID alloc] initWithUUIDString:@"00000000-1111-3333-1598-000000000000"];
    adIdentifier = [privacyLayer adIdentifier];
    XCTAssertEqual(adIdentifier.length, 36);
    XCTAssertFalse([privacyLayer isEmptyIDFA]);
}

@end

