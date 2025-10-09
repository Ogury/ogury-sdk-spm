//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGAAdDsp.h"

@interface OGAAdDsp () <NSCopying>

@end

@implementation OGAAdDsp

- (instancetype)initWithCreativeId:(NSString *)creativeId region:(NSString *)region {
    if (self = [super init]) {
        _creativeId = creativeId;
        _region = region;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    OGAAdDsp *copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.creativeId = [self.creativeId copyWithZone:zone];
        copy.region = [self.region copyWithZone:zone];
    }
    return copy;
}

@end
