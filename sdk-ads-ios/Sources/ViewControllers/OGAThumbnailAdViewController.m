//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "OGAThumbnailAdViewController.h"
#import "OGAThumbnailAdViewController+Position.h"
#import "OGAThumbnailAdViewController+Exposure.h"
#import "OGAAdDisplayerUpdateViewabilityInformation.h"
#import "OGAAdDisplayerUpdateMaxSizeInformation.h"
#import "OGAThumbnailAdWindow.h"
#import "OGAAd.h"
#import "OGAMraidUtils.h"
#import "OGAThumbnailAdConstants.h"
#import "OGALog.h"
#import "OGAAdExposureController.h"
#import "OGAThumbnailAdRestrictionsManager.h"
#import "OGAAdDisplayerSystemCloseInformation.h"
#import "OGAForceCloseAdAction.h"
#import "OGASizeSafeAreaController.h"
#import "OGAAdImpressionManager.h"
#import "UIColor+OGAString.h"
#import "OGAThumbnailAdViewController+CachedPosition.h"
#import "OGAThumbnailAdCachedPositionObject.h"
#import "OGADeviceService.h"
#import "OGAViewControllerOrientationHelper.h"
#import "OGAThumbnailAdViewController+Position.h"

@interface OGAThumbnailAdViewController ()

@property(nonatomic, weak, nullable) OGAThumbnailAdWindow *window;
@property(nonatomic, strong) OGAThumbnailAdRestrictionsManager *restrictionManager;
@property(nonatomic, strong) NSNotificationCenter *notificationCenter;
@property(nonatomic, strong) OGASizeSafeAreaController *safeAreaController;
@property(nonatomic, strong) OGAAdImpressionManager *impressionManager;
@property(nonatomic, weak, nullable, readwrite) id<OGAAdDisplayer> displayer;
@property(nonatomic, strong) OGAAdExposureController *exposureController;
@property(nonatomic, strong) UIPanGestureRecognizer *moveThumbnailAdPanGesture;
@property(nonatomic, assign) CGSize thumbnailSize;
@property(nonatomic, assign) CGPoint thumbnailPosition;
@property(nonatomic, assign) BOOL keyboardOnScreen;
@property(nonatomic, assign) CGRect keyboardRect;
@property(nonatomic, assign) OguryOffset offsetRatio;
@property(nonatomic, assign) OguryRectCorner rectCorner;
@property(nonatomic, assign) BOOL hasLoadedThumbnailAdView;
@property(nonatomic, strong) NSArray<NSLayoutConstraint *> *normalConstraint;
@property(nonatomic, strong) NSArray<NSLayoutConstraint *> *expandedConstraint;
@property(nonatomic, strong) NSUserDefaults *userDefaults;
@property(nonatomic, strong) NSString *customThumbnailCachedPositionKey;
@property(nonatomic, strong) OGAThumbnailAdCachedPositionObject *cachedThumbnailAdPosition;
@property(nonatomic, strong) OGADeviceService *deviceService;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, nullable) NSNumber *forcedOrientationMask;
@property(nonatomic) BOOL allowOrientationUpdates;

@end

@implementation OGAThumbnailAdViewController

- (instancetype)initWithWindow:(OGAThumbnailAdWindow *)window {
    return [self initWithWindow:window
             restrictionManager:[[OGAThumbnailAdRestrictionsManager alloc] init]
             notificationCenter:[NSNotificationCenter defaultCenter]
             safeAreaController:[[OGASizeSafeAreaController alloc] init]
              impressionManager:[OGAAdImpressionManager shared]
                  deviceService:[[OGADeviceService alloc] init]
                   userDefaults:NSUserDefaults.standardUserDefaults
                            log:[OGALog shared]];
}

