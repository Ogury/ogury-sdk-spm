//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAAdDisplayer.h"
#import "OGAFullscreenAdContainerState+Testing.h"

@interface OGAFullscreenAdContainerStateTests : XCTestCase

@end

@implementation OGAFullscreenAdContainerStateTests

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAFullscreenAdContainerState *state = [[OGAFullscreenAdContainerState alloc] init];

    XCTAssertNotNil(state);
}

- (void)testState {
    OGAFullscreenAdContainerState *state = [[OGAFullscreenAdContainerState alloc] init];

    XCTAssertEqualObjects(state.name, @"fullscreen");
}

- (void)testType {
    OGAFullscreenAdContainerState *state = [[OGAFullscreenAdContainerState alloc] init];

    XCTAssertEqual(state.type, OGAAdContainerStateTypeFullScreenOverlay);
}

- (void)test_ShouldReturnIsExpandedAsTrue {
    OGAFullscreenAdContainerState *state = [[OGAFullscreenAdContainerState alloc] init];

    XCTAssertTrue(state.isExpanded);
}

- (void)testDisplay {
    UIViewController *rootViewController = OCMClassMock([UIViewController class]);
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAFullscreenViewController *viewController = OCMClassMock([OGAFullscreenViewController class]);
    OCMStub([viewController display:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);
    OCMExpect([displayer startOMIDSessionOnShow]);
    OGAFullscreenAdContainerState *state = OCMPartialMock([[OGAFullscreenAdContainerState alloc] initWithViewControllerProvider:^UIViewController * {
        return rootViewController;
    }]);
    OCMStub([state createFullscreenViewController]).andReturn(viewController);

    OguryError *error = nil;
    XCTAssertTrue([state display:displayer error:&error]);
    OCMVerify([viewController display:displayer error:[OCMArg anyObjectRef]]);
    OCMVerify([rootViewController presentViewController:viewController animated:NO completion:[OCMArg any]]);
}

- (void)testShouldCreateFullscreenViewController {
    OGAFullscreenAdContainerState *state = [[OGAFullscreenAdContainerState alloc] initWithViewControllerProvider:^UIViewController * {
        return nil;
    }];

    OGAFullscreenViewController *fullscreenViewController = [state createFullscreenViewController];

    XCTAssertNotNil(fullscreenViewController);
}

- (void)testDisplay_noViewController {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));

    OGAFullscreenAdContainerState *state = [[OGAFullscreenAdContainerState alloc] initWithViewControllerProvider:^UIViewController * {
        return nil;
    }];

    OguryError *error = nil;
    XCTAssertFalse([state display:displayer error:&error]);
    XCTAssertNotNil(error);
}

- (void)testDisplay_viewControllerFailedToDisplay {
    UIViewController *rootViewController = OCMClassMock([UIViewController class]);
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAFullscreenViewController *viewController = OCMClassMock([OGAFullscreenViewController class]);
    OguryError *viewControllerError = OCMClassMock([OguryAdsError class]);
    OCMStub([viewController display:[OCMArg any] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
                                                                                  OguryError *__autoreleasing *errorPointer = nil;
                                                                                  [invocation getArgument:&errorPointer atIndex:3];
                                                                                  *errorPointer = viewControllerError;
                                                                              })
        .andReturn(NO);

    OGAFullscreenAdContainerState *state = OCMPartialMock([[OGAFullscreenAdContainerState alloc] initWithViewControllerProvider:^UIViewController * {
        return rootViewController;
    }]);
    OCMStub([state createFullscreenViewController]).andReturn(viewController);

    OguryError *error = nil;
    XCTAssertFalse([state display:displayer error:&error]);
    OCMVerify([viewController display:displayer error:[OCMArg anyObjectRef]]);
    XCTAssertEqual(error, viewControllerError);
}

- (void)testShouldCleanUp {
    OGAFullscreenAdContainerState *state = OCMPartialMock([[OGAFullscreenAdContainerState alloc] initWithViewControllerProvider:^UIViewController * {
        return nil;
    }]);

    state.fullscreenViewController = OCMClassMock(OGAFullscreenViewController.self);

    [state cleanUp];

    OCMVerify([state.fullscreenViewController dismissViewControllerAnimated:NO completion:OCMOCK_ANY]);
    OCMVerify([state.fullscreenViewController cleanUp]);

    XCTAssertNil(state.fullscreenViewController);
}

- (void)testShouldPerformKeepAliveOnEnteringBackground {
    OGAFullscreenAdContainerState *state = OCMPartialMock([[OGAFullscreenAdContainerState alloc] initWithViewControllerProvider:^UIViewController * {
        return nil;
    }]);

    [state applicationDidEnterBackground];

    OCMVerify([state performKeepAlive]);
}

@end
