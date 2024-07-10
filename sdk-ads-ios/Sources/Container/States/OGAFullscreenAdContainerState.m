//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAFullscreenAdContainerState.h"
#import "OguryAdsError.h"
#import "OGAFullscreenViewController.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAAdConfiguration.h"
#import "OGAAdDisplayerUpdateStateInformation.h"

@interface OGAFullscreenAdContainerState ()

@property(nonatomic, strong) OGAFullscreenViewController *fullscreenViewController;
@property(nonatomic, strong, readwrite) OGAAdExposureController *exposureController;

@end

@implementation OGAFullscreenAdContainerState

#pragma mark - Properties

@synthesize exposureController = _exposureController;

- (NSString *)name {
    return @"fullscreen";
}

- (OGAAdContainerStateType)type {
    return OGAAdContainerStateTypeFullScreenOverlay;
}

- (BOOL)isExpanded {
    return YES;
}

#pragma mark - Methods

- (instancetype)initWithViewControllerProvider:(UIViewController * (^)(void))viewControllerProvider {
    self = [super
          initWithViewProvider:^UIView *_Nonnull {
              return nil;
          }
        viewControllerProvider:viewControllerProvider];
    if (self) {
        _exposureController = [[OGAAdExposureController alloc] initWithParentViewControllerProvider:viewControllerProvider];
        _exposureController.delegate = self;
    }
    return self;
}

- (BOOL)display:(nonnull id<OGAAdDisplayer>)displayer error:(OguryError *_Nullable *_Nullable)error {
    if (![super display:displayer error:error]) {
        return NO;
    }

    if (!self.viewControllerProvider) {
        if (error) {
            *error = [OguryError createOguryErrorWithCode:OguryAdsUnknownError localizedDescription:@"Missing root view controller to present."];
        }
        return NO;
    }
    UIViewController *rootViewController = self.viewControllerProvider();
    if (!rootViewController) {
        if (error) {
            *error = [OguryError createOguryErrorWithCode:OguryAdsUnknownError localizedDescription:@"Missing root view controller to present."];
        }
        return NO;
    }

    self.fullscreenViewController = [self createFullscreenViewController];

    if (![self.fullscreenViewController display:displayer error:error]) {
        return NO;
    }

    [self registerForApplicationLifecycleNotifications];

    [rootViewController presentViewController:self.fullscreenViewController
                                     animated:NO
                                   completion:^{
                                       self.exposureController.exposedWindow = self.fullscreenViewController.view.window;
                                       [self.displayer startOMIDSessionOnShow];
                                       [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateStateInformation alloc] initWithMraidState:OGAMRAIDStateDefault]];
                                       [self.exposureController computeExposure];
                                   }];

    return YES;
}

- (OGAFullscreenViewController *)createFullscreenViewController {
    return [[OGAFullscreenViewController alloc] initWithExposureController:self.exposureController];
}

- (void)cleanUp {
    [super cleanUp];

    if (self.fullscreenViewController) {
        [self.fullscreenViewController dismissViewControllerAnimated:NO
                                                          completion:^{
                                                              [self.exposureController stopExposure];
                                                          }];

        [self.fullscreenViewController cleanUp];
    }
    self.fullscreenViewController = nil;
}

- (void)applicationDidEnterBackground {
    [super applicationDidEnterBackground];

    [self performKeepAlive];
}

@end
