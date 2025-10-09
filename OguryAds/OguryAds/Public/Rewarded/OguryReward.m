//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OguryReward.h"

@implementation OguryReward

- (instancetype)initWithRewardName:(NSString *)rewardName rewardValue:(NSString *)rewardValue {
    if (self = [super init]) {
        _rewardName = rewardName;
        _rewardValue = rewardValue;
    }
    return self;
}

@end
