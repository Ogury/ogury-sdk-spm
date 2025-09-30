//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAMRAIDAdDisplayer+Volume.h"
#import "OGAMRAIDWebView.h"
#import "OGAJavascriptCommandExecutor.h"
#import "OGAVolumeManager.h"
#import <MediaPlayer/MPVolumeView.h>

@interface OGAMRAIDAdDisplayer ()

@property(nonatomic, strong) MPVolumeView *mpVolumeView;
@property(nonatomic, strong) UISlider *volumeSlider;
@property(nonatomic, strong) NSMutableArray<OGAMraidAdWebView *> *webviews;

@end

@implementation OGAMRAIDAdDisplayer (Volume)

- (void)setupVolumeView {
    [OGAVolumeManager prepare];
    self.mpVolumeView = [OGAVolumeManager sharedVolumeView];
    self.volumeSlider = [OGAVolumeManager sharedVolumeSlider];
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

- (void)unregisterFromVolumeChange {
    [self.volumeSlider removeTarget:self action:@selector(volumeDidChange:) forControlEvents:UIControlEventValueChanged];
}

@end
