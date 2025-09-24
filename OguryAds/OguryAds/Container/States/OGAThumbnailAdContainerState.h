//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdContainerState.h"
#import "OGABaseAdContainerState.h"

@class OGAThumbnailAdWindowFactory;

NS_ASSUME_NONNULL_BEGIN

@interface OGAThumbnailAdContainerState : OGABaseAdContainerState

- (instancetype)initWithThumbnailAdWindowFactory:(OGAThumbnailAdWindowFactory *)thumbnailAdWindowFactory;

@end

NS_ASSUME_NONNULL_END
