//
//  OGAMediation.m
//  OguryAds
//
//  Created by Jerome TONNELIER on 22/05/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import "OguryMediation.h"

@implementation OguryMediation

@synthesize name, version;

- (instancetype)initWithName:(NSString *_Nonnull)name version:(NSString *_Nonnull)version {
    if (self = [super init]) {
        self.name = name;
        self.version = version;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[OguryMediation alloc] initWithName:name version:version];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSString *name = [coder decodeObjectForKey:@"name"];
    NSString *version = [coder decodeObjectForKey:@"version"];
    return [self initWithName:name version:version];
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:version forKey:@"version"];
}

- (BOOL)isEqual:(id)object {
    OguryMediation *other = (OguryMediation *)object;
    if (!object) {
        return NO;
    }
    return [name isEqualToString:other.name] && [version isEqualToString:other.version];
}

@end
