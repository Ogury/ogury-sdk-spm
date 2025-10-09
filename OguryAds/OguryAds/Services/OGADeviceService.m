//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGADeviceService.h"
#import "OGADeviceOrientationConstants.h"
#import "UIDevice+Orientation.h"

@interface OGADeviceService ()

@property(nonatomic, strong) UIApplication *application;
@property(nonatomic, strong) UIDevice *device;

@end

@implementation OGADeviceService

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithDevice:UIDevice.currentDevice];
}

- (instancetype)initWithDevice:(UIDevice *)device {
    if (self = [super init]) {
        _device = device;
    }

    return self;
}

#pragma mark - Methods

- (NSString *)interfaceOrientation {
    return [self.device ogaOrientationString] ?: OGAOrientationStringPortrait;
}

@end
