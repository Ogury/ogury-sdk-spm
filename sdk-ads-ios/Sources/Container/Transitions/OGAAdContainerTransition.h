//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdContainerState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OGAAdContainerTransition <NSObject>

#pragma mark - Properties

@property(nonatomic, strong, readonly) NSString *action;
@property(nonatomic, strong, readonly) id<OGAAdContainerState> initialState;
@property(nonatomic, strong, readonly) id<OGAAdContainerState> finalState;

#pragma mark - Initialization

- (instancetype)initWithAction:(NSString *)action initialState:(id<OGAAdContainerState>)initialState finalState:(id<OGAAdContainerState>)finalState;

#pragma mark - Methods

- (BOOL)performTransition:(OguryAdError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
