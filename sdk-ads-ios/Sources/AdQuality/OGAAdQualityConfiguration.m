//
//  OGAAdQualityConfiguration.m
//  OguryAds
//
//  Created by Jerome TONNELIER on 28/08/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import "OGAAdQualityConfiguration.h"

@implementation OGAAdQualityBlankAdConfiguration
@synthesize isEnabled, algos;

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSArray<OGAAdQualityUniformColorRectAlgorithm *> *algo = [coder decodeObjectForKey:@"algo"];
    BOOL isEnabled = [coder decodeBoolForKey:@"enabled"];
    return [self initWithAlgos:algo isEnabled:isEnabled ?: NO];
}

- (instancetype)initWithAlgos:(NSArray<OGAAdQualityUniformColorRectAlgorithm *> *_Nullable)algos isEnabled:(BOOL)isEnabled {
    if (self = [super init]) {
        self.algos = algos;
        self.isEnabled = isEnabled;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.algos = @[];
        self.isEnabled = NO;
    }
    return self;
}

@end

@implementation OGAAdQualityConfiguration
@synthesize blankAdConfiguration;

- (instancetype)initWithCoder:(NSCoder *)coder {
    OGAAdQualityBlankAdConfiguration *blankAdConfiguration = [coder decodeObjectForKey:@"blank_ad_detection"];
    return [self initWithConfiguration:blankAdConfiguration];
}

- (instancetype)initWithConfiguration:(OGAAdQualityBlankAdConfiguration *_Nullable)blankAdConfiguration {
    if (self = [super init]) {
        self.blankAdConfiguration = blankAdConfiguration;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.blankAdConfiguration = [OGAAdQualityBlankAdConfiguration new];
    }
    return self;
}
@end
