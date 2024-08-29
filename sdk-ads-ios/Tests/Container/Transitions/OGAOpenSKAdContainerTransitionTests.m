//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAOpenSKAdContainerTransition.h"
#import "OGAFullscreenAdContainerState.h"
#import "OGAStoreKitState.h"
#import "OGAOpenStoreKitAction.h"
#import "OGAOpenSKOverlayAction.h"
#import "OGASKOverlayState.h"
#import "OguryAdsError.h"

@interface OGAOpenSKAdContainerTransitionTests : XCTestCase

@property(strong) id<OGAAdContainerState> initialState;
@property(strong) id<OGAAdContainerState> finalState;

@end

@implementation OGAOpenSKAdContainerTransitionTests

#pragma mark - Methods

- (void)testShouldInstantiateStoreKit {
    OGAOpenSKAdContainerTransition *transition = [[OGAOpenSKAdContainerTransition alloc] initWithAction:OGAOpenStoreKitActionName initialState:[[OGAFullscreenAdContainerState alloc] init] finalState:[[OGAStoreKitState alloc] init]];

    XCTAssertNotNil(transition);
}

- (void)testShouldInstantiateSKOverlay {
    OGAOpenSKAdContainerTransition *transition = [[OGAOpenSKAdContainerTransition alloc] initWithAction:OGAOpenSKOverlayActionName initialState:[[OGAFullscreenAdContainerState alloc] init] finalState:[[OGASKOverlayState alloc] init]];

    XCTAssertNotNil(transition);
}

- (void)testShouldPerformActionSKOverlay {
    self.initialState = OCMClassMock([OGAFullscreenAdContainerState class]);
    self.finalState = OCMClassMock([OGASKOverlayState class]);

    OGAOpenSKAdContainerTransition *transition = [[OGAOpenSKAdContainerTransition alloc]
        initWithAction:OGAOpenSKOverlayActionName
          initialState:self.initialState
            finalState:self.finalState];

    NSError *error;

    OCMStub([self.finalState display:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);

    OCMReject([self.initialState cleanUp]);
    XCTAssertTrue([transition performTransition:&error]);
    XCTAssertNil(error);
    OCMVerify([self.finalState display:[OCMArg any] error:[OCMArg anyObjectRef]]);
}

- (void)testShouldPerformActionStoreKit {
    self.initialState = OCMClassMock([OGAFullscreenAdContainerState class]);
    self.finalState = OCMClassMock([OGAStoreKitState class]);

    OGAOpenSKAdContainerTransition *transition = [[OGAOpenSKAdContainerTransition alloc]
        initWithAction:OGAOpenStoreKitActionName
          initialState:self.initialState
            finalState:self.finalState];

    NSError *error;

    OCMStub([self.finalState display:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);

    OCMReject([self.initialState cleanUp]);
    XCTAssertTrue([transition performTransition:&error]);
    XCTAssertNil(error);
    OCMVerify([self.finalState display:[OCMArg any] error:[OCMArg anyObjectRef]]);
}

- (void)testShouldPerformActionSKOverlayError {
    self.initialState = OCMClassMock([OGAFullscreenAdContainerState class]);
    self.finalState = OCMClassMock([OGASKOverlayState class]);

    OGAOpenSKAdContainerTransition *transition = [[OGAOpenSKAdContainerTransition alloc]
        initWithAction:OGAOpenSKOverlayActionName
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

- (void)testShouldPerformActionStoreKitError {
    self.initialState = OCMClassMock([OGAFullscreenAdContainerState class]);
    self.finalState = OCMClassMock([OGAStoreKitState class]);

    OGAOpenSKAdContainerTransition *transition = [[OGAOpenSKAdContainerTransition alloc]
        initWithAction:OGAOpenStoreKitActionName
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
