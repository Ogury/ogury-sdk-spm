//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryRectCorner.h"
#import "OguryOffset.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAThumbnailAdCachedPositionObject : NSObject <NSSecureCoding>

@property(nonatomic, assign) OguryOffset offsetRatio;
@property(nonatomic, assign) OguryRectCorner rectCorner;

- (instancetype)initWithOguryOffsetRatio:(OguryOffset)offsetRatio rectCorner:(OguryRectCorner)rectCorner;

@end

NS_ASSUME_NONNULL_END
