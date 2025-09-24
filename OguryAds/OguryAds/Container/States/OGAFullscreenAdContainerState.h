//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdContainerState.h"
#import "OGABaseAdContainerState.h"
#import "OGAAdExposureController.h"
#import "OGAAdExposureDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAFullscreenAdContainerState : OGABaseAdContainerState <OGAAdExposureDelegate>

#pragma mark - Initialization

- (instancetype)initWithViewControllerProvider:(UIViewController * (^)(void))viewControllerProvider;

@end

NS_ASSUME_NONNULL_END
