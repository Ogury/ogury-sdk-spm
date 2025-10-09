//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAThumbnailAdViewController.h"
#import "OGAAdExposureController.h"
#import "OGAThumbnailAdRestrictionsManager.h"
#import "OGAProfigDao.h"
#import "OGASizeSafeAreaController.h"
#import "OGAAdImpressionManager.h"
#import "OGADeviceService.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAThumbnailAdViewController (Testing)

@property(nonatomic, weak, nullable) OGAThumbnailAdWindow *window;

@property(nonatomic, weak, nullable) id<OGAAdDisplayer> displayer;

@property(nonatomic, strong) OGAAdExposureController *exposureController;

- (instancetype)initWithWindow:(OGAThumbnailAdWindow *)window
            restrictionManager:(OGAThumbnailAdRestrictionsManager *)restrictionManager
            notificationCenter:(NSNotificationCenter *)notificationCenter
            safeAreaController:(OGASizeSafeAreaController *)safeAreaController
             impressionManager:(OGAAdImpressionManager *)impressionManager
                 deviceService:(OGADeviceService *)deviceService
                  userDefaults:(NSUserDefaults *)userDefaults
                           log:(OGALog *)log;

- (void)setupExposureController:(OGAAdExposureController *)exposureController;

@end

NS_ASSUME_NONNULL_END
