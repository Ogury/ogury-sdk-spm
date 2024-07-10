//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGADeviceService.h"
#import "OGADeviceOrientationConstants.h"
#import "UIApplication+Orientation.h"
#import "UIDevice+Orientation.h"

@interface OGADeviceService ()

@property(nonatomic, strong) UIApplication *application;
@property(nonatomic, strong) UIDevice *device;

@end

@implementation OGADeviceService

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithApplication:UIApplication.sharedApplication device:UIDevice.currentDevice];
}

- (instancetype)initWithApplication:(UIApplication *)application device:(UIDevice *)device {
    if (self = [super init]) {
        _application = application;
        _device = device;
    }

    return self;
}

#pragma mark - Methods

- (NSString *)interfaceOrientation {
    NSString *orientationString = [self.application OGAOrientationString] ?: [self.device ogaOrientationString];

    // If we still don't have a value by now, we align with Android and send the portrait orientation
    return orientationString ?: OGAOrientationStringPortrait;
}

@end