- (instancetype)initWithWindow:(OGAThumbnailAdWindow *)window
            restrictionManager:(OGAThumbnailAdRestrictionsManager *)restrictionManager
            notificationCenter:(NSNotificationCenter *)notificationCenter
            safeAreaController:(OGASizeSafeAreaController *)safeAreaController
             impressionManager:(OGAAdImpressionManager *)impressionManager
                 deviceService:(OGADeviceService *)deviceService
                  userDefaults:(NSUserDefaults *)userDefaults
                           log:(OGALog *)log {
    if (self = [super init]) {
        _window = window;
        _keyboardOnScreen = NO;
        _hasLoadedThumbnailAdView = NO;
        _restrictionManager = restrictionManager;
        _notificationCenter = notificationCenter;
        _safeAreaController = safeAreaController;
        _impressionManager = impressionManager;
        _userDefaults = userDefaults;
        _deviceService = deviceService;
        _log = log;
        _allowOrientationUpdates = YES;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [_notificationCenter addObserver:self selector:@selector(deviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTransparentBackground];
    [self addAdVisibilityObserver];
    [self initThumbnailSize];
    if (![self updateToCachedThumbnailAdPositionWithAdUnitId:self.displayer.ad.adUnit.identifier]) {
        [self setupThumbnailPosition];
    }
    [self updateThumbnailAdWithAnimation:(NO)];
    [self addMoveNotification];
    self.hasLoadedThumbnailAdView = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateViewabilityInformation alloc] initWithViewability:YES]];
    [self sendAdExposure];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return _forcedOrientationMask != nil ? [[OGAViewControllerOrientationHelper new] orientationMaskFromRawValue:_forcedOrientationMask] : [OGAAd supportedOrientationForAd:self.displayer.ad];
}

- (BOOL)shouldAutorotate {
    return _allowOrientationUpdates;
}

- (void)setupTransparentBackground {
    self.view.backgroundColor = UIColor.clearColor;
}

- (void)deviceOrientationChange:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.window.isExpanded) {
            [self applyOffsetToPosition];
            [self checkThumbnailCorrectPosition];
            [self updateThumbnailAdWithAnimation:NO];
        }
        [self sendScreenOrientationChange:[self getScreenSize]];
        OGAAdDisplayerUpdateMaxSizeInformation *maxSizeInformation = [[OGAAdDisplayerUpdateMaxSizeInformation alloc] initWithSize:UIScreen.mainScreen.bounds.size];
        [self.displayer dispatchInformation:maxSizeInformation];
        [self sendAdExposure];
    });
}

- (void)addAdVisibilityObserver {
    [self.notificationCenter addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(keyboardOffScreen:) name:UIKeyboardWillHideNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(viewControllerListUpdated) name:OGAViewControllersUpdated object:nil];
}

- (void)keyboardOffScreen:(NSNotification *)notification {
    self.keyboardOnScreen = NO;
    self.keyboardRect = CGRectZero;
}

- (void)keyboardOnScreen:(NSNotification *)notification {
    self.keyboardOnScreen = YES;

    self.keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self updateThumbnailAdFrameBasedOnKeyboard];
}

- (void)updateThumbnailAdFrameBasedOnKeyboard {
    if ([self isMinimumVisibleScreen]) {
        [self checkThumbnailCorrectPosition];
        [self updateThumbnailAdWithAnimation:NO];
    }
}

- (void)updateThumbnailAdWithAnimation:(BOOL)animation {
    // Thumbnail ad should not reposition nor resize when it is expanded.
    if (self.window.isExpanded) {
        return;
    }

    CGFloat animationDuration = 0;
    if (animation && !self.keyboardOnScreen) {
        animationDuration = 0.4;
    }

    [UIView animateWithDuration:animationDuration
        delay:0
        options:UIViewAnimationOptionCurveLinear
        animations:^{
            [self.window setFrame:CGRectMake(self.thumbnailPosition.x, self.thumbnailPosition.y, self.thumbnailSize.width, self.thumbnailSize.height)];
        }
        completion:^(BOOL finished) {
            [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                 adConfiguration:nil
                                                         logType:OguryLogTypeInternal
                                                         message:@"Update thumbnail position"
                                                            tags:@[
                                                                [OguryLogTag tagWithKey:@"Size"
                                                                                  value:NSStringFromCGSize(self.thumbnailSize)],
                                                                [OguryLogTag tagWithKey:@"Position"
                                                                                  value:NSStringFromCGPoint(self.thumbnailPosition)]
                                                            ]]];
            [self sendAdExposure];
        }];
}

- (void)viewControllerListUpdated {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:nil
                                                 logType:OguryLogTypeInternal
                                                 message:@"viewControllerListUpdated"
                                                    tags:nil]];
    if (self.window.isExpanded) {
        return;
    }
    BOOL shouldRestrict = [self.restrictionManager shouldRestrict:self.displayer.configuration.blackListViewControllers
                                                 whiteListBundles:self.displayer.configuration.whitelistBundleIdentifiers];

    if (shouldRestrict) {
        [self pauseAd];
    } else {
        [self resumeAd];
    }
}

