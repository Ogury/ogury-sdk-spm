//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAAdContainerBuilder+Testing.h"
#import "OGAForceCloseAdAction.h"
#import "OGAInitialAdContainerState.h"
#import "OGAClosedAdContainerState.h"
#import "OGABasicAdContainerTransition.h"

@interface OGAAdContainerBuilderTests : XCTestCase

@property(nonatomic, strong) id<OGAAdDisplayer> displayer;
@property(nonatomic, strong) OGAAdContainerBuilder *builder;

@end

@implementation OGAAdContainerBuilderTests

- (void)setUp {
    self.displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    self.builder = OCMPartialMock([[OGAAdContainerBuilder alloc] initWithDisplayer:self.displayer]);
}

#pragma mark - Initialization

- (void)testInit {
    XCTAssertTrue([self.builder.initialState isKindOfClass:[OGAInitialAdContainerState class]]);
    XCTAssertEqual(self.builder.initialState.displayer, self.displayer);

    XCTAssertTrue([self.builder.closedState isKindOfClass:[OGAClosedAdContainerState class]]);
    XCTAssertNil(self.builder.closedState.displayer);

    id<OGAAdContainerTransition> transition = self.builder.transitions.firstObject;
    XCTAssertNotNil(transition);
    XCTAssertEqualObjects(transition.action, OGAForceCloseAdActionName);
    XCTAssertEqual(transition.initialState, self.builder.initialState);
    XCTAssertEqual(transition.finalState, self.builder.closedState);
}

#pragma mark - Methods

- (void)testAddState {
    id<OGAAdContainerState> state = OCMProtocolMock(@protocol(OGAAdContainerState));

    [self.builder addState:state];

    XCTAssertEqualObjects(self.builder.states.lastObject, state);
    id<OGAAdContainerTransition> forceCloseTransition = self.builder.transitions.lastObject;
    XCTAssertEqualObjects(forceCloseTransition.action, OGAForceCloseAdActionName);
    XCTAssertEqual(forceCloseTransition.initialState, state);
    XCTAssertEqual(forceCloseTransition.finalState, self.builder.closedState);
}

- (void)testAddState_doNotAddAlreadyKnownState {
    id<OGAAdContainerState> state = OCMProtocolMock(@protocol(OGAAdContainerState));

    [self.builder addState:state];

    NSArray *addedStates = [self.builder.states filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary<NSString *, id> *bindings) {
                                                    return evaluatedObject == state;
                                                }]];
    XCTAssertEqual(addedStates.count, 1);
}

- (void)testAddTransition {
    id<OGAAdContainerTransition> transition = OCMProtocolMock(@protocol(OGAAdContainerTransition));
    id<OGAAdContainerState> initialState = OCMProtocolMock(@protocol(OGAAdContainerState));
    id<OGAAdContainerState> finalState = OCMProtocolMock(@protocol(OGAAdContainerState));
    OCMStub(transition.initialState).andReturn(initialState);
    OCMStub(transition.finalState).andReturn(finalState);
    OCMStub([self.builder addState:[OCMArg any]]);

    [self.builder addTransition:transition];

    XCTAssertEqualObjects(self.builder.transitions.lastObject, transition);
    OCMVerify([self.builder addState:initialState]);
    OCMVerify([self.builder addState:finalState]);
}

- (void)testAddBasicTransitionWithAction {
    OCMStub([self.builder addTransition:[OCMArg any]]);
    id<OGAAdContainerState> state = OCMProtocolMock(@protocol(OGAAdContainerState));

    [self.builder addBasicTransitionWithAction:@"test" initialState:self.builder.initialState finalState:state];

    __block id<OGAAdContainerTransition> transition;
    OCMVerify([self.builder addTransition:[OCMArg checkWithBlock:^BOOL(id obj) {
                                transition = obj;
                                return YES;
                            }]]);
    XCTAssertEqualObjects(transition.action, @"test");
    XCTAssertEqual(transition.initialState, self.builder.initialState);
    XCTAssertEqual(transition.finalState, state);
}

- (void)testBuild {
    OGAAdContainer *container = [self.builder build];

    XCTAssertNotNil(container);
    XCTAssertEqualObjects(container.transitions, self.builder.transitions);
}

- (void)testAssertNoNonReachableStates_doNotThrowIfNoNonReachableState {
    XCTAssertNoThrow([self.builder assertNoNonReachableStates]);
}

- (void)testAssertNoNonReachableStates_throwIfAtLeastOneNonReachableState {
    id<OGAAdContainerTransition> transition = OCMProtocolMock(@protocol(OGAAdContainerTransition));
    id<OGAAdContainerState> initialState = OCMProtocolMock(@protocol(OGAAdContainerState));
    id<OGAAdContainerState> finalState = self.builder.closedState;
    OCMStub(transition.initialState).andReturn(initialState);
    OCMStub(transition.finalState).andReturn(finalState);

    [self.builder addTransition:transition];
    XCTAssertThrows([self.builder assertNoNonReachableStates]);
}

@end
