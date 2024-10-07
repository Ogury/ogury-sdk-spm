//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAWindowedFullscreenAdContainerState.h"

#import "OguryAdError.h"
#import "OGASizeSafeAreaController.h"
#import "OGAAdDisplayerUpdateCurrentPositionInformation.h"
#import "OGAAdDisplayerUpdateStateInformation.h"
#import "OguryAdError+Internal.h"

@interface OGAWindowedFullscreenAdContainerState ()

@property(nonatomic, weak, nullable) OGAThumbnailAdWindow *thumbnailAdWindow;
@property(nonatomic, strong, nullable) OGAThumbnailAdWindowFactory *thumbnailAdWindowFactory;
@property(nonatomic, strong, nullable) OGASizeSafeAreaController *safeAreaController;
@property(nonatomic, strong) UIApplication *application;

@end

@implementation OGAWindowedFullscreenAdContainerState

#pragma mark - Properties

- (NSString *)name {
    return @"FullscreenWindowAd";
}

- (OGAAdContainerStateType)type {
    return OGAAdContainerStateTypeFullScreenOverlay;
}

- (OGAAdExposureController *)exposureController {
    return self.thumbnailAdWindow.thumbnailAdViewController.exposureController;
}

- (BOOL)isExpanded {
    return YES;
}

#pragma mark - init Methods

- (instancetype)initWithThumbnailAdWindowFactory:(OGAThumbnailAdWindowFactory *)thumbnailAdWindowFactory {
    return [self initWithThumbnailAdWindowFactory:thumbnailAdWindowFactory safeAreaController:[[OGASizeSafeAreaController alloc] initWithWindowFactory:thumbnailAdWindowFactory] application:UIApplication.sharedApplication];
}

- (instancetype)initWithThumbnailAdWindowFactory:(OGAThumbnailAdWindowFactory *)thumbnailAdWindowFactory safeAreaController:(OGASizeSafeAreaController *)safeAreaController application:(UIApplication *)application {
    self = [super
        initWithViewProvider:^UIView *_Nonnull {
            return nil;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }];
    if (self) {
        _thumbnailAdWindowFactory = thumbnailAdWindowFactory;
        _safeAreaController = safeAreaController;
        _safeAreaController.delegate = self;
        _application = application;
    }
    return self;
}

#pragma mark - Methods

- (BOOL)display:(nonnull id<OGAAdDisplayer>)displayer error:(OguryAdError *_Nullable *_Nullable)error {
    if (![super display:displayer error:error]) {
        return NO;
    }

    self.thumbnailAdWindow = [self.thumbnailAdWindowFactory createThumbnailAdWindowWithDisplayer:displayer];
    if (!self.thumbnailAdWindow) {
        if (error) {
            *error = [OguryAdError createOguryErrorWithCode:OGAInternalUnknownError localizedDescription:@"Missing window."];
        }
        return NO;
    }

    // Dismiss the keyboard before expanding the thumbnail
    [self.application sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    self.thumbnailAdWindow.isDraggable = NO;
    self.thumbnailAdWindow.isExpanded = YES;
    self.thumbnailAdWindow.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    if (![self.thumbnailAdWindow display:displayer error:error]) {
        return NO;
    }

    [self registerForApplicationLifecycleNotifications];

    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateStateInformation alloc] initWithMraidState:OGAMRAIDStateExpanded]];

    return YES;
}

- (void)cleanUp {
    [super cleanUp];

    [self.thumbnailAdWindow cleanUp];
    [self.thumbnailAdWindowFactory cleanUp];
    self.thumbnailAdWindow = nil;
    self.safeAreaController = nil;
}

- (void)applicationDidEnterBackground {
    [super applicationDidEnterBackground];

    [self performKeepAlive];
}

@end
