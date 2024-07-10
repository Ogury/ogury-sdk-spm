//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAFullscreenToThumbnailAdContainerTransition.h"
#import "OGACloseAdAction.h"

@implementation OGAFullscreenToThumbnailAdContainerTransition

#pragma mark - Initialization

- (instancetype)initWithInitialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState {
    return [self initWithAction:OGACloseAdActionName initialState:initialState finalState:finalState];
}

#pragma mark - Methods

- (BOOL)performTransition:(OguryError *_Nullable *_Nullable)error {
    id<OGAAdDisplayer> displayer = self.initialState.displayer;

    [self.initialState unregisterForApplicationLifecycleNotifications];
    return [self.finalState display:displayer error:error];
}

@end
