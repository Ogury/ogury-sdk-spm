//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAMRAIDAdDisplayer+Volume.h"
#import "OGAMRAIDWebView.h"
#import "OGAJavascriptCommandExecutor.h"
#import <MediaPlayer/MPVolumeView.h>

@interface OGAMRAIDAdDisplayer ()

@property(nonatomic, strong) MPVolumeView *mpVolumeView;
@property(nonatomic, strong) UISlider *volumeSlider;
@property(nonatomic, strong) NSMutableArray<OGAMraidAdWebView *> *webviews;

@end

@implementation OGAMRAIDAdDisplayer (Volume)

- (void)setupVolumeView {
    self.mpVolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-40, -40, 0, 0)];
    self.mpVolumeView.showsRouteButton = false;
    self.mpVolumeView.showsVolumeSlider = false;
    [self.view addSubview:self.mpVolumeView];
    for (UIView *view in self.mpVolumeView.subviews) {
        if ([view isKindOfClass:[UISlider class]]) {
            self.volumeSlider = (UISlider *)view;
            break;
        }
    }
}

- (void)registerForVolumeChangeFromVolumeSlider {
    [self.volumeSlider addTarget:self action:@selector(volumeDidChange:) forControlEvents:UIControlEventValueChanged];
    [self volumeDidChange:self.volumeSlider];
}

- (void)volumeDidChange:(UISlider *)sender {
    NSInteger volume = @(sender.value * 100).intValue;
    for (OGAMRAIDWebView *webView in self.webviews) {
        [webView.commandExecutor updateAudioVolume:volume];
    }
}

// for cleanUp
- (void)unregisterFromVolumeChange {
    [self.volumeSlider removeTarget:self action:@selector(volumeDidChange:) forControlEvents:UIControlEventValueChanged];
}

@end
