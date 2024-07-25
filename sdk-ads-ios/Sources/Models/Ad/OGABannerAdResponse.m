//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGABannerAdResponse.h"

@implementation OGABannerAdResponse

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        _autoRefresh = @(NO);
    }

    return self;
}

#pragma mark - Methods

+ (OGAJSONKeyMapper *)keyMapper {
    return [[OGAJSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"autoRefresh" : @"auto_refresh",
        @"autoRefreshRate" : @"auto_refresh_rate",
        @"fullWidth" : @"full_width"
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return true;
}

- (BOOL)isFullScreen {
    return (self.fullWidth && self.fullWidth.boolValue);
}

@end
