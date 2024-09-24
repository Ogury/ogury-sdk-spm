//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAWindowedFullscreenAdContainerState.h"
#import "OGAWindowedFullscreenAdContainerState+Testing.h"
#import "OGAAdDisplayer.h"
#import "OGAAdDisplayerUpdateStateInformation.h"

@interface OGAWindowedFullscreenAdContainerStateTests : XCTestCase

@property(nonatomic, strong) OGAThumbnailAdWindow *window;
@property(nonatomic, strong) id<OGAAdDisplayer> displayer;
@property(nonatomic, strong) OGAThumbnailAdWindowFactory *windowFactory;
@property(nonatomic, strong) OGAWindowedFullscreenAdContainerState *state;
@property(nonatomic, strong) UIApplication *application;
@property(nonatomic, strong, nullable) OGASizeSafeAreaController *safeAreaController;

@end

@implementation OGAWindowedFullscreenAdContainerStateTests

- (void)setUp {
    self.displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    self.window = OCMClassMock([OGAThumbnailAdWindow class]);
    self.windowFactory = OCMPartialMock([[OGAThumbnailAdWindowFactory alloc] init]);
    self.safeAreaController = OCMClassMock([OGASizeSafeAreaController class]);
    self.application = OCMClassMock([UIApplication class]);

    OGAWindowedFullscreenAdContainerState *state = [[OGAWindowedFullscreenAdContainerState alloc] initWithThumbnailAdWindowFactory:self.windowFactory safeAreaController:self.safeAreaController application:self.application];
    self.state = OCMPartialMock(state);
}

#pragma mark - Properties

- (void)testName {
    XCTAssertEqualObjects(self.state.name, @"FullscreenWindowAd");
}

- (void)testType {
    XCTAssertEqual(self.state.type, OGAAdContainerStateTypeFullScreenOverlay);
}

- (void)test_ShouldReturnIsExpandedAsTrue {
    XCTAssertTrue(self.state.isExpanded);
}

- (void)testExposureController {
    OGAThumbnailAdViewController *viewController = OCMClassMock([OGAThumbnailAdViewController class]);
    OGAAdExposureController *exposureController = OCMClassMock([OGAAdExposureController class]);
    OCMStub(self.window.thumbnailAdViewController).andReturn(viewController);
    OCMStub(viewController.exposureController).andReturn(exposureController);
    OCMStub(self.state.thumbnailAdWindow).andReturn(self.window);

    XCTAssertEqual(self.state.exposureController, exposureController);
}

- (void)testExposureController_returnsNilIfNoWindow {
    OCMStub(self.state.thumbnailAdWindow).andReturn(nil);

    XCTAssertNil(self.state.exposureController);
}

#pragma mark - Methods

- (void)testDisplay {
    OCMStub([self.windowFactory createThumbnailAdWindowWithDisplayer:[OCMArg any]]).andReturn(self.window);
    OCMStub([self.window display:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(YES);

    OguryError *error;
    XCTAssertTrue([self.state display:self.displayer error:&error]);

    OCMVerify([self.windowFactory createThumbnailAdWindowWithDisplayer:self.displayer]);
    OCMVerify([self.window display:self.displayer error:[OCMArg anyObjectRef]]);
    OCMVerify([self.application sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil]);
    OCMVerify([self.state registerForApplicationLifecycleNotifications]);
    OCMVerify([self.displayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(id obj) {
                                  if ([obj isKindOfClass:[OGAAdDisplayerUpdateStateInformation class]]) {
                                      return [((OGAAdDisplayerUpdateStateInformation *)obj).mraidState isEqualToString:@"expanded"];
                                  }
                                  return NO;
                              }]]);
}

- (void)testDisplay_failedToCreateWindow {
    OCMStub([self.windowFactory createThumbnailAdWindowWithDisplayer:[OCMArg any]]).andReturn(nil);

    OguryError *error;
    XCTAssertFalse([self.state display:self.displayer error:&error]);
    XCTAssertNotNil(error);
}

- (void)testDisplay_failedToDisplay {
    OguryError *displayError = OCMClassMock([OguryAdError class]);
    OCMStub([self.windowFactory createThumbnailAdWindowWithDisplayer:[OCMArg any]]).andReturn(self.window);
    OCMStub([self.window display:[OCMArg any] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
                                                                               OguryError *__autoreleasing *errorPointer = nil;
                                                                               [invocation getArgument:&errorPointer atIndex:3];
                                                                               *errorPointer = displayError;
                                                                           })
        .andReturn(NO);

    OguryError *error;
    XCTAssertFalse([self.state display:self.displayer error:&error]);
    XCTAssertEqual(error, displayError);
}

- (void)testShouldPerformCleanUp {
    OCMStub(self.state.thumbnailAdWindow).andReturn(self.window);

    [self.state cleanUp];

    OCMVerify([self.window cleanUp]);
    OCMVerify([self.windowFactory cleanUp]);

    OCMVerify([self.state setThumbnailAdWindow:nil]);
    XCTAssertNil(self.state.safeAreaController);
}

- (void)testShouldPerformKeepAliveOnEnteringBackground {
    OCMStub([self.state performKeepAlive]);

    [self.state applicationDidEnterBackground];

    OCMVerify([self.state performKeepAlive]);
}

@end
