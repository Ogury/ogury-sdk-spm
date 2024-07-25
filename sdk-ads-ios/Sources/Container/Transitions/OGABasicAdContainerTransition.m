//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGABasicAdContainerTransition.h"

@implementation OGABasicAdContainerTransition

#pragma mark - Initialization

- (instancetype)initWithInitialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState {
    [NSException raise:@"MustOverride" format:@"Must be overriden by subclasses"];
    return nil;
}

- (instancetype)initWithAction:(NSString *)action initialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState {
    if (self = [super init]) {
        _action = action;
        _initialState = initialState;
        _finalState = finalState;
    }

    return self;
}

#pragma mark - Methods

- (BOOL)performTransition:(OguryError *_Nullable *_Nullable)error {
    id<OGAAdDisplayer> displayer = self.initialState.displayer;
    [self.initialState cleanUp];
    if (![self.finalState display:displayer error:error]) {
        return NO;
    }
    return YES;
}

@end
