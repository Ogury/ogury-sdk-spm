//
//  OGAMediation.m
//  OguryAds
//
//  Created by Jerome TONNELIER on 22/05/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import "OguryMediation.h"

@implementation OguryMediation

@synthesize name, version, adapterVersion;

- (instancetype)initWithName:(NSString *_Nonnull)name
                     version:(NSString *_Nonnull)sdkVersion {
    return [self initWithName:name version:sdkVersion adapterVersion:nil];
}

- (instancetype)initWithName:(NSString *_Nonnull)name
                     version:(NSString *_Nonnull)sdkVersion
              adapterVersion:(NSString *_Nullable)adapterVersion {
    if (self = [super init]) {
        self.name = name;
        self.version = sdkVersion;
        self.adapterVersion = adapterVersion;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[OguryMediation alloc] initWithName:name version:version adapterVersion:adapterVersion];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSString *name = [coder decodeObjectForKey:@"name"];
    NSString *version = [coder decodeObjectForKey:@"version"];
    NSString *adapterVersion = [coder decodeObjectForKey:@"adapterVersion"];
    return [self initWithName:name version:version adapterVersion:adapterVersion];
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:version forKey:@"version"];
    [coder encodeObject:adapterVersion forKey:@"adapterVersion"];
}

- (BOOL)isEqual:(id)object {
    OguryMediation *other = (OguryMediation *)object;
    if (!object) {
        return NO;
    }
    return [name isEqualToString:other.name] && [version isEqualToString:other.version] && ((adapterVersion == nil && other.adapterVersion == nil) || [adapterVersion isEqualToString:other.adapterVersion]);
}

@end
