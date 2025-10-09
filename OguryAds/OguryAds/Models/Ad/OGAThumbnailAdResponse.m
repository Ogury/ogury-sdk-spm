//
//  OGAThumbnailAdResponse.m
//  OguryAds
//
//  Created by Mihai-Cristian SAVA on 9/5/19.
//  Copyright © 2019 Ogury. All rights reserved.
//

#import "OGAThumbnailAdResponse.h"

@implementation OGAThumbnailAdResponse

- (instancetype)init {
    self = [super init];
    if (self) {
        self.disableMultiActivity = [[NSNumber alloc] initWithBool:NO];
        self.draggable = @"true";
    }
    return self;
}

+ (OGAJSONKeyMapper *)keyMapper {
    return [[OGAJSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"height" : @"initial_size.height",
        @"draggable" : @"draggable",
        @"disableMultiActivity" : @"disable_multi_activity",
        @"width" : @"initial_size.width",
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return true;
}

@end
