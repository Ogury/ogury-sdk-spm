//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGAAdUnit.h"

@implementation OGAAdUnit
+ (OGAJSONKeyMapper *)keyMapper {
    return [[OGAJSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"identifier" : @"id",
        @"appUserId" : @"app_user_id",
        @"rewardLaunch" : @"reward_launch",
        @"rewardName" : @"reward_name",
        @"rewardValue" : @"reward_value"
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return true;
}

@end
