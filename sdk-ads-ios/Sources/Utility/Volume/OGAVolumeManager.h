//
//  OGAVolumeViewManager.h
//  OguryAdsSDK
//
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MPVolumeView.h>

@interface OGAVolumeManager : NSObject
+ (void)prepare;
+ (MPVolumeView *)sharedVolumeView;
+ (UISlider *)sharedVolumeSlider;
@end
