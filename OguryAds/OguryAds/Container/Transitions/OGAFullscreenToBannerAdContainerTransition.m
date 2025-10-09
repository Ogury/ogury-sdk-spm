//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAFullscreenToBannerAdContainerTransition.h"
#import "OGACloseAdAction.h"
#import "OGAAdExposureController.h"
#import "OGAAdContainerState.h"

@implementation OGAFullscreenToBannerAdContainerTransition

#pragma mark - Initialization

- (instancetype)initWithInitialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState {
    return [self initWithAction:OGACloseAdActionName initialState:initialState finalState:finalState];
}

#pragma mark - Methods

- (BOOL)performTransition:(OguryAdError *_Nullable *_Nullable)error {
    id<OGAAdDisplayer> displayer = self.initialState.displayer;

    [self.initialState.exposureController stopExposure];
    [self.initialState cleanUp];

    [self.finalState.exposureController startExposure];
    if (![self.finalState display:displayer error:error]) {
        return NO;
    }
    [self resumeBannerContentForState:self.finalState];
    return YES;
}

- (void)resumeBannerContentForState:(id<OGAAdContainerState>)state {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [state.exposureController computeExposure];
    });
}

@end
