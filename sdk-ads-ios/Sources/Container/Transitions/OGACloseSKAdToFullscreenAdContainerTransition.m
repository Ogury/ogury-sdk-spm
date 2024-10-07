//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGACloseSKAdToFullscreenAdContainerTransition.h"
#import "OGACloseSKAction.h"
#import "OGAAdExposureController.h"
#import "OGAAdContainerState.h"

@implementation OGACloseSKAdToFullscreenAdContainerTransition

#pragma mark - Initialization

- (instancetype)initWithInitialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState {
    return [self initWithAction:OGACloseSKToFullscreenActionName initialState:initialState finalState:finalState];
}

#pragma mark - Methods

- (BOOL)performTransition:(OguryAdError *_Nullable *_Nullable)error {
    [self.initialState cleanUp];
    return YES;
}

@end
