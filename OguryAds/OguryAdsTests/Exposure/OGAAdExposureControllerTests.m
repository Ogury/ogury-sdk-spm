//
// Created by Pernic on 22/12/2020.
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdExposureController.h"
#import <OCMock/OCMock.h>
// #import "OCMockObject.h"
// #import "OCMMacroState.h"
// #import "OCMRecorder.h"
// #import "OCMStubRecorder.h"
#import "OGAKeyboardObserver.h"

@interface OGAAdExposureController (Testing)

- (instancetype)initWithApplication:(UIApplication *)application keyboardObserver:(OGAKeyboardObserver *)keyboardObserver notificationCenter:(NSNotificationCenter *)notificationCenter exposedView:(UIView *)exposedView exposedWindow:(UIWindow *)exposedWindow parentViewControllerProvider:(UIViewController * (^)(
                                                                                                                                                                                                                                                                                                   void))parentViewControllerProvider;
- (OGAAdExposure *)getExposure;
+ (UIViewController *)getParentViewControllerFor:(UIView *)view referentViewController:(UIViewController *)viewController;

@end

@interface OGAAdExposureControllerTests : XCTestCase

@end

@implementation OGAAdExposureControllerTests

- (void)testGetExposureApplicationInactive {
    UIViewController *rootViewController = OCMClassMock([UIViewController class]);
    id application = OCMClassMock([UIApplication class]);
    OCMStub([application sharedApplication]).andReturn(application);
    OCMStub([application applicationState]).andReturn(UIApplicationStateBackground);

    OGAAdExposureController *exposureController =
        [[OGAAdExposureController alloc] initWithApplication:application
                                            keyboardObserver:[OGAKeyboardObserver shared]
                                          notificationCenter:NSNotificationCenter.defaultCenter
                                                 exposedView:[[UIView alloc] init]
                                               exposedWindow:[[UIWindow alloc] init]
                                parentViewControllerProvider:^UIViewController * {
                                    return rootViewController;
                                }];

    OGAAdExposure *exposure = [exposureController getExposure];
    XCTAssertTrue(exposure.exposurePercentage < 0.001);
}

- (void)testGetExposureStopExposure {
    UIViewController *rootViewController = OCMClassMock([UIViewController class]);
    id application = OCMClassMock([UIApplication class]);
    OCMStub([application applicationState]).andReturn(UIApplicationStateActive);

    OGAAdExposureController *exposureController =
        [[OGAAdExposureController alloc] initWithApplication:application
                                            keyboardObserver:[OGAKeyboardObserver shared]
                                          notificationCenter:NSNotificationCenter.defaultCenter
                                                 exposedView:[[UIView alloc] init]
                                               exposedWindow:[[UIWindow alloc] init]
                                parentViewControllerProvider:^UIViewController * {
                                    return rootViewController;
                                }];

    [exposureController stopExposure];
    OGAAdExposure *exposure = [exposureController getExposure];
    XCTAssertTrue(exposure.exposurePercentage < 0.001);
}

- (void)testGetExposureOnlyOneWindowWithParent {
    UIViewController *parentViewController = OCMClassMock([UIViewController class]);
    UIViewController *adViewController = OCMClassMock([UIViewController class]);
    UIView *adView = OCMClassMock([UIView class]);
    OCMStub([adView frame]).andReturn(CGRectMake(0, 0, 100, 100));
    id application = OCMClassMock([UIApplication class]);
    OCMStub([application applicationState]).andReturn(UIApplicationStateActive);
    UIWindow *window = OCMClassMock([UIWindow class]);
    OCMStub([window rootViewController]).andReturn(adViewController);
    OCMStub([adViewController view]).andReturn(adView);
    OCMStub([application windows]).andReturn([NSArray arrayWithObject:window]);

    OGAAdExposureController *exposureController =
        [[OGAAdExposureController alloc] initWithApplication:application
                                            keyboardObserver:[OGAKeyboardObserver shared]
                                          notificationCenter:NSNotificationCenter.defaultCenter
                                                 exposedView:adView
                                               exposedWindow:window
                                parentViewControllerProvider:^UIViewController * {
                                    return parentViewController;
                                }];

    OGAAdExposure *exposure = [exposureController getExposure];
    XCTAssertTrue(exposure.exposurePercentage > 0.99);
}

