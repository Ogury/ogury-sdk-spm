//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAThumbnailAdWindow.h"
#import "OGAThumbnailAdViewController.h"
#import <OCMock/OCMock.h>
#import "OGAAd.h"
#import "OGAAdConfiguration.h"
#import "OGAThumbnailAdResponse.h"
#import "OGAMRAIDAdDisplayer.h"
#import "UIWindowScene+OGAActiveScene.h"

@interface OGAThumbnailAdWindow ()

@property(strong, nonatomic) OGAThumbnailAdViewController *_Nullable thumbnailAdViewController;

- (instancetype)initWithDisplayer:(id<OGAAdDisplayer>)displayer thumbnailViewController:(OGAThumbnailAdViewController *)thumbnailViewController;

- (void)setupThumbnailAdWindowWithDisplayer:(id<OGAAdDisplayer>)displayer;

- (OGAThumbnailAdViewController *)createThumbnailAdViewControllerWithDisplayer:(id<OGAAdDisplayer>)displayer;

@end

@interface OGAThumbnailAdWindowTests : XCTestCase

@property(nonatomic, strong) OGAThumbnailAdWindow *thumbnailAdWindow;
@property(nonatomic, strong) id<OGAAdDisplayer> displayer;
@property(nonatomic, strong) OGAThumbnailAdViewController *thumbnailViewController;
@property(nonatomic, strong) OGAAd *ad;
@property(nonatomic, strong) OGAAdConfiguration *configuration;
@property(nonatomic, strong) UIWindowScene *scene API_AVAILABLE(ios(13.0));
@property(nonatomic, strong) OGAThumbnailAdResponse *thumbnailAdResponse;

@end

@implementation OGAThumbnailAdWindow (overwriteForTesting)

- (void)setRootViewController:(UIViewController *)rootViewController {
}

@end

@implementation OGAThumbnailAdWindowTests

- (void)setUp {
    self.displayer = OCMClassMock([OGAMRAIDAdDisplayer class]);
    self.ad = OCMClassMock([OGAAd class]);
    self.configuration = OCMClassMock([OGAAdConfiguration class]);
    self.thumbnailAdResponse = OCMClassMock([OGAThumbnailAdResponse class]);
    OCMStub([self.thumbnailAdResponse width]).andReturn(@"180");
    OCMStub([self.thumbnailAdResponse height]).andReturn(@"101");
    OCMStub([self.ad thumbnailAdResponse]).andReturn(self.thumbnailAdResponse);
    OCMStub([self.displayer ad]).andReturn(self.ad);
    if (@available(iOS 13.0, *)) {
        self.scene = OCMClassMock([UIWindowScene class]);
        OCMStub([self.configuration scene]).andReturn(self.scene);
    }
    self.thumbnailViewController = OCMClassMock([OGAThumbnailAdViewController class]);
    self.thumbnailAdWindow = OCMPartialMock([[OGAThumbnailAdWindow alloc] initWithDisplayer:self.displayer thumbnailViewController:self.thumbnailViewController]);
}

#pragma mark - Properties

- (void)testThumbnailAdViewController {
    XCTAssertNotNil(self.thumbnailAdWindow.thumbnailAdViewController);
}

#pragma mark - Methods

- (void)testSetupThumbnailWindowWithDisplayer {
    if (@available(iOS 13.0, *)) {
        OCMStub([self.thumbnailAdWindow setWindowScene:self.scene]);
        OCMStub([self.displayer configuration]).andReturn(self.configuration);
    }
    [self.thumbnailAdWindow setupThumbnailAdWindowWithDisplayer:self.displayer];
    XCTAssertEqual(self.thumbnailAdWindow.frame.origin.x, 0);
    XCTAssertEqual(self.thumbnailAdWindow.frame.origin.y, 0);
    XCTAssertEqual(self.thumbnailAdWindow.frame.size.width, 180);
    XCTAssertEqual(self.thumbnailAdWindow.frame.size.height, 101);
    XCTAssertEqual(self.thumbnailAdWindow.tag, 987652);
    XCTAssertTrue(self.thumbnailAdWindow.clipsToBounds);
    XCTAssertEqual(self.thumbnailAdWindow.windowLevel, UIWindowLevelStatusBar);
    if (@available(iOS 13.0, *)) {
        OCMVerify([self.thumbnailAdWindow setWindowScene:self.scene]);
    }
}

