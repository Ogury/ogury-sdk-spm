//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGABaseAdContainerState.h"
#import "OGAThumbnailAdWindowFactory.h"
#import "OGASafeAreaDelegate.h"

@interface OGAWindowedFullscreenAdContainerState : OGABaseAdContainerState <OGASafeAreaDelegate>

- (instancetype)initWithThumbnailAdWindowFactory:(OGAThumbnailAdWindowFactory *)thumbnailAdWindowFactory;

@end
