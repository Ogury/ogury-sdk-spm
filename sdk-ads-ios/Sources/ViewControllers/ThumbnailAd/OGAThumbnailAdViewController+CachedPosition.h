//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAThumbnailAdViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAThumbnailAdViewController (CachedPosition)

- (void)cacheThumbnailAdPosition;

- (BOOL)updateToCachedThumbnailAdPositionWithAdUnitId:(NSString *)adUnitId;

@end

NS_ASSUME_NONNULL_END