- (void)testGetExposureOnlyOneWindowWithNoParent {
    UIViewController *adViewController = OCMClassMock([UIViewController class]);
    UIView *adView = OCMClassMock([UIView class]);
    OCMStub([adView frame]).andReturn(CGRectMake(0, 0, 100, 100));
    id application = OCMClassMock([UIApplication class]);
    OCMStub([application applicationState]).andReturn(UIApplicationStateActive);
    UIWindow *window = OCMClassMock([UIWindow class]);
    OCMStub([window rootViewController]).andReturn(adViewController);
    OCMStub([window frame]).andReturn(CGRectMake(0, 0, 100, 100));
    OCMStub([adViewController view]).andReturn(adView);
    OCMStub([application windows]).andReturn([NSArray arrayWithObject:window]);

    OGAAdExposureController *exposureController =
        [[OGAAdExposureController alloc] initWithApplication:application
                                            keyboardObserver:[OGAKeyboardObserver shared]
                                          notificationCenter:NSNotificationCenter.defaultCenter
                                                 exposedView:adView
                                               exposedWindow:window
                                parentViewControllerProvider:^UIViewController * {
                                    return nil;
                                }];

    OGAAdExposure *exposure = [exposureController getExposure];
    XCTAssertTrue(exposure.exposurePercentage > 0.99);
}

- (void)testGetExposureWindowsWithNoParent {
    UIViewController *adViewController = OCMClassMock([UIViewController class]);
    UIView *adView = OCMClassMock([UIView class]);
    OCMStub([adView frame]).andReturn(CGRectMake(0, 0, 100, 100));
    id application = OCMClassMock([UIApplication class]);
    OCMStub([application applicationState]).andReturn(UIApplicationStateActive);
    UIWindow *window = OCMClassMock([UIWindow class]);
    OCMStub([window rootViewController]).andReturn(adViewController);
    OCMStub([window frame]).andReturn(CGRectMake(0, 0, 100, 100));
    UIWindow *windowAbove = OCMClassMock([UIWindow class]);
    OCMStub([windowAbove frame]).andReturn(CGRectMake(0, 0, 50, 100));
    OCMStub([windowAbove alpha]).andReturn(1);
    OCMStub([windowAbove backgroundColor]).andReturn(UIColor.blackColor);
    UIViewController *viewControllerAbove = OCMClassMock([UIViewController class]);
    UIView *viewAbove = OCMClassMock([UIView class]);
    OCMStub([viewControllerAbove view]).andReturn(viewAbove);
    OCMStub([viewAbove backgroundColor]).andReturn(UIColor.blackColor);
    OCMStub([viewAbove isHidden]).andReturn(NO);
    OCMStub([viewAbove window]).andReturn(windowAbove);
    OCMStub([windowAbove rootViewController]).andReturn(viewControllerAbove);
    OCMStub([adViewController view]).andReturn(adView);
    NSMutableArray *windows = [[NSMutableArray alloc] init];
    [windows addObject:window];
    [windows addObject:windowAbove];
    OCMStub([application windows]).andReturn(windows);

    OGAAdExposureController *exposureController =
        [[OGAAdExposureController alloc] initWithApplication:application
                                            keyboardObserver:[OGAKeyboardObserver shared]
                                          notificationCenter:NSNotificationCenter.defaultCenter
                                                 exposedView:adView
                                               exposedWindow:window
                                parentViewControllerProvider:^UIViewController * {
                                    return nil;
                                }];

    OGAAdExposure *exposure = [exposureController getExposure];
    XCTAssertTrue(fabs(exposure.exposurePercentage - 50) < 0.001);
}

