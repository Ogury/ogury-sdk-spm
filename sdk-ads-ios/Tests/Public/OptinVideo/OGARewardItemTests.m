//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OguryAds/OGARewardItem.h>

@interface OGARewardItemTests : XCTestCase

@end

@implementation OGARewardItemTests

- (void)testInitWithRewardNameRewardValue {
    OGARewardItem *item = [[OGARewardItem alloc] initWithRewardName:@"rewardNameTest" rewardValue:@"RewardValue123"];

    XCTAssertEqualObjects(item.rewardName, @"rewardNameTest");
    XCTAssertEqualObjects(item.rewardValue, @"RewardValue123");
}

@end
