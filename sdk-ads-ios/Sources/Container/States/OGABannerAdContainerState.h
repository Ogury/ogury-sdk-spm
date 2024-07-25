//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGABaseAdContainerState.h"
#import "OGAAdExposureDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGABannerAdContainerState : OGABaseAdContainerState <OGAAdExposureDelegate>

#pragma mark - Initialization

- (instancetype)initWithViewProvider:(UIView * (^)(void))viewProvider viewControllerProvider:(UIViewController * (^)(void))viewControllerProvider;

@end

NS_ASSUME_NONNULL_END
