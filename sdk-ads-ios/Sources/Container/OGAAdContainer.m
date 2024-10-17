//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdContainer.h"
#import "OGACloseAdAction.h"
#import "OGAForceCloseAdAction.h"
#import "OguryAdError.h"
#import "OGAAdDisplayerInformation.h"
#import "OGAAdDisplayerUpdateScreenSizeInformation.h"
#import "OguryAdError.h"
#import "OguryAdError+Internal.h"

@interface OGAAdContainer ()

@property(nonatomic, strong) id<OGAAdContainerState> currentState;
@property(nonatomic, assign) OGAAdContainerStateType previousStateType;
@property(nonatomic, strong) NSArray<id<OGAAdContainerTransition>> *transitions;

@end

@implementation OGAAdContainer

#pragma mark - Initialization

- (instancetype)initWithInitialState:(id<OGAAdContainerState>)initialState transitions:(NSArray<id<OGAAdContainerTransition>> *)transitions {
    if (self = [super init]) {
        _currentState = initialState;
        _transitions = [NSArray arrayWithArray:transitions];  // To prevent any accidental mutation of the array.
    }

    return self;
}

#pragma mark - Properties

- (NSString *)state {
    return self.currentState.name;
}

- (OGAAdContainerStateType)stateType {
    return self.currentState.type;
}

- (OGAAdContainerStateType)previousStateType {
    return _previousStateType;
}

#pragma mark - Methods

- (BOOL)performAction:(NSString *)action error:(OguryAdError **)error {
    id<OGAAdContainerTransition> transition = [self findTransitionForAction:action initialState:self.currentState];
    if (!transition) {
        if (error) {
            *error = [OguryAdError createOguryErrorWithCode:OGAInternalUnknownError localizedDescription:@"No transitions available."];
        }
        return NO;
    }

    if ([self.delegate respondsToSelector:@selector(shouldTransitionTo:from:error:)]) {
        if (![self.delegate shouldTransitionTo:transition.finalState from:self.currentState error:error]) {
            return NO;
        }
    }

    id<OGAAdDisplayer> displayer = self.currentState.displayer;
    OguryAdError *transitionError = nil;
    if (![transition performTransition:&transitionError]) {
        if (error) {
            *error = [OguryAdError viewControllerPreventsAdFromBeingDisplayed];
        }
        if ([self.delegate respondsToSelector:@selector(didFailToTransitionTo:error:)]) {
            [self.delegate didFailToTransitionTo:transition.finalState error:transitionError];
        }
        return NO;
    }
    self.currentState = transition.finalState;
    self.previousStateType = transition.initialState.type;

    // Send information that screen size have changed
    id<OGAAdDisplayerInformation> information = [[OGAAdDisplayerUpdateScreenSizeInformation alloc] initWithSize:displayer.view.bounds.size];
    [displayer dispatchInformation:information];

    if ([self.delegate respondsToSelector:@selector(didTransitionTo:from:action:)]) {
        [self.delegate didTransitionTo:self.currentState from:transition.initialState action:action];
    }

    return YES;
}

- (_Nullable id<OGAAdContainerTransition>)findTransitionForAction:(NSString *)action initialState:(id<OGAAdContainerState>)initialState {
    NSUInteger index = [self.transitions indexOfObjectPassingTest:^BOOL(id<OGAAdContainerTransition> _Nonnull transition, NSUInteger index, BOOL *_Nonnull stop) {
        return transition.action == action && transition.initialState == initialState;
    }];
    return (index != NSNotFound) ? self.transitions[index] : nil;
}

@end
