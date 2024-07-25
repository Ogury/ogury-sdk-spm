//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAMRAIDAdDisplayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAMRAIDAdDisplayer (Volume)

- (void)setupVolumeView;

- (void)volumeDidChange:(UISlider *)sender;

- (void)unregisterFromVolumeChange;

- (void)registerForVolumeChangeFromVolumeSlider;

@end

NS_ASSUME_NONNULL_END
