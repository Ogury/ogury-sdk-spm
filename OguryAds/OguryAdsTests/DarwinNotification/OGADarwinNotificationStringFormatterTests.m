//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGADarwinNotificationStringFormatter.h"
#import "OGAInternal.h"

@interface OGADarwinNotificationStringFormatterTests : XCTestCase

@end

@implementation OGADarwinNotificationStringFormatterTests

- (void)testStringFromLogAll {
    OGADarwinNotificationStringFormatter *formatter = [[OGADarwinNotificationStringFormatter alloc] init];

    NSString *expected = [[NSString alloc] initWithFormat:@"%@.co.ogury.OguryAds.loglevel.all", [[NSBundle mainBundle] bundleIdentifier]];

    XCTAssertTrue([expected isEqualToString:[formatter stringFromOGADarwinNotificationIdentifier:OGADarwinNotificationIdentifierLogAll]]);
}

@end
