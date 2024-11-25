//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGABannerAdContainerState+Testing.h"

@implementation OGABannerAdViewContainerState (Testing)

- (void)overrideBannerView:(UIView *)bannerView {
    self.bannerView = bannerView;
}

@end
