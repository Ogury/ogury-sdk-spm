//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdContainerBuilder.h"

@interface OGAAdContainerBuilder (Testing)

#pragma mark - Properties

@property(nonatomic, strong) NSMutableArray<id<OGAAdContainerState>> *states;
@property(nonatomic, strong) NSMutableArray<id<OGAAdContainerTransition>> *transitions;

#pragma mark - Methods

- (void)addState:(id<OGAAdContainerState>)state;

- (void)assertNoNonReachableStates;

@end
