//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAUnloadAdAction.h"
#import "OGAAdContainer+Testing.h"

@interface OGAUnloadAdActionTest : XCTestCase

@end

@implementation OGAUnloadAdActionTest

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAUnloadAdAction *action = [[OGAUnloadAdAction alloc] init];

    XCTAssertNotNil(action);
}

- (void)testShouldPerformActionOnDisplayer {
    OGAUnloadAdAction *action = [[OGAUnloadAdAction alloc] init];

    OGAAdContainer *mockContainer = OCMClassMock([OGAAdContainer class]);

    [action performAction:mockContainer error:nil];

    OCMVerify([mockContainer performAction:action.name error:nil]);
}

@end
