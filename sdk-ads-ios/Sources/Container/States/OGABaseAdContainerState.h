//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdContainerState.h"
#import "OGAAdExposureDelegate.h"
#import "OGAAdImpressionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGABaseAdContainerState : NSObject <OGAAdContainerState, OGAAdExposureDelegate>

#pragma mark - Properties

@property(nonatomic, copy, readonly) UIView * (^viewProvider)(void);
@property(nonatomic, copy, readonly) UIViewController * (^viewControllerProvider)(void);
@property(nonatomic, strong, readonly, nullable) OGAAdExposureController *exposureController;
@property(nonatomic, strong, readonly) OGAAdImpressionManager *impressionController;
@property(nonatomic, strong, readonly) OGAProfigDao *profigDao;
@property(nonatomic, assign) OGAAdContainerStateType previousType;
@property(nonatomic, strong, readonly) NSNotificationCenter *notificationCenter;

#pragma mark - Initialization

- (instancetype)initWithViewProvider:(UIView * (^)(void))viewProvider
              viewControllerProvider:(UIViewController * (^)(void))viewControllerProvider;

- (instancetype)initWithViewProvider:(UIView *_Nullable (^)(void))viewProvider
              viewControllerProvider:(UIViewController *_Nullable (^)(void))viewControllerProvider
                impressionController:(OGAAdImpressionManager *)impressionController
                           profigDao:(OGAProfigDao *)profigDao
                  notificationCenter:(NSNotificationCenter *)notificationCenter
                                 log:(OGALog *)log;

#pragma mark - Methods

- (void)registerForApplicationLifecycleNotifications;

- (void)unregisterForApplicationLifecycleNotifications;

- (void)windowDidBecomeVisible:(NSNotification *)notification;

- (void)windowDidBecomeHidden:(NSNotification *)notification;

- (void)windowDidBecomeKey:(NSNotification *)notification;

- (void)windowDidResignKey:(NSNotification *)notification;

- (void)applicationDidBecomeActive;

- (void)applicationWillResignActive;

- (void)applicationDidEnterBackground;

- (void)performKeepAlive;

- (void)dismissPresentedAdViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