- (void)testGetExposureWindowsTransparentWithNoParent {
    UIViewController *adViewController = OCMClassMock([UIViewController class]);
    UIView *adView = OCMClassMock([UIView class]);
    OCMStub([adView frame]).andReturn(CGRectMake(0, 0, 100, 100));
    id application = OCMClassMock([UIApplication class]);
    OCMStub([application applicationState]).andReturn(UIApplicationStateActive);
    UIWindow *window = OCMClassMock([UIWindow class]);
    OCMStub([window rootViewController]).andReturn(adViewController);
    OCMStub([window frame]).andReturn(CGRectMake(0, 0, 100, 100));
    UIWindow *windowAbove = OCMClassMock([UIWindow class]);
    OCMStub([windowAbove frame]).andReturn(CGRectMake(0, 0, 50, 100));
    OCMStub([windowAbove alpha]).andReturn(0);
    OCMStub([windowAbove backgroundColor]).andReturn(UIColor.blackColor);
    UIViewController *viewControllerAbove = OCMClassMock([UIViewController class]);
    UIView *viewAbove = OCMClassMock([UIView class]);
    OCMStub([viewControllerAbove view]).andReturn(viewAbove);
    OCMStub([viewAbove backgroundColor]).andReturn(UIColor.blackColor);
    OCMStub([viewAbove isHidden]).andReturn(NO);
    OCMStub([viewAbove window]).andReturn(windowAbove);
    OCMStub([windowAbove rootViewController]).andReturn(viewControllerAbove);
    OCMStub([adViewController view]).andReturn(adView);
    NSMutableArray *windows = [[NSMutableArray alloc] init];
    [windows addObject:window];
    [windows addObject:windowAbove];
    OCMStub([application windows]).andReturn(windows);

    OGAAdExposureController *exposureController =
        [[OGAAdExposureController alloc] initWithApplication:application
                                            keyboardObserver:[OGAKeyboardObserver shared]
                                          notificationCenter:NSNotificationCenter.defaultCenter
                                                 exposedView:adView
                                               exposedWindow:window
                                parentViewControllerProvider:^UIViewController * {
                                    return nil;
                                }];

    OGAAdExposure *exposure = [exposureController getExposure];
    XCTAssertTrue(exposure.exposurePercentage > 0.99);
}

- (void)testGetExposureWindowsHiddenWithNoParent {
    UIViewController *adViewController = OCMClassMock([UIViewController class]);
    UIView *adView = OCMClassMock([UIView class]);
    OCMStub([adView frame]).andReturn(CGRectMake(0, 0, 100, 100));
    id application = OCMClassMock([UIApplication class]);
    OCMStub([application applicationState]).andReturn(UIApplicationStateActive);
    UIWindow *window = OCMClassMock([UIWindow class]);
    OCMStub([window rootViewController]).andReturn(adViewController);
    OCMStub([window frame]).andReturn(CGRectMake(0, 0, 100, 100));
    UIWindow *windowAbove = OCMClassMock([UIWindow class]);
    OCMStub([windowAbove frame]).andReturn(CGRectMake(0, 0, 50, 100));
    OCMStub([windowAbove alpha]).andReturn(1);
    OCMStub([windowAbove isHidden]).andReturn(YES);
    UIViewController *viewControllerAbove = OCMClassMock([UIViewController class]);
    UIView *viewAbove = OCMClassMock([UIView class]);
    OCMStub([viewControllerAbove view]).andReturn(viewAbove);
    OCMStub([viewAbove backgroundColor]).andReturn(UIColor.blackColor);
    OCMStub([viewAbove isHidden]).andReturn(NO);
    OCMStub([viewAbove window]).andReturn(windowAbove);
    OCMStub([windowAbove rootViewController]).andReturn(viewControllerAbove);
    OCMStub([adViewController view]).andReturn(adView);
    NSMutableArray *windows = [[NSMutableArray alloc] init];
    [windows addObject:window];
    [windows addObject:windowAbove];
    OCMStub([application windows]).andReturn(windows);

    OGAAdExposureController *exposureController =
        [[OGAAdExposureController alloc] initWithApplication:application
                                            keyboardObserver:[OGAKeyboardObserver shared]
                                          notificationCenter:NSNotificationCenter.defaultCenter
                                                 exposedView:adView
                                               exposedWindow:window
                                parentViewControllerProvider:^UIViewController * {
                                    return nil;
                                }];

    OGAAdExposure *exposure = [exposureController getExposure];
    XCTAssertTrue(exposure.exposurePercentage > 0.99);
}

