//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAThumbnailAdViewController.h"
#import "OGAInvalidThumbnailAdPositions.h"
#import "OguryRectCorner.h"
#import "OguryOffset.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAThumbnailAdViewController (Position)

- (void)setupThumbnailPosition;

- (void)checkThumbnailCorrectPosition;

- (OGAInvalidThumbnailAdPositions)canMoveToPoint:(CGPoint)point;

- (BOOL)isMinimumVisibleScreen;

- (void)sendScreenOrientationChange:(CGSize)size;

- (void)applyOffsetToPosition;

- (void)updateOffsetRatio;

- (CGSize)getScreenSize;

- (void)initThumbnailSize;

- (void)sendCurrentOrientation;

@end

NS_ASSUME_NONNULL_END
