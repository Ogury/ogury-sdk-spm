//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdSequence.h"
#import "OGAAdConfiguration.h"
#import "OGAAdController.h"
#import "OGAAdSequenceCoordinator.h"
#import <OCMock/OCMock.h>

@interface OGAAdSequenceTests : XCTestCase

@end

@implementation OGAAdSequenceTests

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:[[OGAAdConfiguration alloc] init]];

    XCTAssertNotNil(sequence);
    XCTAssertNotNil(sequence.configuration);
}

- (void)testWhenUpdatingSessionIdThenAllAdControllersAreUpdated {
    OGAAdSequence *sequence = OCMPartialMock([[OGAAdSequence alloc] initWithAdConfiguration:[OGAAdConfiguration new]]);
    sequence.configuration.monitoringDetails = [OGAMonitoringDetails new];
    [sequence.configuration startNewMonitoringSession];
    OGAAdSequenceCoordinator *coord = OCMPartialMock([OGAAdSequenceCoordinator new]);
    OCMStub(sequence.coordinator).andReturn(coord);
    NSMutableArray<OGAAdController *> *controllers = [@[] mutableCopy];
    for (int index = 0; index < 2; index++) {
        OGAAdController *ctrl = OCMPartialMock([OGAAdController new]);
        OGAAd *ad = OCMPartialMock([OGAAd new]);
        ctrl.ad = ad;
        OGAAdConfiguration *conf = [OGAAdConfiguration new];
        conf.monitoringDetails = [OGAMonitoringDetails new];
        [conf startNewMonitoringSession];
        conf.monitoringDetails.sessionId = @"sessionId";
        ad.adConfiguration = conf;
        [controllers addObject:ctrl];
    }
    OCMStub(coord.adControllers).andReturn(controllers);
    [sequence updateReloadStateWithSessionId:@"newSessionId"];
    XCTAssertEqualObjects(sequence.configuration.monitoringDetails.sessionId, @"newSessionId");
    XCTAssertEqualObjects(sequence.coordinator.adControllers[0].ad.adConfiguration.monitoringDetails.sessionId, @"newSessionId");
    XCTAssertEqualObjects(sequence.monitoringAdConfiguration.monitoringDetails.sessionId, @"newSessionId");
    XCTAssertEqualObjects(sequence.coordinator.adControllers[1].ad.adConfiguration.monitoringDetails.sessionId, @"newSessionId");
}

@end
