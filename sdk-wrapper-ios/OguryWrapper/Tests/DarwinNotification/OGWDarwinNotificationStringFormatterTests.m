//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGWDarwinNotificationStringFormatter.h"
#import "OGWWrapper.h"

@interface OGWDarwinNotificationStringFormatterTests : XCTestCase

@end

@implementation OGWDarwinNotificationStringFormatterTests

- (void)testStringFromLogAll {
    OGWDarwinNotificationStringFormatter *formatter = [[OGWDarwinNotificationStringFormatter alloc] init];

    NSString *expected = [[NSString alloc] initWithFormat:@"%@.co.ogury.loglevel.all", [[NSBundle mainBundle] bundleIdentifier]];

    XCTAssertTrue([expected isEqualToString:[formatter stringFromOGWDarwinNotificationIdentifier:OGWDarwinNotificationIdentifierLogAll]]);
}

@end
