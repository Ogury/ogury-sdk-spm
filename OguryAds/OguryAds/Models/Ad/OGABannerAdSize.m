//
//  OGABannerAdSize.m
//  OguryAdsSDK
//
//  Created by nicolas perret on 03/06/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import "OGABannerAdSize.h"
#import <UIKit/UIKit.h>

@implementation OGABannerAdSize

#pragma mark - Methods

+ (OGAJSONKeyMapper *)keyMapper {
    return [[OGAJSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"height" : @"h",
        @"width" : @"w"
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return false;
}

- (CGSize)size {
    return CGSizeMake([self.width intValue], [self.height intValue]);
}

@end
