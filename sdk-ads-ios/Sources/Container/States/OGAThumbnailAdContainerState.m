//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAThumbnailAdContainerState.h"

#import "OguryAdError.h"
#import "OGAThumbnailAdWindow.h"
#import "OGAThumbnailAdWindowFactory.h"
#import "OGAAdDisplayerUpdateStateInformation.h"
#import "OGAProfigDao.h"
#import "OGAThumbnailAdConstants.h"
#import "OguryAdError+Internal.h"

@interface OGAThumbnailAdContainerState ()

@property(nonatomic, weak, nullable) OGAThumbnailAdWindow *thumbnailAdWindow;
@property(nonatomic, strong, nullable) OGAThumbnailAdWindowFactory *thumbnailAdWindowFactory;

@end

@implementation OGAThumbnailAdContainerState

#pragma mark - Properties

- (NSString *)name {
    return @"ThumbnailAd";
}

- (OGAAdContainerStateType)type {
    return OGAAdContainerStateTypeOverlay;
}

- (OGAAdExposureController *)exposureController {
    return self.thumbnailAdWindow.thumbnailAdViewController.exposureController;
}

#pragma mark - Methods

- (instancetype)initWithThumbnailAdWindowFactory:(OGAThumbnailAdWindowFactory *)thumbnailAdWindowFactory {
    self = [super
        initWithViewProvider:^UIView *_Nonnull {
            return nil;
        }
        viewControllerProvider:^UIViewController *_Nonnull {
            return nil;
        }];

    if (self) {
        _thumbnailAdWindowFactory = thumbnailAdWindowFactory;
    }

    return self;
}

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

    self.thumbnailAdWindow.isExpanded = NO;
    self.thumbnailAdWindow.isDraggable = YES;
    if (![self.thumbnailAdWindow display:displayer error:error]) {
        return NO;
    }

    [self registerForApplicationLifecycleNotifications];

    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateStateInformation alloc] initWithMraidState:OGAMRAIDStateDefault]];
    return YES;
}

- (void)cleanUp {
    [super cleanUp];

    [self.thumbnailAdWindow cleanUp];
    [self.thumbnailAdWindowFactory cleanUp];
    self.thumbnailAdWindow = nil;
}

- (void)windowDidBecomeVisible:(NSNotification *)notification {
    [super windowDidBecomeVisible:notification];

    UIWindow *notifiedWindow;

    if ([notification.object isKindOfClass:[UIWindow class]]) {
        notifiedWindow = notification.object;
        if (notifiedWindow.tag != OGAThumbnailAdWindowTag && notifiedWindow == self.thumbnailAdWindow) {
            [self.thumbnailAdWindow makeKeyAndVisible];
        }
    }

    [self.exposureController computeExposure];
}

- (void)windowDidBecomeHidden:(NSNotification *)notification {
    [super windowDidBecomeHidden:notification];

    [self.exposureController computeExposure];
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [super windowDidBecomeKey:notification];

    [self.exposureController computeExposure];
}

- (void)windowDidResignKey:(NSNotification *)notification {
    [super windowDidResignKey:notification];

    [self.exposureController computeExposure];
}

- (void)applicationDidEnterBackground {
    [super applicationDidEnterBackground];

    [self performKeepAlive];
}

@end
