//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAOpenSKOverlayAction.h"
#import <OCMock/OCMock.h>
#import "OGAAdContainer.h"

@interface OGAOpenSKOverlayActionTests : XCTestCase

@end

@implementation OGAOpenSKOverlayActionTests

- (void)testShouldInstantiate {
    OGAOpenSKOverlayAction *action = [[OGAOpenSKOverlayAction alloc] init];
    XCTAssertNotNil(action);
}

- (void)testShouldPerformActionOnDisplayerClose {
    OGAOpenSKOverlayAction *action = [[OGAOpenSKOverlayAction alloc] init];
    OGAAdContainer *mockContainer = OCMClassMock(OGAAdContainer.self);
    [action performAction:mockContainer error:nil];
    OCMVerify([mockContainer performAction:action.name error:nil]);
}

@end
