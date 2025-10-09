//
//  OGAMediationTests.m
//  OguryAdsTests
//
//  Created by Jerome TONNELIER on 23/05/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OguryMediation.h"

@interface OGAMediationTests : XCTestCase

@end

@implementation OGAMediationTests

- (void)testWhenSupplyingInformationsThenTheyAreSaved {
    OguryMediation *mediation = [[OguryMediation alloc] initWithName:@"name" version:@"version"];
    XCTAssertEqualObjects(mediation.name, @"name");
    XCTAssertEqualObjects(mediation.version, @"version");
}

- (void)testWhenMediationIsArchivedThenItCanUnarchived {
    OguryMediation *mediation = [[OguryMediation alloc] initWithName:@"name" version:@"version"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mediation];
    XCTAssertNotNil(data);
    OguryMediation *unarchivedMediation = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertNotNil(unarchivedMediation);
    XCTAssertEqualObjects(mediation.name, unarchivedMediation.name);
    XCTAssertEqualObjects(mediation.version, unarchivedMediation.version);
}

- (void)testWhenCopyingObjectThenItGivesValidObject {
    OguryMediation *mediation = [[OguryMediation alloc] initWithName:@"name" version:@"version"];
    OguryMediation *mediationCopy = [mediation copy];
    XCTAssertEqualObjects(mediation.name, mediationCopy.name);
    XCTAssertEqualObjects(mediation.version, mediationCopy.version);
}

@end
