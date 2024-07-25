//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGCDarwinNotificationStringFormatter.h"
#import "OGCInternal.h"

@interface OGCDarwinNotificationStringFormatterTests : XCTestCase

@end

@implementation OGCDarwinNotificationStringFormatterTests

- (void)testStringFromLogAll {
    OGCDarwinNotificationStringFormatter *formatter = [[OGCDarwinNotificationStringFormatter alloc] init];

    NSString *expected = [[NSString alloc] initWithFormat:@"%@.co.ogury.core.loglevel.%@", [[NSBundle mainBundle] bundleIdentifier], @"all"];
    
    XCTAssertTrue([expected isEqualToString:[formatter stringFromOGCDarwinNotificationIdentifier:OGCDarwinNotificationIdentifierLogAll]]);
}

@end
