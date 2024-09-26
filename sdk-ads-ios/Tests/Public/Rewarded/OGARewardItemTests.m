//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OguryAds/OguryAds.h>

@interface OGARewardItemTests : XCTestCase

@end

@implementation OGARewardItemTests

- (void)testInitWithRewardNameRewardValue {
    OguryRewardItem *item = [[OguryRewardItem alloc] initWithRewardName:@"rewardNameTest" rewardValue:@"RewardValue123"];

    XCTAssertEqualObjects(item.rewardName, @"rewardNameTest");
    XCTAssertEqualObjects(item.rewardValue, @"RewardValue123");
}

@end
