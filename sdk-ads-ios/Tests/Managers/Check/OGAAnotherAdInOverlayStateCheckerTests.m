//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAAdManager+Check.h"
#import "OGAAdSequenceCoordinator.h"
#import "OGAAnotherAdInFullScreenOverlayStateChecker.h"

@interface OGAAnotherAdInFullScreenOverlayStateChecker ()

- (instancetype)initWithAdManager:(OGAAdManager *)adManager;

- (BOOL)isAnotherAdInFullScreenOverlayState:(OGAAdSequence *)sequence;

@end

@interface OGAAnotherAdInOverlayStateCheckerTests : XCTestCase

@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) NSHashTable *sequencesShowing;

@property(nonatomic, strong) OGAAnotherAdInFullScreenOverlayStateChecker *checker;

@end

@implementation OGAAnotherAdInOverlayStateCheckerTests

- (void)setUp {
    self.adManager = OCMClassMock([OGAAdManager class]);
    self.sequencesShowing = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];

    OCMStub(self.adManager.sequencesShowing).andReturn(self.sequencesShowing);

    OGAAnotherAdInFullScreenOverlayStateChecker *checker = [[OGAAnotherAdInFullScreenOverlayStateChecker alloc] initWithAdManager:self.adManager];
    self.checker = OCMPartialMock(checker);
}

#pragma mark - Methods

- (void)testCheckForSequence_noSequenceInOverlay {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub([self.checker isAnotherAdInFullScreenOverlayState:sequence]).andReturn(NO);

    OguryError *error;
    XCTAssertTrue([self.checker checkForSequence:sequence error:&error]);

    XCTAssertNil(error);
}

- (void)testCheckForSequence_anotherSequenceInOverlay {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub([self.checker isAnotherAdInFullScreenOverlayState:sequence]).andReturn(YES);

    OguryError *error;
    XCTAssertFalse([self.checker checkForSequence:sequence error:&error]);

    XCTAssertEqual(error.code, OguryAdsAnotherAdAlreadyDisplayedError);
}

- (void)testIsAnotherAdInOverlayState_anotherSequenceInOverlay {
    OGAAdSequenceCoordinator *coordinator = OCMClassMock([OGAAdSequenceCoordinator class]);
    OCMStub(coordinator.isFullScreenOverlay).andReturn(YES);
    OGAAdSequence *anotherSequence = OCMClassMock([OGAAdSequence class]);
    OCMStub(anotherSequence.coordinator).andReturn(coordinator);
    [self.sequencesShowing addObject:anotherSequence];

    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    OCMStub(configuration.adType).andReturn(OguryAdsTypeInterstitial);

    XCTAssertTrue([self.checker isAnotherAdInFullScreenOverlayState:sequence]);
}

- (void)testIsAnotherAdInOverlayState_noOtherSequenceInOverlay {
    OGAAdSequenceCoordinator *coordinator = OCMClassMock([OGAAdSequenceCoordinator class]);
    OCMStub(coordinator.isFullScreenOverlay).andReturn(NO);
    OGAAdSequence *anotherSequence = OCMClassMock([OGAAdSequence class]);
    OCMStub(anotherSequence.coordinator).andReturn(coordinator);
    [self.sequencesShowing addObject:anotherSequence];

    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    OCMStub(configuration.adType).andReturn(OguryAdsTypeInterstitial);

    XCTAssertFalse([self.checker isAnotherAdInFullScreenOverlayState:sequence]);
}

@end
