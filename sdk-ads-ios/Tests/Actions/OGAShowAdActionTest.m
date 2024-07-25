//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAShowAdAction.h"
#import "OGAAdContainer+Testing.h"

@interface OGAShowAdActionTest : XCTestCase

@end

@implementation OGAShowAdActionTest

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAShowAdAction *action = [[OGAShowAdAction alloc] init];

    XCTAssertNotNil(action);
}

- (void)testShouldPerformActionOnDisplayer {
    OGAShowAdAction *action = [[OGAShowAdAction alloc] init];

    OGAAdContainer *mockContainer = OCMClassMock([OGAAdContainer class]);

    [action performAction:mockContainer error:nil];

    OCMVerify([mockContainer performAction:action.name error:nil]);
}

@end
