//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAAdContainer+Testing.h"
#import "OguryAdsError.h"
#import "OguryAdError+Internal.h"

@interface OGAAdContainerTests : XCTestCase

@property(strong) id<OGAAdContainerState> initialState;
@property(strong) id<OGAAdContainerState> finalState;
@property(strong) id<OGAAdContainerTransition> transition;

@property(strong) OGAAdContainer *container;

@end

@implementation OGAAdContainerTests

- (void)setUp {
    self.initialState = OCMProtocolMock(@protocol(OGAAdContainerState));
    self.finalState = OCMProtocolMock(@protocol(OGAAdContainerState));

    self.transition = [self mockTransition:@"test" initialState:self.initialState finalState:self.finalState];

    self.container = [[OGAAdContainer alloc] initWithInitialState:self.initialState transitions:@[ self.transition ]];
}

- (id<OGAAdContainerTransition>)mockTransition:(NSString *)action initialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState {
    id<OGAAdContainerTransition> transition = OCMProtocolMock(@protocol(OGAAdContainerTransition));
    OCMStub(transition.action).andReturn(action);
    OCMStub(transition.initialState).andReturn(initialState);
    OCMStub(transition.finalState).andReturn(finalState);
    return transition;
}

- (void)testShouldInstantiate {
    XCTAssertEqual(self.container.transitions.count, 1);
}

- (void)testState {
    OCMStub(self.initialState.name).andReturn(@"initial");
    XCTAssertEqualObjects(self.container.state, @"initial");
}

- (void)testStateType {
    OCMStub(self.initialState.type).andReturn(OGAAdContainerStateTypeInitial);
    XCTAssertEqual(self.container.stateType, OGAAdContainerStateTypeInitial);
}

- (void)testFindTransitionForAction {
    NSArray<id<OGAAdContainerTransition>> *transitions = @[
        [self mockTransition:@"another"
                initialState:self.initialState
                  finalState:self.finalState],
        self.transition
    ];
    OGAAdContainer *container = [[OGAAdContainer alloc] initWithInitialState:self.initialState transitions:transitions];

    XCTAssertEqual([container findTransitionForAction:@"test" initialState:self.initialState], self.transition);
}

- (void)testFindTransitionForAction_notFound {
    XCTAssertNil([self.container findTransitionForAction:@"test" initialState:self.finalState]);
    XCTAssertNil([self.container findTransitionForAction:@"another" initialState:self.initialState]);
}

- (void)testPerformAction {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OCMStub(self.initialState.displayer).andReturn(displayer);
    OCMStub([self.finalState display:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);
    id<OGAAdContainerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdContainerDelegate));
    OCMStub([delegate shouldTransitionTo:[OCMArg any] from:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);
    self.container.delegate = delegate;
    OCMStub([self.transition performTransition:[OCMArg anyObjectRef]]).andReturn(YES);

    OguryError *error = nil;
    XCTAssertTrue([self.container performAction:@"test" error:&error]);

    OCMVerify([delegate shouldTransitionTo:self.finalState from:self.initialState error:[OCMArg anyObjectRef]]);
    OCMVerify([delegate didTransitionTo:self.finalState from:self.initialState action:@"test"]);
}

- (void)testPerformAction_missingTransition {
    OguryError *error = nil;
    XCTAssertFalse([self.container performAction:@"missing" error:&error]);
    XCTAssertNotNil(error);
}

- (void)testPerformAction_shouldNotPerform {
    OguryError *delegateError = OCMClassMock([OguryAdError class]);
    id<OGAAdContainerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdContainerDelegate));
    OCMStub([delegate shouldTransitionTo:[OCMArg any] from:[OCMArg any] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
                                                                                                         OguryError *__autoreleasing *errorPointer = nil;
                                                                                                         [invocation getArgument:&errorPointer atIndex:4];
                                                                                                         *errorPointer = delegateError;
                                                                                                     })
        .andReturn(NO);
    self.container.delegate = delegate;

    OguryError *error = nil;
    XCTAssertFalse([self.container performAction:@"test" error:&error]);
    XCTAssertEqual(delegateError, error);
}

- (void)testPerformAction_failedToDisplay {
    OguryError *displayError = [OguryAdError viewControllerPreventsAdFromBeingDisplayed];
    OCMStub([self.transition performTransition:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
                                                                          OguryError *__autoreleasing *errorPointer = nil;
                                                                          [invocation getArgument:&errorPointer atIndex:2];
                                                                          *errorPointer = displayError;
                                                                      })
        .andReturn(NO);
    id<OGAAdContainerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdContainerDelegate));
    OCMStub([delegate shouldTransitionTo:[OCMArg any] from:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);
    self.container.delegate = delegate;

    OguryError *error = nil;
    XCTAssertFalse([self.container performAction:@"test" error:&error]);

    XCTAssertEqual(displayError.localizedDescription, error.localizedDescription);

    OCMVerify([delegate shouldTransitionTo:self.finalState from:self.initialState error:[OCMArg anyObjectRef]]);
    OCMVerify([delegate didFailToTransitionTo:self.finalState error:displayError]);
}

@end
