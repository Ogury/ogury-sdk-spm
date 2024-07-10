//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OGAInitialAdContainerState.h"

@interface OGAInitialAdContainerStateTests : XCTestCase

@property(nonatomic, strong) OGAInitialAdContainerState *state;

@end

@implementation OGAInitialAdContainerStateTests

- (void)setUp {
    self.state = [[OGAInitialAdContainerState alloc] init];
}

#pragma mark - Properties

- (void)testState {
    XCTAssertEqualObjects(self.state.name, @"initial");
}

- (void)testType {
    XCTAssertEqual(self.state.type, OGAAdContainerStateTypeInitial);
}

- (void)test_ShouldReturnIsExpandedAsFalse {
    XCTAssertFalse(self.state.isExpanded);
}

@end
