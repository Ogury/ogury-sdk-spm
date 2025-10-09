//
//  OGAVolumeViewManager.m
//  OguryAdsSDK
//
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import "OGAVolumeManager.h"

static MPVolumeView *_sharedVolumeView;
static UISlider *_sharedSlider;

@implementation OGAVolumeManager

+ (void)prepare {
    if (_sharedVolumeView) return;
    _sharedVolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-40, -40, 0, 0)];
    _sharedVolumeView.showsRouteButton = NO;
    _sharedVolumeView.showsVolumeSlider = NO;
    for (UIView *v in _sharedVolumeView.subviews) {
        if ([v isKindOfClass:[UISlider class]]) {
            _sharedSlider = (UISlider *)v;
            break;
        }
    }
    UIWindow *w = UIApplication.sharedApplication.windows.firstObject ?: UIApplication.sharedApplication.keyWindow;
    [w addSubview:_sharedVolumeView];
}

+ (MPVolumeView *)sharedVolumeView {
    return _sharedVolumeView;
}
+ (UISlider *)sharedVolumeSlider {
    return _sharedSlider;
}

@end
