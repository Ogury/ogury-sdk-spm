//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAFullscreenViewController.h"
#import "OGAAdDisplayer.h"
#import "OGADeviceService.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAFullscreenViewController (Testing)

@property(nonatomic, weak, nullable) id<OGAAdDisplayer> displayer;

@property(nonatomic, strong) OGADeviceService *deviceService;

- (instancetype)initWithExposureController:(OGAAdExposureController *)exposureController deviceService:(OGADeviceService *)deviceService notificationCenter:(NSNotificationCenter *)notificationCenter;

- (void)sendScreenOrientationChange:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
