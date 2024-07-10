//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGADeviceOrientationConstants.h"
#import "UIDevice+Orientation.h"

@implementation UIDevice (Orientation)

#pragma mark - Methods

- (NSString *_Nullable)ogaOrientationString {
    return [UIDevice orientationStringForDevice:self];
}

+ (NSString *_Nullable)orientationStringForDevice:(UIDevice *)device {
    switch (device.orientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            return OGAOrientationStringPortrait;

        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            return OGAOrientationStringLandscape;

        default:
            return nil;
    }
}

@end
