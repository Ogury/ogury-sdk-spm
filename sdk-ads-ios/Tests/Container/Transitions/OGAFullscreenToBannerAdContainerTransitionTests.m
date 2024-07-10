//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAFullscreenToBannerAdContainerTransition.h"
#import "OGAFullscreenAdContainerState.h"
#import "OGABannerAdContainerState.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAAdDisplayerUpdateViewabilityInformation.h"

@interface OGAFullscreenToBannerAdContainerTransitionTests : XCTestCase

@end

@implementation OGAFullscreenToBannerAdContainerTransitionTests

#pragma mark - Constants

static NSString *const defaultAction = @"";

#pragma mark - Methods

- (void)testShouldInstantiate {
    OGAFullscreenToBannerAdContainerTransition *transition = [[OGAFullscreenToBannerAdContainerTransition alloc] initWithAction:defaultAction
                                                                                                                   initialState:[[OGAFullscreenAdContainerState alloc] init]
                                                                                                                     finalState:[[OGABannerAdContainerState alloc] init]];

    XCTAssertNotNil(transition);
    XCTAssertTrue([transition.initialState isKindOfClass:OGAFullscreenAdContainerState.self]);
    XCTAssertTrue([transition.finalState isKindOfClass:OGABannerAdContainerState.self]);
}

- (void)testShouldPerfomTransition {
    id<OGAAdDisplayer> fullscreenDisplayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAAdExposureController *fullscreenExposureController = OCMClassMock(OGAAdExposureController.self);
    OGAFullscreenAdContainerState *initialState = OCMClassMock(OGAFullscreenAdContainerState.self);
    OCMStub([initialState displayer]).andReturn(fullscreenDisplayer);
    OCMStub([initialState exposureController]).andReturn(fullscreenExposureController);

    OGAAdExposureController *bannerExposureController = OCMClassMock(OGAAdExposureController.self);
    OGABannerAdContainerState *finalState = OCMClassMock(OGABannerAdContainerState.self);
    OCMStub([finalState exposureController]).andReturn(bannerExposureController);

    OGAFullscreenToBannerAdContainerTransition *transition = OCMPartialMock([[OGAFullscreenToBannerAdContainerTransition alloc] initWithAction:defaultAction
                                                                                                                                  initialState:initialState
                                                                                                                                    finalState:finalState]);

    NSError *error;

    [transition performTransition:&error];

    OCMVerify([initialState cleanUp]);
    OCMVerify([fullscreenExposureController stopExposure]);
    OCMVerify([bannerExposureController startExposure]);
    OCMVerify([finalState display:fullscreenDisplayer error:[OCMArg anyObjectRef]]);
}

@end
