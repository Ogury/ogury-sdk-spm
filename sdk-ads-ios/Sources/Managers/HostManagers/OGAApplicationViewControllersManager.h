//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAApplicationViewControllersManager : NSObject

+ (instancetype)shared;

- (NSArray<NSString *> *)getVisibleViewControllers;

- (NSArray<NSString *> *)getVisibleBundles;

- (void)addVisibleViewController:(NSDictionary<NSString *, NSString *> *)visibleViewController;

- (void)removeVisibleViewController:(NSDictionary<NSString *, NSString *> *)visibleViewController;

@end

NS_ASSUME_NONNULL_END