- (void)testGetExposureWindowsWithViewControllerHiddenWithNoParent {
    UIViewController *adViewController = OCMClassMock([UIViewController class]);
    UIView *adView = OCMClassMock([UIView class]);
    OCMStub([adView frame]).andReturn(CGRectMake(0, 0, 100, 100));
    id application = OCMClassMock([UIApplication class]);
    OCMStub([application applicationState]).andReturn(UIApplicationStateActive);
    UIWindow *window = OCMClassMock([UIWindow class]);
    OCMStub([window rootViewController]).andReturn(adViewController);
    OCMStub([window frame]).andReturn(CGRectMake(0, 0, 100, 100));
    UIWindow *windowAbove = OCMClassMock([UIWindow class]);
    OCMStub([windowAbove frame]).andReturn(CGRectMake(0, 0, 50, 100));
    OCMStub([windowAbove alpha]).andReturn(1);
    OCMStub([windowAbove backgroundColor]).andReturn(UIColor.blackColor);
    UIViewController *viewControllerAbove = OCMClassMock([UIViewController class]);
    UIView *viewAbove = OCMClassMock([UIView class]);
    OCMStub([viewControllerAbove view]).andReturn(viewAbove);
    OCMStub([viewAbove backgroundColor]).andReturn(UIColor.blackColor);
    OCMStub([viewAbove isHidden]).andReturn(YES);
    OCMStub([viewAbove window]).andReturn(windowAbove);
    OCMStub([windowAbove rootViewController]).andReturn(viewControllerAbove);
    OCMStub([adViewController view]).andReturn(adView);
    NSMutableArray *windows = [[NSMutableArray alloc] init];
    [windows addObject:window];
    [windows addObject:windowAbove];
    OCMStub([application windows]).andReturn(windows);

    OGAAdExposureController *exposureController =
        [[OGAAdExposureController alloc] initWithApplication:application
                                            keyboardObserver:[OGAKeyboardObserver shared]
                                          notificationCenter:NSNotificationCenter.defaultCenter
                                                 exposedView:adView
                                               exposedWindow:window
                                parentViewControllerProvider:^UIViewController * {
                                    return nil;
                                }];

    OGAAdExposure *exposure = [exposureController getExposure];
    XCTAssertTrue(exposure.exposurePercentage > 0.99);
}

- (void)testGetExposureWindowsWithViewControllerTransparentWithNoParent {
    UIViewController *adViewController = OCMClassMock([UIViewController class]);
    UIView *adView = OCMClassMock([UIView class]);
    OCMStub([adView frame]).andReturn(CGRectMake(0, 0, 100, 100));
    id application = OCMClassMock([UIApplication class]);
    OCMStub([application applicationState]).andReturn(UIApplicationStateActive);
    UIWindow *window = OCMClassMock([UIWindow class]);
    OCMStub([window rootViewController]).andReturn(adViewController);
    OCMStub([window frame]).andReturn(CGRectMake(0, 0, 100, 100));
    UIWindow *windowAbove = OCMClassMock([UIWindow class]);
    OCMStub([windowAbove frame]).andReturn(CGRectMake(0, 0, 50, 100));
    OCMStub([windowAbove alpha]).andReturn(1);
    OCMStub([windowAbove backgroundColor]).andReturn(UIColor.blackColor);
    UIViewController *viewControllerAbove = OCMClassMock([UIViewController class]);
    UIView *viewAbove = OCMClassMock([UIView class]);
    OCMStub([viewControllerAbove view]).andReturn(viewAbove);
    OCMStub([viewAbove backgroundColor]).andReturn(UIColor.clearColor);
    OCMStub([viewAbove isHidden]).andReturn(NO);
    OCMStub([viewAbove window]).andReturn(windowAbove);
    OCMStub([windowAbove rootViewController]).andReturn(viewControllerAbove);
    OCMStub([adViewController view]).andReturn(adView);
    NSMutableArray *windows = [[NSMutableArray alloc] init];
    [windows addObject:window];
    [windows addObject:windowAbove];
    OCMStub([application windows]).andReturn(windows);

    OGAAdExposureController *exposureController =
        [[OGAAdExposureController alloc] initWithApplication:application
                                            keyboardObserver:[OGAKeyboardObserver shared]
                                          notificationCenter:NSNotificationCenter.defaultCenter
                                                 exposedView:adView
                                               exposedWindow:window
                                parentViewControllerProvider:^UIViewController * {
                                    return nil;
                                }];

    OGAAdExposure *exposure = [exposureController getExposure];
    XCTAssertTrue(exposure.exposurePercentage > 0.99);
}

