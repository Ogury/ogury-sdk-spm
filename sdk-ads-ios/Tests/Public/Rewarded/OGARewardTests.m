//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OguryAds/OguryAds.h>

@interface OGARewardTests : XCTestCase

@end

@implementation OGARewardTests

- (void)testInitWithRewardNameRewardValue {
    OguryReward *reward = [[OguryReward alloc] initWithRewardName:@"rewardNameTest" rewardValue:@"RewardValue123"];

    XCTAssertEqualObjects(reward.rewardName, @"rewardNameTest");
    XCTAssertEqualObjects(reward.rewardValue, @"RewardValue123");
}

@end
