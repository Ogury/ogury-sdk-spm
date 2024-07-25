//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGACloseSKAdContainerTransition.h"
#import "OGACloseSKAction.h"
#import "OGAAdExposureController.h"
#import "OGAAdContainerState.h"

@implementation OGACloseSKAdContainerTransition

#pragma mark - Initialization

- (instancetype)initWithInitialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState {
    return [self initWithAction:OGACloseSKActionName initialState:initialState finalState:finalState];
}

#pragma mark - Methods

- (BOOL)performTransition:(OguryError *_Nullable *_Nullable)error {
    [self.initialState cleanUp];
    return YES;
}

@end
