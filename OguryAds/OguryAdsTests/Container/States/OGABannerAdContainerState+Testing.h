//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGABannerAdViewContainerState.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGABannerAdViewContainerState (Testing)

@property(nonatomic, strong) UIView *bannerView;
@property(nonatomic, weak, nullable) UIView *parentView;
@property(nonatomic, strong) NSNotificationCenter *notificationCenter;

- (void)centerBannerInFrame;

- (void)startViewsObservation;

- (UIView *_Nullable)getParentScrollViewFrom:(UIView *)view;

- (void)addAdVisibilityObserver;

- (void)removeKeyPathObservers;

- (void)overrideBannerView:(UIView *)bannerView;

- (void)windowDidBecomeVisible:(NSNotification *)notification;

- (void)windowDidBecomeHidden:(NSNotification *)notification;

- (void)windowDidBecomeKey:(NSNotification *)notification;

- (void)windowDidResignKey:(NSNotification *)notification;

- (void)applicationDidBecomeActive;

- (void)applicationWillResignActive;

- (void)applicationDidEnterBackground;

- (void)bannerViewDidMoveToWindow:(NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
