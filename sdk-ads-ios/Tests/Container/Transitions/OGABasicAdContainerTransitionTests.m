//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGABasicAdContainerTransition.h"
#import "OGAFullscreenAdContainerState.h"

@interface OGABasicAdContainerTransitionTests : XCTestCase

@property(strong) id<OGAAdContainerState> initialState;
@property(strong) id<OGAAdContainerState> finalState;

@end

@implementation OGABasicAdContainerTransitionTests

#pragma mark - Constants

static NSString *const defaultAction = @"";

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGABasicAdContainerTransition *transition = [[OGABasicAdContainerTransition alloc] initWithAction:defaultAction
                                                                                         initialState:[[OGAFullscreenAdContainerState alloc] init]
                                                                                           finalState:[[OGAFullscreenAdContainerState alloc] init]];

    XCTAssertNotNil(transition);
}

- (void)testShouldPerformAction {
    self.initialState = OCMProtocolMock(@protocol(OGAAdContainerState));
    self.finalState = OCMProtocolMock(@protocol(OGAAdContainerState));

    OGABasicAdContainerTransition *transition = [[OGABasicAdContainerTransition alloc] initWithAction:defaultAction
                                                                                         initialState:self.initialState
                                                                                           finalState:self.finalState];

    NSError *error;

    OCMStub([self.finalState display:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);

    XCTAssertTrue([transition performTransition:&error]);
    XCTAssertNil(error);
    OCMVerify([self.finalState display:[OCMArg any] error:[OCMArg anyObjectRef]]);
    OCMVerify([self.initialState cleanUp]);
}

- (void)testShouldPerformActionWithError {
    self.initialState = OCMProtocolMock(@protocol(OGAAdContainerState));
    self.finalState = OCMProtocolMock(@protocol(OGAAdContainerState));

    OGABasicAdContainerTransition *transition = [[OGABasicAdContainerTransition alloc] initWithAction:defaultAction
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

    XCTAssertFalse([transition performTransition:&error]);
    XCTAssertNotNil(error);
}

@end
