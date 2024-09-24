//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAAnotherAdOfSameTypeAlreadyDisplayedChecker.h"
#import "OGAAdManager+Check.h"
#import "OGAAdSequenceCoordinator.h"

@interface OGAAnotherAdOfSameTypeAlreadyDisplayedChecker ()

- (instancetype)initWithAdManager:(OGAAdManager *)adManager;

- (BOOL)isAnotherAdOfSameTypeAlreadyDisplayed:(OGAAdSequence *)sequence;

@end

@interface OGAAnotherAdOfSameTypeAlreadyDisplayedCheckerTests : XCTestCase

@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) NSHashTable *sequencesShowing;

@property(nonatomic, strong) OGAAdSequence *sequence;
@property(nonatomic, strong) OGAAdConfiguration *configuration;
@property(nonatomic, strong) OGAAdSequence *anotherSequence;
@property(nonatomic, strong) OGAAdConfiguration *anotherConfiguration;

@property(nonatomic, strong) OGAAnotherAdOfSameTypeAlreadyDisplayedChecker *checker;

@end

@implementation OGAAnotherAdOfSameTypeAlreadyDisplayedCheckerTests

- (void)setUp {
    self.adManager = OCMClassMock([OGAAdManager class]);
    self.sequencesShowing = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];

    self.sequence = OCMClassMock([OGAAdSequence class]);
    self.configuration = OCMClassMock([OGAAdConfiguration class]);
    self.anotherSequence = OCMClassMock([OGAAdSequence class]);
    self.anotherConfiguration = OCMClassMock([OGAAdConfiguration class]);

    OCMStub(self.adManager.sequencesShowing).andReturn(self.sequencesShowing);
    OCMStub(self.sequence.configuration).andReturn(self.configuration);
    OCMStub(self.anotherSequence.configuration).andReturn(self.anotherConfiguration);

    OGAAnotherAdOfSameTypeAlreadyDisplayedChecker *checker = [[OGAAnotherAdOfSameTypeAlreadyDisplayedChecker alloc] initWithAdManager:self.adManager];
    self.checker = OCMPartialMock(checker);
}

#pragma mark - Methods

- (void)testCheckForSequence_noAdOfSameTypeDisplayed {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub([self.checker isAnotherAdOfSameTypeAlreadyDisplayed:sequence]).andReturn(NO);

    OguryError *error;
    XCTAssertTrue([self.checker checkForSequence:sequence error:&error]);

    XCTAssertNil(error);
}

- (void)testCheckForSequence_anotherAdOfSameTypeDisplayed {
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub([self.checker isAnotherAdOfSameTypeAlreadyDisplayed:sequence]).andReturn(YES);

    OguryError *error;
    XCTAssertFalse([self.checker checkForSequence:sequence error:&error]);

    XCTAssertEqual(error.code, OguryAdErrorCodeAnotherAdIsAlreadyDisplayed);
}

- (void)testIsAnotherAdOfSameTypeAlreadyDisplayed_noOtherAd {
    XCTAssertFalse([self.checker isAnotherAdOfSameTypeAlreadyDisplayed:self.sequence]);
}

- (void)testIsAnotherAdOfSameTypeAlreadyDisplayed_anotherAdOfSameTypeDisplayed {
    OCMStub(self.configuration.adType).andReturn(OguryAdsTypeInterstitial);
    OCMStub(self.anotherConfiguration.adType).andReturn(OguryAdsTypeInterstitial);
    OGAAdSequenceCoordinator *coordinator = OCMClassMock([OGAAdSequenceCoordinator class]);
    OCMStub(coordinator.isDisplayed).andReturn(YES);
    OCMStub(self.anotherSequence.coordinator).andReturn(coordinator);
    [self.sequencesShowing addObject:self.anotherSequence];

    XCTAssertTrue([self.checker isAnotherAdOfSameTypeAlreadyDisplayed:self.sequence]);
}

- (void)testIsAnotherAdOfSameTypeAlreadyDisplayed_anotherAdOfSameTypeButNotDisplayed {
    OCMStub(self.configuration.adType).andReturn(OguryAdsTypeInterstitial);
    OCMStub(self.anotherConfiguration.adType).andReturn(OguryAdsTypeInterstitial);
    OGAAdSequenceCoordinator *coordinator = OCMClassMock([OGAAdSequenceCoordinator class]);
    OCMStub(coordinator.isDisplayed).andReturn(NO);
    OCMStub(self.anotherSequence.coordinator).andReturn(coordinator);
    [self.sequencesShowing addObject:self.anotherSequence];

    XCTAssertFalse([self.checker isAnotherAdOfSameTypeAlreadyDisplayed:self.sequence]);
}

- (void)testIsAnotherAdOfSameTypeAlreadyDisplayed_anotherAdDisplayedButNotOfTheSameType {
    OCMStub(self.configuration.adType).andReturn(OguryAdsTypeInterstitial);
    OCMStub(self.anotherConfiguration.adType).andReturn(OguryAdsTypeRewardedAd);
    OGAAdSequenceCoordinator *coordinator = OCMClassMock([OGAAdSequenceCoordinator class]);
    OCMStub(coordinator.isDisplayed).andReturn(NO);
    OCMStub(self.anotherSequence.coordinator).andReturn(coordinator);
    [self.sequencesShowing addObject:self.anotherSequence];

    XCTAssertFalse([self.checker isAnotherAdOfSameTypeAlreadyDisplayed:self.sequence]);
}

@end
