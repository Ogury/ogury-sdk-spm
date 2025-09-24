//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGACloseSKAdToFullscreenAdContainerTransition.h"
#import "OGAFullscreenAdContainerState.h"
#import "OGAStoreKitState.h"
#import "OGASKOverlayState.h"

@interface OGACloseSKAdToFullscreenAdContainerTransitionTests : XCTestCase

@property(strong) id<OGAAdContainerState> initialState;
@property(strong) id<OGAAdContainerState> finalState;

@end

@implementation OGACloseSKAdToFullscreenAdContainerTransitionTests
#pragma mark - Methods

- (void)testShouldInstantiateStoreKit {
    OGACloseSKAdToFullscreenAdContainerTransition *transition = [[OGACloseSKAdToFullscreenAdContainerTransition alloc] initWithInitialState:[[OGAStoreKitState alloc] init] finalState:[[OGAFullscreenAdContainerState alloc] init]];

    XCTAssertNotNil(transition);
}

- (void)testShouldPerformActionStoreKit {
    self.initialState = OCMClassMock([OGAStoreKitState class]);
    self.finalState = OCMClassMock([OGAFullscreenAdContainerState class]);

    OGACloseSKAdToFullscreenAdContainerTransition *transition = [[OGACloseSKAdToFullscreenAdContainerTransition alloc] initWithInitialState:self.initialState finalState:self.finalState];
    NSError *error;
    XCTAssertTrue([transition performTransition:&error]);
    XCTAssertNil(error);
    OCMVerify([self.initialState cleanUp]);
}

- (void)testShouldInstantiateSKOverlay {
    OGACloseSKAdToFullscreenAdContainerTransition *transition = [[OGACloseSKAdToFullscreenAdContainerTransition alloc] initWithInitialState:[[OGASKOverlayState alloc] init] finalState:[[OGAFullscreenAdContainerState alloc] init]];

    XCTAssertNotNil(transition);
}

- (void)testShouldPerformActionSKOverlay {
    self.initialState = OCMClassMock([OGASKOverlayState class]);
    self.finalState = OCMClassMock([OGAFullscreenAdContainerState class]);

    OGACloseSKAdToFullscreenAdContainerTransition *transition = [[OGACloseSKAdToFullscreenAdContainerTransition alloc] initWithInitialState:self.initialState finalState:self.finalState];
    NSError *error;
    XCTAssertTrue([transition performTransition:&error]);
    XCTAssertNil(error);
    OCMVerify([self.initialState cleanUp]);
}

@end
