//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAdContainerBuilder.h"

#import "OGAForceCloseAdAction.h"
#import "OGAInitialAdContainerState.h"
#import "OGAClosedAdContainerState.h"
#import "OGABasicAdContainerTransition.h"

@interface OGAAdContainerBuilder ()

@property(nonatomic, strong) NSMutableArray<id<OGAAdContainerState>> *states;
@property(nonatomic, strong) NSMutableArray<id<OGAAdContainerTransition>> *transitions;

@property(nonatomic, strong) id<OGAAdContainerState> initialState;
@property(nonatomic, strong) id<OGAAdContainerState> closedState;

@end

@implementation OGAAdContainerBuilder

- (instancetype)initWithDisplayer:(id<OGAAdDisplayer>)displayer {
    if (self = [super init]) {
        _states = [[NSMutableArray alloc] init];
        _transitions = [[NSMutableArray alloc] init];

        [self initializeInitialAndClosedState:displayer];
    }
    return self;
}

- (void)initializeInitialAndClosedState:(id<OGAAdDisplayer>)displayer {
    self.closedState = [[OGAClosedAdContainerState alloc] init];
    [self.states addObject:self.closedState];

    self.initialState = [[OGAInitialAdContainerState alloc] initWithDisplayer:displayer];
    [self addState:self.initialState];
}

- (void)addTransition:(id<OGAAdContainerTransition>)transition {
    if (![self.transitions containsObject:transition]) {
        [self.transitions addObject:transition];
        [self addState:transition.initialState];
        [self addState:transition.finalState];
    }
}

- (void)addBasicTransitionWithAction:(NSString *)action initialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState {
    [self addTransition:[[OGABasicAdContainerTransition alloc] initWithAction:action
                                                                 initialState:initialState
                                                                   finalState:finalState]];
}

- (void)addState:(id<OGAAdContainerState>)state {
    if (![self.states containsObject:state]) {
        [self.states addObject:state];
        [self addTransition:[[OGABasicAdContainerTransition alloc] initWithAction:OGAForceCloseAdActionName
                                                                     initialState:state
                                                                       finalState:self.closedState]];
    }
}

- (OGAAdContainer *)build {
#ifdef DEBUG
    // Only assert in debug releases to avoid crashing production SDK.
    [self assertNoNonReachableStates];
#endif
    return [[OGAAdContainer alloc] initWithInitialState:self.initialState transitions:self.transitions];
}

- (void)assertNoNonReachableStates {
    NSMutableSet<id<OGAAdContainerState>> *nonReachableStates = [NSMutableSet setWithArray:self.states];
    [nonReachableStates removeObject:self.initialState];
    for (id<OGAAdContainerTransition> transition in self.transitions) {
        [nonReachableStates removeObject:transition.finalState];
    }
    NSAssert(nonReachableStates.count == 0, @"Non reachable state '%@'.", nonReachableStates.objectEnumerator.nextObject.name);
}

@end
