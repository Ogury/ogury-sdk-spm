//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGACloseSKAdToCloseTransition.h"
#import "OGAStoreKitState.h"
#import "OGASKOverlayState.h"
#import "OGAClosedAdContainerState.h"

@interface OGACloseSKAdToCloseTransitionTests : XCTestCase

@property(strong) id<OGAAdContainerState> initialState;
@property(strong) id<OGAAdContainerState> finalState;

@end

@implementation OGACloseSKAdToCloseTransitionTests

#pragma mark - Methods

- (void)testShouldInstantiateStoreKit {
    OGACloseSKAdToCloseTransition *transition = [[OGACloseSKAdToCloseTransition alloc] initWithInitialState:[[OGAStoreKitState alloc] init] finalState:[[OGAClosedAdContainerState alloc] init]];

    XCTAssertNotNil(transition);
}

- (void)testShouldPerformActionStoreKit {
    self.initialState = OCMClassMock([OGAStoreKitState class]);
    self.finalState = OCMClassMock([OGAClosedAdContainerState class]);

    OGACloseSKAdToCloseTransition *transition = [[OGACloseSKAdToCloseTransition alloc] initWithInitialState:self.initialState finalState:self.finalState];
    NSError *error;
    XCTAssertTrue([transition performTransition:&error]);
    XCTAssertNil(error);
    OCMVerify([self.initialState cleanUp]);
    OCMVerify([self.initialState forceClose]);
}

- (void)testShouldInstantiateSKOverlay {
    OGACloseSKAdToCloseTransition *transition = [[OGACloseSKAdToCloseTransition alloc] initWithInitialState:[[OGASKOverlayState alloc] init] finalState:[[OGAClosedAdContainerState alloc] init]];

    XCTAssertNotNil(transition);
}

- (void)testShouldPerformActionSKOverlay {
    self.initialState = OCMClassMock([OGASKOverlayState class]);
    self.finalState = OCMClassMock([OGAClosedAdContainerState class]);

    OGACloseSKAdToCloseTransition *transition = [[OGACloseSKAdToCloseTransition alloc] initWithInitialState:self.initialState finalState:self.finalState];
    NSError *error;
    XCTAssertTrue([transition performTransition:&error]);
    XCTAssertNil(error);
    OCMVerify([self.initialState cleanUp]);
    OCMVerify([self.initialState forceClose]);
}

@end
