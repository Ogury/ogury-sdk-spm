//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGASafeAreaDelegate.h"
#import "OGAThumbnailAdWindowFactory.h"

@interface OGASizeSafeAreaController : NSObject

@property(nonatomic, weak, nullable) id<OGASafeAreaDelegate> delegate;

- (instancetype)init;

- (instancetype)initWithWindowFactory:(OGAThumbnailAdWindowFactory *)thumbnailAdWindowFactory;

- (CGRect)getUsableFullscreenFrame;

- (CGRect)getUsableFullscreenFrameWithWindow:(UIWindow *)window;

@end