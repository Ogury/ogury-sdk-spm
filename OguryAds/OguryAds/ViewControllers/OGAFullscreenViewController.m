//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAFullscreenViewController.h"
#import "OGAAd.h"
#import "UIColor+OGAString.h"
#import "OGAAdDisplayerUpdateMaxSizeInformation.h"
#import "OGAAdDisplayerUpdateScreenSizeInformation.h"
#import "OGADeviceService.h"
#import "OGAAdDisplayerUpdateCurrentAppOrientationInformation.h"
#import "OGAAdDisplayerUpdateCurrentPositionInformation.h"
#import "OGAMraidAdWebView.h"
#import "OGAViewControllerOrientationHelper.h"

@interface OGAFullscreenViewController ()

@property(nonatomic, strong) OGADeviceService *deviceService;
@property(nonatomic, weak) id<OGAAdDisplayer> displayer;
@property(nonatomic, assign, nonnull) NSNotificationCenter *notificationCenter;
@property(nonatomic, nullable) NSNumber *forcedOrientationMask;
@property(nonatomic) BOOL allowOrientationUpdates;

@end

@implementation OGAFullscreenViewController

- (instancetype)initWithExposureController:(OGAAdExposureController *)exposureController deviceService:(OGADeviceService *)deviceService notificationCenter:(NSNotificationCenter *)notificationCenter {
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        _notificationCenter = notificationCenter;
        _exposureController = exposureController;
        _exposureController.exposedView = self.view;
        _exposureController.exposedWindow = self.view.window;
        _deviceService = deviceService;
        _allowOrientationUpdates = YES;
        [_notificationCenter addObserver:self selector:@selector(deviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (instancetype)initWithExposureController:(OGAAdExposureController *)exposureController {
    return [self initWithExposureController:exposureController deviceService:[[OGADeviceService alloc] init] notificationCenter:[NSNotificationCenter defaultCenter]];
}

#pragma mark - Methods

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return _forcedOrientationMask != nil ? [[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:_forcedOrientationMask] : [OGAAd supportedOrientationForAd:self.displayer.ad];
}

- (BOOL)shouldAutorotate {
    return _allowOrientationUpdates;
}

- (BOOL)display:(id<OGAAdDisplayer>)displayer error:(OguryError *_Nullable *_Nullable)error {
    self.displayer = displayer;
    // handles the setOrientationProperties of the MRaid command
    self.displayer.orientationDelegate = (id<OGAAdDisplayerOrientationDelegate>)self;
    self.view.backgroundColor = [UIColor colorFromString:displayer.ad.sdkBackgroundColor];
    displayer.view.translatesAutoresizingMaskIntoConstraints = NO;
    displayer.view.frame = self.view.frame;
    [self.view addSubview:displayer.view];
    if (@available(iOS 11, *)) {
        [NSLayoutConstraint activateConstraints:@[
            [displayer.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [displayer.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
            [displayer.view.rightAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.rightAnchor],
            [displayer.view.leftAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leftAnchor]
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [displayer.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
            [displayer.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
            [displayer.view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
            [displayer.view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor]
        ]];
    }
    [self.displayer registerForVolumeChange];
    return YES;
}

- (void)deviceOrientationChange:(NSNotification *)notification {
    [self sendScreenOrientationChange:[UIScreen mainScreen].bounds.size];
}

- (void)sendScreenOrientationChange:(CGSize)size {
    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateMaxSizeInformation alloc] initWithSize:size]];
    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateScreenSizeInformation alloc] initWithSize:size]];
    [self sendCurrentOrientation];
    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateCurrentPositionInformation alloc] initWithPosition:CGPointZero size:size]];
}

- (void)sendCurrentOrientation {
    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateCurrentAppOrientationInformation alloc] initWithOrientation:[self.deviceService interfaceOrientation] locked:false]];
}

- (void)cleanUp {
    [self.notificationCenter removeObserver:self];
}

#pragma mark - OGAAdDisplayerOrientationDelegate
- (void)forceOrientation:(UIInterfaceOrientationMask)orientation {
    return [self forceOrientation:orientation orientationHelper:[OGAViewControllerOrientationHelper new]];
}

- (void)forceOrientation:(UIInterfaceOrientationMask)orientation orientationHelper:(OGAViewControllerOrientationHelper *)helper {
    if ([helper orientationIsSupportedByApplication:orientation]) {
        _forcedOrientationMask = [NSNumber numberWithUnsignedInteger:orientation];
        if (@available(iOS 16.0, *)) {
            [self setNeedsUpdateOfSupportedInterfaceOrientations];
        } else {
            UIInterfaceOrientation newOrientation = [[OGAViewControllerOrientationHelper new]
                orientationFromInterfaceOrientationMask:orientation];
            [UIDevice.currentDevice setValue:[NSNumber numberWithUnsignedInteger:newOrientation]
                                      forKey:@"orientation"];
            [UIViewController attemptRotationToDeviceOrientation];
        }
        [self sendCurrentOrientation];
    }
}

- (void)allowOrientationChange:(BOOL)allowOrientationChange {
    _allowOrientationUpdates = allowOrientationChange;
    // retrieve the orientation from the ad
    UIInterfaceOrientationMask supportedMask = [OGAAd supportedOrientationForAd:self.displayer.ad];
    // if Mraid asked to force the orientation, iOS16 has a brand new way of triggering the rotation
    // in this case, if the mask is all, then we force the mask to the current one
    if (supportedMask == UIInterfaceOrientationMaskAll && allowOrientationChange == NO) {
        supportedMask = self.supportedInterfaceOrientations;
    }
    _forcedOrientationMask = [NSNumber numberWithUnsignedInteger:supportedMask];
    if (@available(iOS 16.0, *)) {
        [self setNeedsUpdateOfSupportedInterfaceOrientations];
    } else {
        UIInterfaceOrientation newOrientation = [[OGAViewControllerOrientationHelper new]
            orientationFromInterfaceOrientationMask:supportedMask];
        [UIDevice.currentDevice setValue:[NSNumber numberWithUnsignedInteger:newOrientation]
                                  forKey:@"orientation"];
        [UIViewController attemptRotationToDeviceOrientation];
    }
    [self sendCurrentOrientation];
}

@end
