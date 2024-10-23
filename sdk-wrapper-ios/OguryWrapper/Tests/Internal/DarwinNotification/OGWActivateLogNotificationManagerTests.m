//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGWSetLogLevelNotificationManager.h"
#import <OCMock/OCMock.h>
#import "OGWWrapper.h"
#import "OGWLog.h"

@interface OGWSetLogLevelNotificationManager (OGWActivateLogNotificationManagerTests)

@property (nonatomic) CFNotificationCenterRef cFNotificationCenter;
@property (nonatomic, strong) OGWDarwinNotificationStringFormatter *stringFormatter;

- (instancetype)init:(CFNotificationCenterRef)cFNotificationCenter stringFormatter:(OGWDarwinNotificationStringFormatter *)stringFormatter;

@end

@interface OGWActivateLogNotificationManagerTests : XCTestCase

@end

@implementation OGWActivateLogNotificationManagerTests

- (void)testLocalCenter {
    OGWSetLogLevelNotificationManager *manager = [[OGWSetLogLevelNotificationManager alloc] init:CFNotificationCenterGetLocalCenter() stringFormatter:[[OGWDarwinNotificationStringFormatter alloc] init]];

    [manager registerToNotification];

    id mock = OCMPartialMock([OGWWrapper shared]);
    
    NSString *formattedString = [[manager stringFormatter] stringFromOGWDarwinNotificationIdentifier:OGWDarwinNotificationIdentifierLogAll];
    
    CFNotificationCenterPostNotification(manager.cFNotificationCenter, (__bridge CFStringRef)formattedString, nil, nil, CFNotificationSuspensionBehaviorDeliverImmediately);

    XCTestExpectation *expectation = [self expectationWithDescription:@"waiter"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        OCMVerify([mock setLogLevel:OguryLogLevelAll]);
        [expectation fulfill];
    });

    [self waitForExpectations:@[expectation] timeout:2];
}

- (void)testUnregisterLocalCenter {
    OGWSetLogLevelNotificationManager *manager = [[OGWSetLogLevelNotificationManager alloc] init:CFNotificationCenterGetLocalCenter() stringFormatter:[[OGWDarwinNotificationStringFormatter alloc] init]];

    manager.cFNotificationCenter = CFNotificationCenterGetLocalCenter();
    [manager registerToNotification];

    id mock = OCMPartialMock([OGWWrapper shared]);
    OCMReject([mock setLogLevel:OguryLogLevelAll]).ignoringNonObjectArgs();

    [manager unregisterFromNotification];

    NSString *formattedString = [[manager stringFormatter] stringFromOGWDarwinNotificationIdentifier:OGWDarwinNotificationIdentifierLogAll];
    CFNotificationCenterPostNotification(manager.cFNotificationCenter, (__bridge CFStringRef)formattedString, nil, nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"waiter"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectations:@[expectation] timeout:2];
}


@end