- (void)testGetExposureWindowsWithParent {
    UIViewController *parentViewController = OCMClassMock([UIViewController class]);
    UIViewController *adViewController = OCMClassMock([UIViewController class]);
    UIView *adView = OCMClassMock([UIView class]);
    OCMStub([adView frame]).andReturn(CGRectMake(0, 0, 100, 100));
    id application = OCMClassMock([UIApplication class]);
    OCMStub([application applicationState]).andReturn(UIApplicationStateActive);
    UIWindow *window = OCMClassMock([UIWindow class]);
    OCMStub([window rootViewController]).andReturn(adViewController);
    OCMStub([window frame]).andReturn(CGRectMake(0, 0, 100, 100));
    UIWindow *windowAbove = OCMClassMock([UIWindow class]);
    OCMStub([windowAbove frame]).andReturn(CGRectMake(0, 0, 50, 100));
    OCMStub([windowAbove alpha]).andReturn(1);
    OCMStub([windowAbove backgroundColor]).andReturn(UIColor.blackColor);
    UIViewController *viewControllerAbove = OCMClassMock([UIViewController class]);
    UIView *viewAbove = OCMClassMock([UIView class]);
    OCMStub([viewControllerAbove view]).andReturn(viewAbove);
    OCMStub([viewAbove backgroundColor]).andReturn(UIColor.blackColor);
    OCMStub([viewAbove isHidden]).andReturn(NO);
    OCMStub([viewAbove window]).andReturn(windowAbove);
    OCMStub([windowAbove rootViewController]).andReturn(viewControllerAbove);
    OCMStub([adViewController view]).andReturn(adView);
    NSMutableArray *windows = [[NSMutableArray alloc] init];
    [windows addObject:window];
    [windows addObject:windowAbove];
    OCMStub([application windows]).andReturn(windows);

    OGAAdExposureController *exposureController =
        [[OGAAdExposureController alloc] initWithApplication:application
                                            keyboardObserver:[OGAKeyboardObserver shared]
                                          notificationCenter:NSNotificationCenter.defaultCenter
                                                 exposedView:adView
                                               exposedWindow:window
                                parentViewControllerProvider:^UIViewController * {
                                    return parentViewController;
                                }];

    OGAAdExposure *exposure = [exposureController getExposure];
    XCTAssertTrue(fabs(exposure.exposurePercentage - 50) < 0.001);
}

