//
//  OGASdkConsumer.m
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 05/02/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import "OGASdkConsumer.h"

@implementation OGASdkConsumer

- (instancetype)initWithName:(NSString *_Nonnull)name version:(NSString *_Nonnull)version {
    if (self = [super init]) {
        _name = name;
        _version = version;
    }
    return self;
}

@end
