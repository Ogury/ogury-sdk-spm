//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGASizeSafeAreaController.h"
#import "OGASafeAreaDelegate.h"
#import "OGAThumbnailAdWindowFactory.h"

@interface OGASizeSafeAreaController ()

@property(nonatomic, assign, nonnull) NSNotificationCenter *notificationCenter;
@property(nonatomic, assign, nonnull) UIApplication *application;
@property(strong, nonatomic, nullable) OGAThumbnailAdWindowFactory *thumbnailAdWindowFactory;

@end

@implementation OGASizeSafeAreaController

#pragma mark - Initialization

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter application:(UIApplication *)application windowFactory:(OGAThumbnailAdWindowFactory *)thumbnailAdWindowFactory {
    if (self = [super init]) {
        _notificationCenter = notificationCenter;
        _thumbnailAdWindowFactory = thumbnailAdWindowFactory;
        _application = application;
        [_notificationCenter addObserver:self selector:@selector(rotated:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (instancetype)initWithWindowFactory:(OGAThumbnailAdWindowFactory *)thumbnailAdWindowFactory {
    return [self initWithNotificationCenter:[NSNotificationCenter defaultCenter] application:[UIApplication sharedApplication] windowFactory:thumbnailAdWindowFactory];
}

- (instancetype)init {
    return [self initWithNotificationCenter:[NSNotificationCenter defaultCenter] application:[UIApplication sharedApplication] windowFactory:nil];
}

- (CGRect)getUsableFullscreenFrame {
    if (!self.thumbnailAdWindowFactory) {
        return [self getUsableFullscreenFrameWithWindow:self.application.windows.firstObject];
    }
    return [self getUsableFullscreenFrameWithWindow:[self.thumbnailAdWindowFactory getThumbnailAdWindowIfExist]];
}

- (CGRect)getUsableFullscreenFrameWithWindow:(UIWindow *)window {
    UIWindow *screenWindow = window;
    if (@available(iOS 13.0, *)) {
        if (window.windowScene) {
            screenWindow = window.windowScene.windows.firstObject;
            return [self getFrameForWindow:screenWindow top:screenWindow.safeAreaInsets.top bottom:screenWindow.safeAreaInsets.bottom left:screenWindow.safeAreaInsets.left right:screenWindow.safeAreaInsets.right];
        }
    }
    if (@available(iOS 11.0, *)) {
        screenWindow = self.application.windows.firstObject;
        return [self getFrameForWindow:screenWindow top:screenWindow.safeAreaInsets.top bottom:screenWindow.safeAreaInsets.bottom left:screenWindow.safeAreaInsets.left right:screenWindow.safeAreaInsets.right];
    }

    CGFloat topMargin = window.rootViewController.topLayoutGuide.length;
    CGFloat bottomMargin = window.rootViewController.bottomLayoutGuide.length;

    return [self getFrameForWindow:window top:topMargin bottom:bottomMargin left:0 right:0];
}

- (CGRect)getFrameForWindow:(UIWindow *)window top:(CGFloat)top bottom:(CGFloat)bottom left:(CGFloat)left right:(CGFloat)right {
    CGFloat width = window.frame.size.width;
    CGFloat height = window.frame.size.height;
    return CGRectMake(left, top, width - right - left, height - top - bottom);
}

- (void)rotated:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(safeAreaChanged:)]) {
        [self.delegate safeAreaChanged:[self getUsableFullscreenFrame]];
    }
}

@end