- (void)testGetExposureWindowsWithParentWithOtherView {
    UIViewController *parentViewController = OCMClassMock([UIViewController class]);
    UIView *parentView = OCMClassMock([UIView class]);
    OCMStub([parentViewController view]).andReturn(parentView);
    UIViewController *adViewController = OCMClassMock([UIViewController class]);
    UIView *adView = OCMClassMock([UIView class]);
    OCMStub([adView frame]).andReturn(CGRectMake(0, 0, 100, 100));
    OCMStub([adView bounds]).andReturn(CGRectMake(0, 0, 100, 100));
    id application = OCMClassMock([UIApplication class]);
    OCMStub([application applicationState]).andReturn(UIApplicationStateActive);
    UIWindow *window = OCMClassMock([UIWindow class]);
    OCMStub([window rootViewController]).andReturn(adViewController);
    OCMStub([window frame]).andReturn(CGRectMake(0, 0, 100, 100));
    UIWindow *windowAbove = OCMClassMock([UIWindow class]);
    OCMStub([windowAbove frame]).andReturn(CGRectMake(0, 0, 50, 100));
    OCMStub([windowAbove alpha]).andReturn(1);
    OCMStub([windowAbove backgroundColor]).andReturn(UIColor.blackColor);
    UIViewController *viewControllerAbove = OCMClassMock([UIViewController class]);
    UIView *viewAbove = OCMClassMock([UIView class]);
    OCMStub([viewControllerAbove view]).andReturn(viewAbove);
    OCMStub([viewAbove window]).andReturn(windowAbove);
    OCMStub([viewAbove backgroundColor]).andReturn(UIColor.blackColor);
    OCMStub([viewAbove isHidden]).andReturn(NO);
    OCMStub([windowAbove rootViewController]).andReturn(viewControllerAbove);
    NSMutableArray *windows = [[NSMutableArray alloc] init];
    [windows addObject:window];
    [windows addObject:windowAbove];
    OCMStub([application windows]).andReturn(windows);

    UIView *otherViewAboveInsideParent = OCMClassMock([UIView class]);
    OCMStub([otherViewAboveInsideParent frame]).andReturn(CGRectMake(50, 0, 50, 50));
    OCMStub([otherViewAboveInsideParent backgroundColor]).andReturn(UIColor.blackColor);
    OCMStub([otherViewAboveInsideParent isHidden]).andReturn(NO);
    OCMStub([otherViewAboveInsideParent alpha]).andReturn(1);

    NSArray *subViews = [[NSArray alloc] initWithObjects:adView, otherViewAboveInsideParent, nil];
    OCMStub([parentView subviews]).andReturn(subViews);
    OCMStub([adView isDescendantOfView:parentView]).andReturn(YES);

    OCMStub([parentView convertRect:CGRectMake(0, 0, 100, 100) fromView:adView]).andReturn(CGRectMake(0, 0, 100, 100));

    OGAAdExposureController *exposureController =
        [[OGAAdExposureController alloc] initWithApplication:application
                                            keyboardObserver:[OGAKeyboardObserver shared]
                                          notificationCenter:NSNotificationCenter.defaultCenter
                                                 exposedView:adView
                                               exposedWindow:window
                                parentViewControllerProvider:^UIViewController * {
                                    return parentViewController;
                                }];

    OGAAdExposure *exposure = [exposureController getExposure];
    XCTAssertTrue(fabs(exposure.exposurePercentage - 25) < 0.001);
}

- (void)testGetExposureKeyboard {
    UIViewController *parentViewController = OCMClassMock([UIViewController class]);
    UIViewController *adViewController = OCMClassMock([UIViewController class]);
    UIView *adView = OCMClassMock([UIView class]);
    OCMStub([adView frame]).andReturn(CGRectMake(0, 0, 100, 100));
    id application = OCMClassMock([UIApplication class]);
    OCMStub([application applicationState]).andReturn(UIApplicationStateActive);
    UIWindow *window = OCMClassMock([UIWindow class]);
    OCMStub([window rootViewController]).andReturn(adViewController);
    OCMStub([window frame]).andReturn(CGRectMake(0, 0, 100, 100));
    UIWindow *windowAbove = OCMClassMock([UIWindow class]);
    OCMStub([windowAbove frame]).andReturn(CGRectMake(0, 0, 50, 100));
    OCMStub([adViewController view]).andReturn(adView);
    NSMutableArray *windows = [[NSMutableArray alloc] init];
    [windows addObject:window];
    [windows addObject:windowAbove];
    OCMStub([application windows]).andReturn(windows);
    CGRect keyboardFrame = CGRectMake(50, 0, 25, 100);
    OGAKeyboardObserver *keyboardObserver = OCMClassMock([OGAKeyboardObserver class]);
    OCMStub([keyboardObserver keyboardOnScreen]).andReturn(TRUE);
    OCMStub([keyboardObserver keyboardRect]).andReturn([NSValue valueWithCGRect:keyboardFrame]);

    OGAAdExposureController *exposureController =
        OCMPartialMock([[OGAAdExposureController alloc] initWithApplication:application
                                                           keyboardObserver:keyboardObserver
                                                         notificationCenter:NSNotificationCenter.defaultCenter
                                                                exposedView:adView
                                                              exposedWindow:window
                                               parentViewControllerProvider:^UIViewController * {
                                                   return parentViewController;
                                               }]);

    OGAAdExposure *exposure = [exposureController getExposure];
    XCTAssertTrue(fabs(exposure.exposurePercentage - 75) < 0.001);
}

