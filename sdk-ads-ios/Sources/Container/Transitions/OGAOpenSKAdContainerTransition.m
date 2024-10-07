//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAOpenSKAdContainerTransition.h"
#import "OGAOpenStoreKitAction.h"
#import "OGAAdExposureController.h"
#import "OGAAdContainerState.h"

@implementation OGAOpenSKAdContainerTransition

#pragma mark - Initialization

- (instancetype)initWithInitialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState {
    return [self initWithAction:OGAOpenStoreKitActionName initialState:initialState finalState:finalState];
}

#pragma mark - Methods

- (BOOL)performTransition:(OguryAdError *_Nullable *_Nullable)error {
    id<OGAAdDisplayer> displayer = self.initialState.displayer;
    if (![self.finalState display:displayer error:error]) {
        return NO;
    }
    return YES;
}

@end
