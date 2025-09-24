//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAForceCloseAdAction.h"
#import "OGAAdContainer.h"

@interface OGAForceCloseAdActionTests : XCTestCase

@end

@implementation OGAForceCloseAdActionTests

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAForceCloseAdAction *action = [[OGAForceCloseAdAction alloc] init];

    XCTAssertNotNil(action);
}

- (void)testShouldPerformActionOnDisplayer {
    OGAForceCloseAdAction *action = [[OGAForceCloseAdAction alloc] init];

    OGAAdContainer *mockContainer = OCMClassMock(OGAAdContainer.self);

    [action performAction:mockContainer error:nil];

    OCMVerify([mockContainer performAction:action.name error:nil]);
}

@end
