//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdContainerTransition.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Basic transitions that will only cleanUp the initialState and display the displayer in the finalState.
 *
 * Designed to be used by close/forceClose action since there is no animation.
 *
 **/
@interface OGABasicAdContainerTransition : NSObject <OGAAdContainerTransition>

#pragma mark - Properties

@property(nonatomic, strong, readonly) NSString *action;
@property(nonatomic, strong, readonly) id<OGAAdContainerState> initialState;
@property(nonatomic, strong, readonly) id<OGAAdContainerState> finalState;

#pragma mark - Initialization

- (instancetype)initWithInitialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState;

- (instancetype)initWithAction:(NSString *)action initialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState;

@end

NS_ASSUME_NONNULL_END
