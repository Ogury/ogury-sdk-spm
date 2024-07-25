//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAAdExpirationManager.h"
#import "OGAAdExpirationManager+Testing.h"
#import "OGAAd.h"
#import "OGAMetricsService.h"
#import "OGATrackEvent.h"

static NSString *const OGAAdExpirationManagerTestsDefaultAdIdentifier = @"ad-identifier";
static NSString *const OGAAdExpirationManagerTestsDefaultAdLocalIdentifier = @"ad-local-identifier";

@interface OGAAdExpirationManagerTests : XCTestCase

#pragma mark - Properties

@property(nonatomic, strong) OGAAd *ad;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong) OGAAdExpirationManager *adExpirationManager;

@end

@implementation OGAAdExpirationManagerTests

- (void)setUp {
    self.ad = OCMClassMock(OGAAd.self);
    self.log = OCMClassMock([OGALog class]);
    OCMStub(self.ad.identifier).andReturn(OGAAdExpirationManagerTestsDefaultAdIdentifier);

    self.metricsService = OCMClassMock(OGAMetricsService.self);
    self.adExpirationManager = OCMPartialMock([[OGAAdExpirationManager alloc] initWithMetricsService:self.metricsService log:self.log]);
}

#pragma mark - Methods

- (void)testShouldSendExpirationTrackerEvent {
    OCMStub(self.ad.localIdentifier).andReturn(OGAAdExpirationManagerTestsDefaultAdLocalIdentifier);

    [self.adExpirationManager sendExpirationTrackerEventForAd:self.ad];

    __block OGATrackEvent *event;
    OCMVerify([self.metricsService sendEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                       if ([obj isKindOfClass:[OGATrackEvent class]]) {
                                           event = obj;
                                           return YES;
                                       }
                                       return NO;
                                   }]]);

    XCTAssertNotNil(event);
    XCTAssertEqualObjects(event.advertId, OGAAdExpirationManagerTestsDefaultAdIdentifier);
}

- (void)testShouldNotSendExpirationTrackerEventIfLocalIdentifierIsNotPresent {
    OCMStub(self.ad.localIdentifier).andReturn(nil);

    [self.adExpirationManager sendExpirationTrackerEventForAd:self.ad];

    OCMReject([self.metricsService enqueueEvent:OCMOCK_ANY]);
}

- (void)testShouldNotSendExpirationTrackerEventTwiceForTheSameAd {
    OCMStub(self.ad.localIdentifier).andReturn(OGAAdExpirationManagerTestsDefaultAdLocalIdentifier);

    self.adExpirationManager.expirationTrackersSentByAdLocalIdentifiers[OGAAdExpirationManagerTestsDefaultAdLocalIdentifier] = @(YES);

    [self.adExpirationManager sendExpirationTrackerEventForAd:self.ad];

    OCMReject([self.metricsService enqueueEvent:OCMOCK_ANY]);
}

@end
