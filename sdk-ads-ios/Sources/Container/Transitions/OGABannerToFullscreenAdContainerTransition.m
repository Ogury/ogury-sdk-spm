//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGABannerToFullscreenAdContainerTransition.h"
#import "OGABannerAdContainerState.h"
#import "OGAFullscreenAdContainerState.h"
#import "OGAExpandAdAction.h"
#import "OGAAdDisplayerUpdateStateInformation.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAAdDisplayerUpdateViewabilityInformation.h"

@implementation OGABannerToFullscreenAdContainerTransition

#pragma mark - Initialization

- (instancetype)initWithInitialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState {
    return [self initWithAction:OGAExpandAdActionName initialState:initialState finalState:finalState];
}

#pragma mark - Methods

- (BOOL)performTransition:(OguryError *_Nullable *_Nullable)error {
    [self.initialState.exposureController stopExposure];

    [self.initialState unregisterForApplicationLifecycleNotifications];

    // Hack to pause the video if any
    [self.initialState.displayer dispatchInformation:[[OGAAdDisplayerUpdateExposureInformation alloc] initWithExposure:[OGAAdExposure zeroExposure]]];
    [self.initialState updateViewablityIfNecessary:[OGAAdExposure zeroExposure]];
    if (![self.finalState display:self.initialState.displayer error:error]) {
        return NO;
    }

    [self.finalState.exposureController startExposure];
    [self.finalState.displayer dispatchInformation:[[OGAAdDisplayerUpdateStateInformation alloc] initWithMraidState:OGAMRAIDStateExpanded]];
    [self.finalState.displayer dispatchInformation:[[OGAAdDisplayerUpdateStateInformation alloc] initWithMraidState:OGAMRAIDStateDefault]];
    [self.finalState.displayer dispatchInformation:[[OGAAdDisplayerUpdateExposureInformation alloc] initWithExposure:[OGAAdExposure fullExposure]]];
    [self.finalState updateViewablityIfNecessary:[OGAAdExposure fullExposure]];

    return YES;
}

@end
