//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAExpandAdAction.h"
#import "OGAAdContainer.h"

@interface OGAExpandAdActionTests : XCTestCase

@end

@implementation OGAExpandAdActionTests

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAExpandAdAction *action = [[OGAExpandAdAction alloc] init];

    XCTAssertNotNil(action);
}

- (void)testShouldPerformAction {
    OGAAdContainer *adContainer = OCMClassMock(OGAAdContainer.self);

    OGAExpandAdAction *action = [[OGAExpandAdAction alloc] init];

    [action performAction:adContainer error:nil];

    OCMVerify([adContainer performAction:OGAExpandAdActionName error:nil]);
}

@end
