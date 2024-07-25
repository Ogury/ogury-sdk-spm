//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAThumbnailAdCachedPositionObject.h"

static NSString *const OGAOguryOffsetXKey = @"OGAOguryOffsetXKey";
static NSString *const OGAOguryOffsetYKey = @"OGAOguryOffsetYKey";
static NSString *const OGARectCornerKey = @"OGARectCornerKey";

@implementation OGAThumbnailAdCachedPositionObject

- (instancetype)initWithOguryOffsetRatio:(OguryOffset)offsetRatio rectCorner:(OguryRectCorner)rectCorner {
    if (self = [super init]) {
        _offsetRatio = offsetRatio;
        _rectCorner = rectCorner;
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeFloat:self.rectCorner forKey:OGARectCornerKey];
    [coder encodeFloat:self.offsetRatio.x forKey:OGAOguryOffsetXKey];
    [coder encodeFloat:self.offsetRatio.y forKey:OGAOguryOffsetYKey];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        _offsetRatio = OguryOffsetMake([coder decodeFloatForKey:OGAOguryOffsetXKey], [coder decodeFloatForKey:OGAOguryOffsetYKey]);
        _rectCorner = [coder decodeFloatForKey:OGARectCornerKey];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
