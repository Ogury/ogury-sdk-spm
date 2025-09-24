//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OGAThumbnailAdViewController+Exposure.h"

#import "OGAAdExposureController.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAAdDisplayerUpdateViewabilityInformation.h"
#import "OGAThumbnailAdWindow.h"
#import "OGAThumbnailAdRestrictionsManager.h"
#import "OGAAdImpressionManager.h"
#import "OGAAdConfiguration.h"

@interface OGAThumbnailAdViewController ()

@property(nonatomic, weak, nullable) id<OGAAdDisplayer> displayer;
@property(nonatomic, strong) OGAAdExposureController *exposureController;
@property(nonatomic, weak, nullable) OGAThumbnailAdWindow *window;
@property(nonatomic, strong) OGAThumbnailAdRestrictionsManager *restrictionManager;
@property(nonatomic, strong) OGAAdImpressionManager *impressionManager;

@end

@implementation OGAThumbnailAdViewController (Exposure)

#pragma mark - Methods

- (void)sendAdExposureZero {
    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateExposureInformation alloc] initWithExposure:[OGAAdExposure zeroExposure]]];
}

- (void)sendAdExposure {
    if (self.displayer.mraidDisplayerState == OGAAdMraidDisplayerStateLoaded) {
        [self.exposureController computeExposure];
    } else {
        [self sendAdExposureZero];
        [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateViewabilityInformation alloc] initWithViewability:NO]];
    }
}

- (void)pauseAd {
    [self sendAdExposureZero];
    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateViewabilityInformation alloc] initWithViewability:NO]];
    self.window.hidden = YES;
}

- (void)resumeAd {
    self.window.hidden = NO;
    [self sendAdExposure];
    [self.displayer dispatchInformation:[[OGAAdDisplayerUpdateViewabilityInformation alloc] initWithViewability:YES]];
}

#pragma mark - OGAAdExposureDelegate

- (void)exposureDidChange:(OGAAdExposure *)exposure {
    id<OGAAdDisplayer> displayer = self.displayer;
    if (displayer) {
        [self.impressionManager sendIfNecessaryAfterExposureChanged:exposure
                                                                 ad:displayer.ad
                                                 delegateDispatcher:self.displayer.configuration.delegateDispatcher
                                                          displayer:displayer];
        [displayer dispatchInformation:[[OGAAdDisplayerUpdateExposureInformation alloc] initWithExposure:exposure]];
    }
}

@end
