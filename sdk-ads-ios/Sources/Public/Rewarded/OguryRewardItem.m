//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryRewardItem.h"

@implementation OguryRewardItem

- (instancetype)initWithRewardName:(NSString *)rewardName rewardValue:(NSString *)rewardValue {
    if (self = [super init]) {
        _rewardName = rewardName;
        _rewardValue = rewardValue;
    }
    return self;
}

@end