- (BOOL)display:(id<OGAAdDisplayer>)displayer error:(OguryError *_Nullable *_Nullable)error {
    if (!self.hasLoadedThumbnailAdView) {
        self.displayer = displayer;
        // handles the setOrientationProperties of the MRaid command
        self.displayer.orientationDelegate = (id<OGAAdDisplayerOrientationDelegate>)self;
        [self setupThumbnailConstraintsWithDisplayer:displayer];
        self.displayer.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.displayer.view];
        self.view.backgroundColor = nil;
        [NSLayoutConstraint activateConstraints:self.normalConstraint];
        [self setupExposureController:[[OGAAdExposureController alloc] initWithExposedView:displayer.view
                                                                             exposedWindow:self.window
                                                              parentViewControllerProvider:^UIViewController *(void) {
                                                                  return nil;
                                                              }]];
        [self.displayer registerForVolumeChange];
    } else {
        [self applyOffsetToPosition];
        [self updateThumbnailAdWithAnimation:(NO)];
    }
    return YES;
}

- (void)updateThumbnailToExpandedFormatWithDisplayer:(id<OGAAdDisplayer>)displayer {
    self.view.backgroundColor = [UIColor colorFromString:displayer.ad.sdkBackgroundColor];
    if (@available(iOS 11, *)) {
        [NSLayoutConstraint deactivateConstraints:self.normalConstraint];
        [NSLayoutConstraint activateConstraints:self.expandedConstraint];
    }
}

- (void)updateThumbnailWithDisplayer:(id<OGAAdDisplayer>)displayer {
    self.view.backgroundColor = nil;
    if (@available(iOS 11, *)) {
        [NSLayoutConstraint activateConstraints:self.normalConstraint];
        [NSLayoutConstraint deactivateConstraints:self.expandedConstraint];
    }
}

- (void)setupThumbnailConstraintsWithDisplayer:(id<OGAAdDisplayer>)displayer {
    self.normalConstraint = @[
        [self.displayer.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.displayer.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.displayer.view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
        [self.displayer.view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor]
    ];
    if (@available(iOS 11, *)) {
        self.expandedConstraint = @[
            [displayer.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
            [displayer.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
            [displayer.view.rightAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.rightAnchor],
            [displayer.view.leftAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leftAnchor]
        ];
    }
}

- (void)setupExposureController:(OGAAdExposureController *)exposureController {
    self.exposureController = exposureController;
    if (exposureController) {
        self.exposureController.delegate = self;
    }
}

- (void)addMoveNotification {
    if (self.window) {
        self.moveThumbnailAdPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveObject:)];
        self.moveThumbnailAdPanGesture.minimumNumberOfTouches = 1;
        [self.window addGestureRecognizer:self.moveThumbnailAdPanGesture];
    }
}

- (void)moveObject:(UIPanGestureRecognizer *)recognizer {
    if (![self.displayer.ad.thumbnailAdResponse.draggable boolValue] || !self.window.isDraggable || self.window.isExpanded) {
        return;
    }

    CGPoint translation = [recognizer translationInView:self.window];
    CGPoint newLocation = CGPointMake(recognizer.view.frame.origin.x + translation.x, recognizer.view.frame.origin.y + translation.y);
    if ([self canMoveToPoint:newLocation] == OGAInvalidPositionNone) {
        recognizer.view.frame = CGRectMake(newLocation.x, newLocation.y, recognizer.view.frame.size.width, recognizer.view.frame.size.height);
    }

    [recognizer setTranslation:CGPointZero inView:self.window];

    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.thumbnailPosition = newLocation;
        [self updateOffsetRatio];
        [self cacheThumbnailAdPosition];
        [self sendAdExposure];
    }
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
        //    _allowOrientationUpdates = YES;
        _forcedOrientationMask = [NSNumber numberWithUnsignedInteger:orientation];
        if (@available(iOS 16.0, *)) {
            [self setNeedsUpdateOfSupportedInterfaceOrientations];
        } else {
            UIInterfaceOrientation newOrientation = [[OGAViewControllerOrientationHelper new] orientationFromInterfaceOrientationMask:orientation];
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
        [UIDevice.currentDevice setValue:[NSNumber numberWithUnsignedInteger:
                                                       [[OGAViewControllerOrientationHelper new] orientationFromInterfaceOrientationMask:supportedMask]]
                                  forKey:@"orientation"];
        [UIViewController attemptRotationToDeviceOrientation];
    }
    [self sendCurrentOrientation];
}

@end
