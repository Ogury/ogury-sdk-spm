//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdContainerState.h"
#import "OGABaseAdContainerState.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAStoreKitState : OGABaseAdContainerState

#pragma mark - Initialization

- (instancetype)initWithAd:(OGAAd *)ad
    viewControllerProvider:(UIViewController * (^)(void))viewControllerProvider;

@end

NS_ASSUME_NONNULL_END
