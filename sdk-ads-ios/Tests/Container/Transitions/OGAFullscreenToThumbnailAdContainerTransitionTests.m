//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAFullscreenToThumbnailAdContainerTransition.h"
#import "OGAFullscreenAdContainerState.h"
#import "OGAThumbnailAdContainerState.h"

@interface OGAFullscreenToThumbnailAdContainerTransitionTests : XCTestCase

@end

@implementation OGAFullscreenToThumbnailAdContainerTransitionTests

#pragma mark - Constants

static NSString *const defaultAction = @"";

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAFullscreenToThumbnailAdContainerTransition *transition = [[OGAFullscreenToThumbnailAdContainerTransition alloc] initWithAction:defaultAction
                                                                                                                         initialState:[[OGAFullscreenAdContainerState alloc] init]
                                                                                                                           finalState:[[OGAThumbnailAdContainerState alloc] init]];

    XCTAssertNotNil(transition);
    XCTAssertTrue([transition.initialState isKindOfClass:OGAFullscreenAdContainerState.self]);
    XCTAssertTrue([transition.finalState isKindOfClass:OGAThumbnailAdContainerState.self]);
}

- (void)testShouldPerformTransition {
    OGAFullscreenAdContainerState *initialState = OCMClassMock(OGAFullscreenAdContainerState.self);

    OGAFullscreenToThumbnailAdContainerTransition *transition = [[OGAFullscreenToThumbnailAdContainerTransition alloc] initWithAction:defaultAction
                                                                                                                         initialState:initialState
                                                                                                                           finalState:[[OGAThumbnailAdContainerState alloc] init]];

    [transition performTransition:nil];

    OCMVerify([initialState unregisterForApplicationLifecycleNotifications]);
}

@end