- (void)testSetupThumbnailWindowWithDisplayerNoScene API_AVAILABLE(ios(13.0)) {
    OCMStub([self.scene activationState]).andReturn(UISceneActivationStateForegroundActive);
    id windowSceneMock = OCMClassMock([UIWindowScene class]);
    OCMStub(ClassMethod([windowSceneMock getOGAActiveScene])).andReturn(self.scene);
    [self.thumbnailAdWindow setupThumbnailAdWindowWithDisplayer:self.displayer];
    XCTAssertEqual(self.thumbnailAdWindow.frame.origin.x, 0);
    XCTAssertEqual(self.thumbnailAdWindow.frame.origin.y, 0);
    XCTAssertEqual(self.thumbnailAdWindow.frame.size.width, 180);
    XCTAssertEqual(self.thumbnailAdWindow.frame.size.height, 101);
    XCTAssertEqual(self.thumbnailAdWindow.tag, 987652);
    XCTAssertTrue(self.thumbnailAdWindow.clipsToBounds);
    XCTAssertEqual(self.thumbnailAdWindow.windowLevel, UIWindowLevelStatusBar);
    OCMVerify([self.thumbnailAdWindow setWindowScene:self.scene]);
    [windowSceneMock stopMocking];
}

- (void)testDisplay {
    OCMStub([self.thumbnailAdWindow makeKeyWindow]);
    OCMStub([self.thumbnailViewController display:self.displayer error:[OCMArg anyObjectRef]]).andReturn(YES);

    OguryError *error;
    XCTAssertTrue([self.thumbnailAdWindow display:self.displayer error:&error]);

    OCMVerify([self.thumbnailViewController display:self.displayer error:[OCMArg anyObjectRef]]);
    OCMVerify([self.displayer startOMIDSessionOnShow]);
    OCMVerify([self.thumbnailAdWindow makeKeyWindow]);
}

- (void)testDisplay_doNotCallDisplayAgainIfDisplayerIsAlreadyDisplayed {
    OCMStub(self.thumbnailViewController.displayer).andReturn(self.displayer);
    OCMReject([self.thumbnailAdWindow makeKeyWindow]);
    OCMReject([self.thumbnailViewController display:[OCMArg any] error:[OCMArg anyObjectRef]]);

    OguryError *error;
    XCTAssertTrue([self.thumbnailAdWindow display:self.displayer error:&error]);
    OCMVerify([self.thumbnailViewController updateThumbnailAdWithAnimation:NO]);
}

- (void)testDisplay_failedToDisplayDisplayer {
    OguryError *displayError = OCMClassMock([OguryAdError class]);
    OCMStub([self.thumbnailAdWindow makeKeyWindow]);
    OCMStub([self.thumbnailViewController display:self.displayer error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
                                                                                                  OguryAdError *__autoreleasing *errorPointer = nil;
                                                                                                  [invocation getArgument:&errorPointer atIndex:3];
                                                                                                  *errorPointer = displayError;
                                                                                              })
        .andReturn(NO);

    OguryAdError *error;
    XCTAssertFalse([self.thumbnailAdWindow display:self.displayer error:&error]);

    XCTAssertEqual(error, displayError);
    OCMVerify([self.thumbnailViewController display:self.displayer error:[OCMArg anyObjectRef]]);
    OCMReject([self.thumbnailAdWindow makeKeyWindow]);
}

- (void)testCreateThumbnailViewControllerWithDisplayer {
    OGAThumbnailAdViewController *thumbnailController = [self.thumbnailAdWindow createThumbnailAdViewControllerWithDisplayer:self.displayer];
    XCTAssertNotNil(thumbnailController);
}

- (void)testCleanUp {
    OCMStub([self.thumbnailAdWindow setRootViewController:nil]).andDo(^(NSInvocation *invocation){
    });
    OCMStub([self.thumbnailAdWindow setThumbnailAdViewController:nil]).andDo(^(NSInvocation *invocation){
    });
    [self.thumbnailAdWindow cleanUp];
    OCMVerify([self.thumbnailAdWindow setRootViewController:nil]);
    OCMVerify([self.thumbnailAdWindow setThumbnailAdViewController:nil]);
}

@end
