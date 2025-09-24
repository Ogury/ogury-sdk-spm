//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdExposure.h"
#import "OGAAdDisplayer.h"
#import "OGAAdExposureDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdExposureController : NSObject

@property(nonatomic, weak, nullable) id<OGAAdExposureDelegate> delegate;
@property(nonatomic, weak, nullable) UIView *exposedView;
@property(nonatomic, weak, nullable) UIWindow *exposedWindow;

- (instancetype)initWithParentViewControllerProvider:(UIViewController * (^)(void))parentViewControllerProvider;
- (instancetype)initWithExposedView:(UIView *)exposedView exposedWindow:(UIWindow *)exposedWindow parentViewControllerProvider:(UIViewController * (^)(void))parentViewControllerProvider;

- (void)stopExposure;
- (void)startExposure;
- (void)computeExposure;

@end

NS_ASSUME_NONNULL_END
