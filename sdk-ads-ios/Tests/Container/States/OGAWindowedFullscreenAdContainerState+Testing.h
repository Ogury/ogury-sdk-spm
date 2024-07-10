//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAWindowedFullscreenAdContainerState.h"
#import "OGASizeSafeAreaController.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAWindowedFullscreenAdContainerState (Testing)

@property(nonatomic, weak, nullable) OGAThumbnailAdWindow *thumbnailAdWindow;
@property(nonatomic, strong, nullable) OGAThumbnailAdWindowFactory *thumbnailAdWindowFactory;
@property(nonatomic, strong, nullable) OGASizeSafeAreaController *safeAreaController;
@property(nonatomic, strong) UIApplication *application;

- (instancetype)initWithThumbnailAdWindowFactory:(OGAThumbnailAdWindowFactory *)thumbnailAdWindowFactory safeAreaController:(OGASizeSafeAreaController *)safeAreaController application:(UIApplication *)application;

@end

NS_ASSUME_NONNULL_END
