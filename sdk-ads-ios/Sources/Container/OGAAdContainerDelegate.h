//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryCore.h>

#import "OGAAdContainerState.h"

@class OGAAd;

NS_ASSUME_NONNULL_BEGIN

@protocol OGAAdContainerDelegate <NSObject>

#pragma mark - Properties

@property(nonatomic, strong) OGAAd *ad;

#pragma mark - Methods

@optional

- (BOOL)shouldTransitionTo:(id<OGAAdContainerState>)toState from:(id<OGAAdContainerState>)fromState error:(OguryAdError *_Nullable __autoreleasing *_Nullable)error;

- (void)willTransitionTo:(id<OGAAdContainerState>)toState from:(id<OGAAdContainerState>)fromState;

- (void)didTransitionTo:(id<OGAAdContainerState>)toState from:(id<OGAAdContainerState>)fromState action:(NSString *)action;

- (void)didFailToTransitionTo:(id<OGAAdContainerState>)toState error:(OguryAdError *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
