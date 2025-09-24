//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdContainerDelegate.h"
#import "OGAAdContainerTransition.h"
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdContainer : NSObject

#pragma mark - Properties

@property(nonatomic, weak) id<OGAAdContainerDelegate> delegate;
@property(nonatomic, strong, readonly) NSArray<id<OGAAdContainerTransition>> *transitions;
@property(nonatomic, strong, readonly) NSString *state;
@property(nonatomic, assign, readonly) OGAAdContainerStateType stateType;
@property(nonatomic, assign, readonly) OGAAdContainerStateType previousStateType;

#pragma mark - Initialization

- (instancetype)initWithInitialState:(id<OGAAdContainerState>)initialState transitions:(NSArray<id<OGAAdContainerTransition>> *)transitions;

#pragma mark - Methods

- (BOOL)performAction:(NSString *)action error:(OguryAdError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
