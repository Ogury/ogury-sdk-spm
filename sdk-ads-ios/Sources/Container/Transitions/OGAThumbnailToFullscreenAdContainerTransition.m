//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAThumbnailToFullscreenAdContainerTransition.h"
#import "OGAExpandAdAction.h"

@implementation OGAThumbnailToFullscreenAdContainerTransition

#pragma mark - Initialization

- (instancetype)initWithInitialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState {
    return [self initWithAction:OGAExpandAdActionName initialState:initialState finalState:finalState];
}

#pragma mark - Methods

- (BOOL)performTransition:(OguryError *_Nullable *_Nullable)error {
    id<OGAAdDisplayer> displayer = self.initialState.displayer;

    [self.initialState unregisterForApplicationLifecycleNotifications];
    if (![self.finalState display:displayer error:error]) {
        return NO;
    }
    return YES;
}

@end
