//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAThumbnailToFullscreenAdContainerTransition.h"
#import "OGAThumbnailAdContainerState.h"
#import "OGAFullscreenAdContainerState.h"

@interface OGAThumbnailToFullscreenAdContainerTransitionTests : XCTestCase

@property(strong) id<OGAAdContainerState> initialState;
@property(strong) id<OGAAdContainerState> finalState;

@end

@implementation OGAThumbnailToFullscreenAdContainerTransitionTests

#pragma mark - Constants

static NSString *const defaultAction = @"";

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAThumbnailToFullscreenAdContainerTransition *transition = [[OGAThumbnailToFullscreenAdContainerTransition alloc] initWithAction:defaultAction
                                                                                                                         initialState:[[OGAThumbnailAdContainerState alloc] init]
                                                                                                                           finalState:[[OGAFullscreenAdContainerState alloc] init]];

    XCTAssertNotNil(transition);
    XCTAssertTrue([transition.initialState isKindOfClass:OGAThumbnailAdContainerState.self]);
    XCTAssertTrue([transition.finalState isKindOfClass:OGAFullscreenAdContainerState.self]);
}

- (void)testPerformTransition {
    self.initialState = OCMClassMock([OGAThumbnailAdContainerState class]);
    self.finalState = OCMClassMock([OGAFullscreenAdContainerState class]);

    OGAThumbnailToFullscreenAdContainerTransition *transition = [[OGAThumbnailToFullscreenAdContainerTransition alloc] initWithAction:defaultAction
                                                                                                                         initialState:self.initialState
                                                                                                                           finalState:self.finalState];

    NSError *error;

    OCMReject([self.finalState cleanUp]);
    OCMStub([self.finalState display:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);

    XCTAssertTrue([transition.initialState isKindOfClass:OGAThumbnailAdContainerState.self]);
    XCTAssertTrue([transition.finalState isKindOfClass:OGAFullscreenAdContainerState.self]);
    XCTAssertTrue([transition performTransition:&error]);
    XCTAssertNil(error);

    OCMVerify([self.finalState display:[OCMArg any] error:[OCMArg anyObjectRef]]);
}

- (void)testShouldPerformActionWithError {
    self.initialState = OCMClassMock([OGAThumbnailAdContainerState class]);
    self.finalState = OCMClassMock([OGAFullscreenAdContainerState class]);

    OGAThumbnailToFullscreenAdContainerTransition *transition = [[OGAThumbnailToFullscreenAdContainerTransition alloc] initWithAction:defaultAction
                                                                                                                         initialState:self.initialState
                                                                                                                           finalState:self.finalState];

    NSError *error;
    OguryError *displayError = OCMClassMock([OguryError class]);
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
