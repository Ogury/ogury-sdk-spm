//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdContainer.h"
#import "OGAAdContainerState.h"
#import "OGAAdContainerTransition.h"
#import "OGAAdDisplayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdContainerBuilder : NSObject

#pragma mark - Properties

@property(nonatomic, strong, readonly) id<OGAAdContainerState> initialState;
@property(nonatomic, strong, readonly) id<OGAAdContainerState> closedState;

#pragma mark - Initialization

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithDisplayer:(id<OGAAdDisplayer>)displayer;

#pragma mark - Methods

- (void)addTransition:(id<OGAAdContainerTransition>)transition;

- (void)addBasicTransitionWithAction:(NSString *)action initialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState;

- (OGAAdContainer *)build;

@end

NS_ASSUME_NONNULL_END
