//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import "OGAWKWebView.h"

#import "OGAThumbnailAdConstants.h"

@implementation OGAWKWebView

#pragma mark - Methods

- (UIEdgeInsets)safeAreaInsets {
    UIEdgeInsets standardInsets = [super safeAreaInsets];

    if (self.window.tag == OGAThumbnailAdWindowTag) {
        return UIEdgeInsetsZero;
    }

    UIDeviceOrientation orientation = UIDevice.currentDevice.orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        standardInsets.right = 0;
    } else if (orientation == UIDeviceOrientationLandscapeRight) {
        standardInsets.left = 0;
    }

    return standardInsets;
}

@end
