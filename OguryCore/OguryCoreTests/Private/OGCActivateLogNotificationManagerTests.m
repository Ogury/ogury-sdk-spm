//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGCSetLogLevelNotificationManager.h"
#import <OCMock/OCMock.h>
#import "OGCInternal.h"
#import "OguryLogLevel.h"
#import "OGCLog.h"

@interface OGCDarwinNotificationStringFormatter (OGCActivateLogNotificationManagerTests)

@property (nonatomic, strong) OGCLog *log;

- (instancetype)init:(OGCLog *)log;

@end

@interface OGCSetLogLevelNotificationManager (OGCActivateLogNotificationManagerTests)

@property (nonatomic) CFNotificationCenterRef cFNotificationCenter;
@property (nonatomic, strong) OGCDarwinNotificationStringFormatter *stringFormatter;
@property (nonatomic, strong) OGCLog *log;

- (instancetype)init:(CFNotificationCenterRef)cFNotificationCenter stringFormatter:(OGCDarwinNotificationStringFormatter *)stringFormatter log:(OGCLog *)log;

@end

@interface OGCActivateLogNotificationManagerTests : XCTestCase

@end

@implementation OGCActivateLogNotificationManagerTests

- (void)testLocalCenter {
    OGCSetLogLevelNotificationManager *manager = [[OGCSetLogLevelNotificationManager alloc] init:CFNotificationCenterGetLocalCenter() stringFormatter:[[OGCDarwinNotificationStringFormatter alloc] init:[[OGCLog alloc] init]] log:[[OGCLog alloc] init]];

    [manager registerToNotification];

    id mock = OCMPartialMock([OGCInternal shared]);
    
    NSString *formattedString = [[manager stringFormatter] stringFromOGCDarwinNotificationIdentifier:OGCDarwinNotificationIdentifierLogAll];
    
    CFNotificationCenterPostNotification(manager.cFNotificationCenter, (__bridge CFStringRef)formattedString, nil, nil, CFNotificationSuspensionBehaviorDeliverImmediately);

    XCTestExpectation *expectation = [self expectationWithDescription:@"waiter"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        OCMVerify([mock setLogLevel:OguryLogLevelAll]);
        [expectation fulfill];
    });

    [self waitForExpectations:@[expectation] timeout:2];
}

- (void)testUnregisterLocalCenter {
    OGCSetLogLevelNotificationManager *manager = [[OGCSetLogLevelNotificationManager alloc] init:CFNotificationCenterGetLocalCenter() stringFormatter:[[OGCDarwinNotificationStringFormatter alloc] init:[[OGCLog alloc] init]] log:[[OGCLog alloc] init]];

    manager.cFNotificationCenter = CFNotificationCenterGetLocalCenter();
    [manager registerToNotification];

    id mock = OCMPartialMock([OGCInternal shared]);
    OCMReject([mock setLogLevel:OguryLogLevelAll]).ignoringNonObjectArgs();

    [manager unregisterFromNotification];

    NSString *formattedString = [[manager stringFormatter] stringFromOGCDarwinNotificationIdentifier:OGCDarwinNotificationIdentifierLogAll];
    CFNotificationCenterPostNotification(manager.cFNotificationCenter, (__bridge CFStringRef)formattedString, nil, nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"waiter"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectations:@[expectation] timeout:2];
}


@end
