//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAClosedAdContainerState.h"
#import "OGAAdContainerState.h"
#import "OGAAdDisplayer.h"

@interface OGAClosedAdContainerStateTests : XCTestCase

@end

@implementation OGAClosedAdContainerStateTests

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAClosedAdContainerState *state = [[OGAClosedAdContainerState alloc] init];

    XCTAssertNotNil(state);
    XCTAssertFalse(state.isExpanded);
}

- (void)testShouldReturnContainerStateName {
    OGAClosedAdContainerState *state = [[OGAClosedAdContainerState alloc] init];

    XCTAssertTrue([state.name isEqualToString:@"closed"]);
}

- (void)testShouldReturnContainerStateType {
    OGAClosedAdContainerState *state = [[OGAClosedAdContainerState alloc] init];

    XCTAssertEqual(state.type, OGAAdContainerStateTypeClosed);
}

- (void)testShouldCleanUpDisplayerOnDisplay {
    OGAClosedAdContainerState *state = [[OGAClosedAdContainerState alloc] init];

    id<OGAAdDisplayer> mockDisplayer = OCMProtocolMock(@protocol(OGAAdDisplayer));

    [state display:mockDisplayer error:nil];

    OCMVerify([mockDisplayer cleanUp]);
}

@end