- (void)testDelegateCallStartExposure {
    UIViewController *rootViewController = OCMClassMock([UIViewController class]);
    id application = OCMClassMock([UIApplication class]);
    OCMStub([application sharedApplication]).andReturn(application);
    OCMStub([application applicationState]).andReturn(UIApplicationStateBackground);

    OGAAdExposureController *exposureController =
        OCMPartialMock([[OGAAdExposureController alloc] initWithApplication:application
                                                           keyboardObserver:[OGAKeyboardObserver shared]
                                                         notificationCenter:NSNotificationCenter.defaultCenter
                                                                exposedView:[[UIView alloc] init]
                                                              exposedWindow:[[UIWindow alloc] init]
                                               parentViewControllerProvider:^UIViewController * {
                                                   return rootViewController;
                                               }]);

    [exposureController startExposure];
    OCMVerify([exposureController computeExposure]);
}

- (void)testDelegateCallStopExposure {
    UIViewController *rootViewController = OCMClassMock([UIViewController class]);
    id application = OCMClassMock([UIApplication class]);
    OCMStub([application sharedApplication]).andReturn(application);
    OCMStub([application applicationState]).andReturn(UIApplicationStateBackground);

    OGAAdExposureController *exposureController =
        OCMPartialMock([[OGAAdExposureController alloc] initWithApplication:application
                                                           keyboardObserver:[OGAKeyboardObserver shared]
                                                         notificationCenter:NSNotificationCenter.defaultCenter
                                                                exposedView:[[UIView alloc] init]
                                                              exposedWindow:[[UIWindow alloc] init]
                                               parentViewControllerProvider:^UIViewController * {
                                                   return rootViewController;
                                               }]);

    [exposureController stopExposure];
    OCMVerify([exposureController computeExposure]);
}

- (void)testGetParentViewController_ViewInViewController {
    UIViewController *parentViewController = OCMClassMock([UIViewController class]);
    UIViewController *viewController = OCMClassMock([UIViewController class]);
    UIView *adView = OCMClassMock([UIView class]);
    UIView *viewFromVC = OCMClassMock([UIView class]);
    OCMStub([parentViewController presentedViewController]).andReturn(viewController);
    OCMStub(viewController.view).andReturn(viewFromVC);
    OCMStub([adView isDescendantOfView:viewFromVC]).andReturn(YES);

    XCTAssertEqual(viewController, [OGAAdExposureController getParentViewControllerFor:adView referentViewController:parentViewController]);
}

- (void)testGetParentViewController_ViewInParentViewController {
    UIViewController *parentViewController = OCMClassMock([UIViewController class]);
    UIViewController *viewController = OCMClassMock([UIViewController class]);
    UIView *adView = OCMClassMock([UIView class]);
    UIView *viewFromVC = OCMClassMock([UIView class]);
    OCMStub([parentViewController presentedViewController]).andReturn(viewController);
    OCMStub(parentViewController.view).andReturn(viewFromVC);
    OCMStub([adView isDescendantOfView:viewFromVC]).andReturn(YES);

    XCTAssertEqual(parentViewController, [OGAAdExposureController getParentViewControllerFor:adView referentViewController:parentViewController]);
}

- (void)testGetParentViewController_ViewNotInViewController {
    UIViewController *parentViewController = OCMClassMock([UIViewController class]);
    UIViewController *viewController = OCMClassMock([UIViewController class]);
    UIView *adView = OCMClassMock([UIView class]);
    UIView *viewFromVC = OCMClassMock([UIView class]);
    OCMStub([parentViewController presentedViewController]).andReturn(viewController);
    OCMStub(parentViewController.view).andReturn(viewFromVC);
    OCMStub([adView isDescendantOfView:viewFromVC]).andReturn(NO);

    XCTAssertNil([OGAAdExposureController getParentViewControllerFor:adView referentViewController:parentViewController]);
}

@end
