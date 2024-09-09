//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGABannerToFullscreenAdContainerTransition.h"
#import "OGABannerAdContainerState.h"
#import "OGAFullscreenAdContainerState.h"
#import "OGAAdExposureController.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAAdDisplayerUpdateStateInformation.h"
#import "OGAAdDisplayerUpdateViewabilityInformation.h"

@interface OGABannerToFullscreenAdContainerTransitionTests : XCTestCase

@property(nonatomic, strong) id<OGAAdContainerState> initialState;
@property(nonatomic, strong) id<OGAAdContainerState> finalState;

@end

@implementation OGABannerToFullscreenAdContainerTransitionTests

#pragma mark - Constants

static NSString *const defaultAction = @"expand";

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGABannerToFullscreenAdContainerTransition *transition = [[OGABannerToFullscreenAdContainerTransition alloc] initWithInitialState:[[OGABannerAdContainerState alloc] init]
                                                                                                                           finalState:[[OGAFullscreenAdContainerState alloc] init]];

    XCTAssertNotNil(transition);
    XCTAssertTrue([transition.initialState isKindOfClass:OGABannerAdContainerState.self]);
    XCTAssertTrue([transition.finalState isKindOfClass:OGAFullscreenAdContainerState.self]);
}

- (void)testPerformTransition {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));

    // Initial state
    self.initialState = OCMClassMock([OGABannerAdContainerState class]);
    OCMStub(self.initialState.displayer).andReturn(displayer);

    OGAAdExposureController *initialExposureController = OCMClassMock(OGAAdExposureController.self);
    OCMStub(self.initialState.exposureController).andReturn(initialExposureController);

    // Final state
    self.finalState = OCMClassMock([OGAFullscreenAdContainerState class]);
    OCMStub(self.finalState.displayer).andReturn(displayer);

    OGAAdExposureController *finalExposureController = OCMClassMock(OGAAdExposureController.self);
    OCMStub(self.finalState.exposureController).andReturn(finalExposureController);

    OGABannerToFullscreenAdContainerTransition *transition = [[OGABannerToFullscreenAdContainerTransition alloc] initWithAction:defaultAction
                                                                                                                   initialState:self.initialState
                                                                                                                     finalState:self.finalState];

    NSError *error;

    OCMReject([self.finalState cleanUp]);
    OCMStub([self.finalState display:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);

    XCTAssertTrue([transition.initialState isKindOfClass:OGABannerAdContainerState.self]);
    XCTAssertTrue([transition.finalState isKindOfClass:OGAFullscreenAdContainerState.self]);
    XCTAssertTrue([transition performTransition:&error]);
    XCTAssertNil(error);

    OCMVerify([initialExposureController stopExposure]);
    OCMVerify([displayer dispatchInformation:[OCMArg isKindOfClass:OGAAdDisplayerUpdateExposureInformation.self]]);

    OCMVerify([self.finalState display:[OCMArg any] error:[OCMArg anyObjectRef]]);

    OCMVerify([finalExposureController startExposure]);
    OCMVerify([displayer dispatchInformation:[OCMArg isKindOfClass:OGAAdDisplayerUpdateStateInformation.self]]);
    OCMVerify([displayer dispatchInformation:[OCMArg isKindOfClass:OGAAdDisplayerUpdateExposureInformation.self]]);
}

- (void)testShouldPerformActionWithError {
    self.initialState = OCMClassMock([OGABannerAdContainerState class]);
    self.finalState = OCMClassMock([OGAFullscreenAdContainerState class]);

    OGABannerToFullscreenAdContainerTransition *transition = [[OGABannerToFullscreenAdContainerTransition alloc] initWithAction:defaultAction
                                                                                                                   initialState:self.initialState
                                                                                                                     finalState:self.finalState];

    NSError *error;
    OguryError *displayError = OCMClassMock([OguryAdsError class]);
    OCMStub([self.finalState display:[OCMArg any] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
                                                                                   OguryError *__autoreleasing *errorPointer = nil;
                                                                                   [invocation getArgument:&errorPointer atIndex:3];
                                                                                   *errorPointer = displayError;
                                                                               })
        .andReturn(NO);

    OCMReject([self.finalState cleanUp]);

    XCTAssertFalse([transition performTransition:&error]);
    XCTAssertNotNil(error);

    OCMVerify([self.finalState display:[OCMArg any] error:[OCMArg anyObjectRef]]);
}

@end
