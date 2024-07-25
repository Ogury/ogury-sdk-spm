//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGABaseAdContainerState.h"

#import "OGAAdDisplayerSystemCloseInformation.h"
#import "OGAForceCloseAdAction.h"
#import "OGALog.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAAdConfiguration.h"
#import "OGAAdDisplayerUpdateViewabilityInformation.h"
#import "OGAFullscreenViewController.h"

@interface OGABaseAdContainerState ()

@property(nonatomic, strong) id<OGAAdDisplayer> displayer;
@property(nonatomic, assign) BOOL currentViewabilityStatus;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGABaseAdContainerState

#pragma mark - Properties

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnreachableCode"

- (NSString *)name {
    [NSException raise:@"MustOverride" format:@"Must be overriden by subclasses"];
    return @"";
}

- (OGAAdContainerStateType)type {
    [NSException raise:@"MustOverride" format:@"Must be overriden by subclasses"];
    return OGAAdContainerStateTypeUnknown;
}

- (OGAAdExposureController *)exposureController {
    [NSException raise:@"MustOverride" format:@"Must be overriden by subclasses"];
    return nil;
}

- (BOOL)isExpanded {
    return NO;
}

#pragma clang diagnostic pop

#pragma mark - Initialization

- (instancetype)initWithViewProvider:(UIView *_Nullable (^)(void))viewProvider viewControllerProvider:(UIViewController *_Nullable (^)(void))viewControllerProvider {
    return [self initWithViewProvider:viewProvider
               viewControllerProvider:viewControllerProvider
                 impressionController:[OGAAdImpressionManager shared]
                            profigDao:[OGAProfigDao shared]
                   notificationCenter:NSNotificationCenter.defaultCenter
                                  log:[OGALog shared]];
}

- (instancetype)initWithViewProvider:(UIView *_Nullable (^)(void))viewProvider
              viewControllerProvider:(UIViewController *_Nullable (^)(void))viewControllerProvider
                impressionController:(OGAAdImpressionManager *)impressionController
                           profigDao:(OGAProfigDao *)profigDao
                  notificationCenter:(NSNotificationCenter *)notificationCenter
                                 log:(OGALog *)log {
    if (self = [super init]) {
        _viewProvider = viewProvider;
        _viewControllerProvider = viewControllerProvider;
        _impressionController = impressionController;
        _profigDao = profigDao;
        _notificationCenter = notificationCenter;
        _currentViewabilityStatus = NO;
        _log = log;
    }

    return self;
}

#pragma mark - Methods

- (BOOL)display:(id<OGAAdDisplayer>)displayer error:(OguryError **)error {
    self.displayer = displayer;
    [self.displayer setupCloseButtonTimer];
    return YES;
}

- (void)cleanUp {
    [self unregisterForApplicationLifecycleNotifications];

    self.displayer = nil;
}

- (void)forceClose {
    [self cleanUp];
}

- (void)registerForApplicationLifecycleNotifications {
    [self.notificationCenter addObserver:self selector:@selector(windowDidBecomeVisible:) name:UIWindowDidBecomeVisibleNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(windowDidBecomeHidden:) name:UIWindowDidBecomeHiddenNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(windowDidBecomeKey:) name:UIWindowDidBecomeKeyNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(windowDidResignKey:) name:UIWindowDidResignKeyNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)unregisterForApplicationLifecycleNotifications {
    [self.notificationCenter removeObserver:self];
}

- (void)windowDidBecomeVisible:(NSNotification *)notification {
    // Implemented by subclass
}

- (void)windowDidBecomeHidden:(NSNotification *)notification {
    // Implemented by subclass
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    // Implemented by subclass
}

- (void)windowDidResignKey:(NSNotification *)notification {
    // Implemented by subclass
}

- (void)applicationDidBecomeActive {
#warning Called upon losing focus (see https://openradar.appspot.com/32614495 for more details)
    [self.exposureController computeExposure];
}

- (void)applicationWillResignActive {
#warning Called twice upon losing focus (see https://openradar.appspot.com/32614495 for more details)
    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateExposureInformation alloc] initWithExposure:[OGAAdExposure zeroExposure]]];
    [self updateViewablityIfNecessary:[OGAAdExposure zeroExposure]];
}

- (void)applicationDidEnterBackground {
    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateExposureInformation alloc] initWithExposure:[OGAAdExposure zeroExposure]]];
    [self updateViewablityIfNecessary:[OGAAdExposure zeroExposure]];
}

- (void)performKeepAlive {
    OGAProfigFullResponse *profig = self.profigDao.profigFullResponse;

    if (!self.displayer.hasKeepAlive && profig.closeAdWhenLeavingApp) {
        [self.displayer dispatchInformation:[[OGAAdDisplayerSystemCloseInformation alloc] init]];

        if ([self.displayer.delegate respondsToSelector:@selector(performAction:error:)]) {
            OGAForceCloseAdAction *forceCloseAdAction = [[OGAForceCloseAdAction alloc] init];

            // Leave some time for the format to close completely
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                OguryError *closeError;

                [self.displayer.delegate performAction:forceCloseAdAction error:&closeError];

                if (!closeError) {
                    [self.log logAdError:closeError forAdConfiguration:self.displayer.ad.adConfiguration message:@"Failed to close Ad"];
                }
            });
        }
    }
}

// TO FIX : this is a temporary fix for SPY-11709
- (void)updateViewablityIfNecessary:(OGAAdExposure *)exposure {
    if (!self.currentViewabilityStatus && exposure.exposurePercentage >= OGAAdImpressionControllerMinExposureForImpression) {
        [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateViewabilityInformation alloc] initWithViewability:YES]];
        self.currentViewabilityStatus = YES;
    } else if (self.currentViewabilityStatus && exposure.exposurePercentage < OGAAdImpressionControllerMinExposureForImpression) {
        [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateViewabilityInformation alloc] initWithViewability:NO]];
        self.currentViewabilityStatus = NO;
    }
}

- (void)dismissPresentedAdViewController:(UIViewController *)viewController {
    UIViewController *rootViewController = viewController;
    while ([rootViewController presentedViewController] != nil) {
        rootViewController = [rootViewController presentedViewController];
        if ([rootViewController isKindOfClass:[OGAFullscreenViewController class]]) {
            [rootViewController dismissViewControllerAnimated:NO completion:nil];
            [(OGAFullscreenViewController *)rootViewController cleanUp];
            [((OGAFullscreenViewController *)rootViewController).exposureController stopExposure];
        }
    }
}

#pragma mark - OGAAdExposureDelegate

- (void)exposureDidChange:(OGAAdExposure *)exposure {
    id<OGAAdDisplayer> displayer = self.displayer;

    if (displayer) {
        [self.impressionController sendIfNecessaryAfterExposureChanged:exposure ad:displayer.ad delegateDispatcher:self.displayer.configuration.delegateDispatcher];

        OGAAdDisplayerUpdateExposureInformation *information = [[OGAAdDisplayerUpdateExposureInformation alloc] initWithExposure:exposure];
        [self.displayer dispatchInformation:information];
        [self updateViewablityIfNecessary:exposure];
    }
}

@end
