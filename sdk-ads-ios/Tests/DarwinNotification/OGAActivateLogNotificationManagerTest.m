//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGASetLogLevelNotificationManager.h"
#import <OCMock/OCMock.h>
#import "OGAInternal.h"
#import "OGALog.h"

@interface OGADarwinNotificationStringFormatter (OGAActivateLogNotificationManagerTests)

@property(nonatomic, strong) OGALog *log;

- (instancetype)init:(OGALog *)log;

@end

@interface OGASetLogLevelNotificationManager (OGAActivateLogNotificationManagerTests)

@property(nonatomic) CFNotificationCenterRef cFNotificationCenter;
@property(nonatomic, strong) OGADarwinNotificationStringFormatter *stringFormatter;
@property(nonatomic, strong) OGALog *log;

- (instancetype)init:(CFNotificationCenterRef)cFNotificationCenter stringFormatter:(OGADarwinNotificationStringFormatter *)stringFormatter log:(OGALog *)log;

@end

@interface OGAActivateLogNotificationManagerTests : XCTestCase

@end

@implementation OGAActivateLogNotificationManagerTests

- (void)testLocalCenter {
    //    OGASetLogLevelNotificationManager *manager = [[OGASetLogLevelNotificationManager alloc] init:CFNotificationCenterGetLocalCenter() stringFormatter:[[OGADarwinNotificationStringFormatter alloc] init:[OGALog shared]] log:[OGALog shared]];
    //
    //    [manager registerToNotification];
    //    id mock = OCMPartialMock([OGAInternal shared]);
    //
    //    NSString *formattedString = [[manager stringFormatter] stringFromOGADarwinNotificationIdentifier:OGADarwinNotificationIdentifierLogAll];
    //
    //    CFNotificationCenterPostNotification(manager.cFNotificationCenter, (__bridge CFStringRef)formattedString, nil, nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    //
    //    XCTestExpectation *expectation = [self expectationWithDescription:@"waiter"];
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        OCMVerify([mock setLogLevel:OguryLogLevelAll]);
    //        [expectation fulfill];
    //    });
    //
    //    [self waitForExpectations:@[expectation] timeout:2];
}

- (void)testUnregisterLocalCenter {
    //    OGASetLogLevelNotificationManager *manager = [[OGASetLogLevelNotificationManager alloc] init:CFNotificationCenterGetLocalCenter() stringFormatter:[[OGADarwinNotificationStringFormatter alloc] init:[[OGALog alloc] init]] log:[[OGALog alloc] init]];
    //
    //    manager.cFNotificationCenter = CFNotificationCenterGetLocalCenter();
    //    [manager registerToNotification];
    //
    //    id mock = OCMPartialMock([OGAInternal shared]);
    //    OCMReject([mock setLogLevel:OguryLogLevelAll]).ignoringNonObjectArgs();
    //
    //    [manager unregisterFromNotification];
    //
    //    NSString *formattedString = [[manager stringFormatter] stringFromOGADarwinNotificationIdentifier:OGADarwinNotificationIdentifierLogAll];
    //    CFNotificationCenterPostNotification(manager.cFNotificationCenter, (__bridge CFStringRef)formattedString, nil, nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    //
    //    XCTestExpectation *expectation = [self expectationWithDescription:@"waiter"];
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [expectation fulfill];
    //    });
    //    [self waitForExpectations:@[expectation] timeout:2];
}

@end
