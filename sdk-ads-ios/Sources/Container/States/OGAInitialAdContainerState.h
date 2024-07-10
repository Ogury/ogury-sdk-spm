//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGABaseAdContainerState.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const OGAInitialAdContainerStateState;

@interface OGAInitialAdContainerState : OGABaseAdContainerState

#pragma mark - Initialization

/**
 * Create an initial state holding the provided displayer.
 *
 * The initial state is the only one that must be initialized with the displayer.
 * Other states will receive the displayer when their display method will be called.
 *
 * @param displayer Displayer that will be passed to other states during transition.
 * @return an initial state.
 */
- (instancetype)initWithDisplayer:(id<OGAAdDisplayer>)displayer;

@end

NS_ASSUME_NONNULL_END
