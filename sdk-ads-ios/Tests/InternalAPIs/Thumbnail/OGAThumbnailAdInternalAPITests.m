//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAThumbnailAdInternalAPI.h"
#import "OGAThumbnailAdInternalAPI+Testing.h"
#import "OGAAdManager.h"
#import <OCMock/OCMock.h>
#import "OGAThumbnailAdConstants.h"
#import "OGALog.h"

@interface OGAThumbnailAdInternalAPITests : XCTestCase

@property(nonatomic, strong) OGADelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) OGAInternetConnectionChecker *internetConnectionChecker;
@property(nonatomic, strong) OGAAnotherAdOfSameTypeAlreadyDisplayedChecker *anotherAdOfSameTypeAlreadyDisplayedChecker;
@property(nonatomic, strong) OGAThumbnailAdInternalAPI *internalAPI;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAInternal *internal;

@end

@implementation OGAThumbnailAdInternalAPITests

#pragma mark - Constants

static NSString *const TestAdUnitId = @"AD-UNIT-ID";
static NSString *const TestCampaignId1 = @"CAMPAIGN-ID1";
static NSString *const TestCampaignId2 = @"CAMPAIGN-ID2";

#pragma mark - Methods

- (void)setUp {
    self.log = OCMClassMock([OGALog class]);
    self.delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    self.adManager = OCMClassMock([OGAAdManager class]);
    self.internal = OCMClassMock([OGAInternal class]);
    self.internetConnectionChecker = OCMClassMock([OGAInternetConnectionChecker class]);
    self.anotherAdOfSameTypeAlreadyDisplayedChecker = OCMClassMock([OGAAnotherAdOfSameTypeAlreadyDisplayedChecker class]);
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    self.internalAPI = [[OGAThumbnailAdInternalAPI alloc] initWithAdUnitId:TestAdUnitId
                                                        delegateDispatcher:self.delegateDispatcher
                                                                 adManager:self.adManager
                                                 internetConnectionChecker:self.internetConnectionChecker
                                anotherAdOfSameTypeAlreadyDisplayedChecker:self.anotherAdOfSameTypeAlreadyDisplayedChecker
                                                      monitoringDispatcher:self.monitoringDispatcher
                                                                  internal:self.internal
                                                                 mediation:nil
                                                                       log:self.log];
}

- (void)testIsLoaded {
    self.internalAPI.sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub([self.adManager isLoaded:self.internalAPI.sequence]).andReturn(YES);

    XCTAssertTrue([self.internalAPI isLoaded]);
    OCMVerify([self.adManager isLoaded:self.internalAPI.sequence]);
}

- (void)test_ShouldReturnIsExpanded {
    self.internalAPI.sequence = OCMClassMock([OGAAdSequence class]);

    OCMStub([self.adManager isExpanded:self.internalAPI.sequence]).andReturn(YES);

    XCTAssertTrue(self.internalAPI.isExpanded);

    OCMVerify([self.adManager isExpanded:self.internalAPI.sequence]);
}

- (void)testLoad {
    OGAThumbnailAdInternalAPI *internal = OCMPartialMock(self.internalAPI);
    OCMStub([internal loadWithMaxSize:CGSizeMake(180, 180)]);

    [internal load];

    OCMVerify([internal loadWithMaxSize:CGSizeMake(180, 180)]);
}

- (void)testLoad_withThumbnailSize {
    CGSize size = CGSizeMake(120, 120);
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    self.internalAPI.sequence = previousSequence;
    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    OCMStub([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:[OCMArg any]]).andReturn(sequence);
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.internalAPI.configuration);

    [self.internalAPI loadWithMaxSize:size];

    XCTAssertEqual(self.internalAPI.sequence, sequence);
    XCTAssertTrue(CGSizeEqualToSize(self.internalAPI.configuration.size, size));
    XCTAssertNil(self.internalAPI.configuration.campaignId);
    OCMVerify([self.adManager loadAdConfiguration:self.internalAPI.configuration previousSequence:previousSequence]);
}

- (void)testLoadWithCampaignIdAndThumbnailSize {
    CGSize size = CGSizeMake(120, 120);
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    self.internalAPI.sequence = previousSequence;
    OCMStub([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:[OCMArg any]]).andReturn(sequence);
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.internalAPI.configuration);

    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    [self.internalAPI loadWithCampaignId:TestCampaignId1 thumbnailSize:CGSizeMake(120, 120)];

    XCTAssertEqual(self.internalAPI.sequence, sequence);
    XCTAssertTrue(CGSizeEqualToSize(self.internalAPI.configuration.size, size));
    XCTAssertEqualObjects(self.internalAPI.configuration.campaignId, TestCampaignId1);
    OCMVerify([self.adManager loadAdConfiguration:self.internalAPI.configuration previousSequence:previousSequence]);
}

- (void)testShowWithOguryRectCornerAndMargin_WithSequence {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    self.internalAPI.sequence = sequence;
    [self.internalAPI showWithOguryRectCorner:OguryRectCornerTopLeft margin:OguryOffsetMake(10, 20)];

    OCMVerify([configuration setOffset:OguryOffsetMake(10, 20)]);
    OCMVerify([configuration setCorner:OguryRectCornerTopLeft]);

    __block NSArray<id<OGAConditionChecker>> *additionalConditions;
    OCMVerify([self.adManager show:sequence
              additionalConditions:[OCMArg checkWithBlock:^BOOL(id obj) {
                  additionalConditions = obj;
                  return YES;
              }]]);
    XCTAssertEqual(additionalConditions.count, 1);
    XCTAssertEqual(additionalConditions[0], self.anotherAdOfSameTypeAlreadyDisplayedChecker);
}

- (void)testLoadWithCampaignId {
    OGAThumbnailAdInternalAPI *internal = OCMPartialMock(self.internalAPI);
    OCMStub([internal loadWithCampaignId:TestCampaignId1 creativeId:nil]);

    [internal loadWithCampaignId:TestCampaignId1];

    OCMVerify([internal loadWithCampaignId:TestCampaignId1 creativeId:nil]);
}

- (void)testShow {
    OGAThumbnailAdInternalAPI *internal = OCMPartialMock(self.internalAPI);
    OCMStub([internal showWithOguryRectCorner:OguryRectCornerTopLeft margin:OguryOffsetMake(OGAThumbnailDefaultXOffset, OGAThumbnailDefaultYOffset)]);
    [internal show];
    OCMVerify([internal showWithOguryRectCorner:OguryRectCornerBottomRight margin:OguryOffsetMake(OGAThumbnailDefaultXOffset, OGAThumbnailDefaultYOffset)]);
}

- (void)testShowWithPosition {
    OGAThumbnailAdInternalAPI *internal = OCMPartialMock(self.internalAPI);
    OCMStub([internal showWithOguryRectCorner:OguryRectCornerTopLeft margin:OguryOffsetMake(10, 20)]);
    [internal show:CGPointMake(10, 20)];
    OCMVerify([internal showWithOguryRectCorner:OguryRectCornerTopLeft margin:OguryOffsetMake(10, 20)]);
}

- (void)testShowInSceneWithOguryRectCornerWithMargin API_AVAILABLE(ios(13.0)) {
    OGAThumbnailAdInternalAPI *internal = OCMPartialMock(self.internalAPI);
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    self.internalAPI.sequence = sequence;
    UIWindowScene *scene = OCMClassMock([UIWindowScene class]);
    internal.scene = scene;
    [internal showWithOguryRectCorner:OguryRectCornerBottomRight margin:OguryOffsetMake(OGAThumbnailDefaultXOffset, OGAThumbnailDefaultYOffset)];
    OCMVerify([internal showWithOguryRectCorner:OguryRectCornerBottomRight margin:OguryOffsetMake(OGAThumbnailDefaultXOffset, OGAThumbnailDefaultYOffset)]);
    OCMVerify([configuration setScene:scene]);
}

- (void)testShowInSceneAtPosition API_AVAILABLE(ios(13.0)) {
    OGAThumbnailAdInternalAPI *internal = OCMPartialMock(self.internalAPI);
    UIWindowScene *scene = OCMClassMock([UIWindowScene class]);
    internal.scene = scene;
    [internal show:CGPointMake(10, 20)];
    OCMVerify([internal showWithOguryRectCorner:OguryRectCornerTopLeft margin:OguryOffsetMake(10, 20)]);
}

- (void)testSetBlacklistViewControllers_WithoutSequence {
    OGAThumbnailAdInternalAPI *internal = OCMPartialMock(self.internalAPI);
    internal.sequence = nil;
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    internal.configuration = configuration;
    NSArray *viewControllers = OCMClassMock([NSArray class]);
    [internal setBlacklistViewControllers:viewControllers];
    OCMVerify([configuration setBlackListViewControllers:viewControllers]);
}

- (void)testSetBlacklistViewControllers_WithSequence {
    OGAThumbnailAdInternalAPI *internal = OCMPartialMock(self.internalAPI);
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    internal.sequence = sequence;
    internal.configuration = configuration;
    NSArray *viewControllers = OCMClassMock([NSArray class]);
    [internal setBlacklistViewControllers:viewControllers];
    OCMVerify([configuration setBlackListViewControllers:viewControllers]);
}

- (void)testSetWhiteListBundleIdentifier_WithoutSequence {
    OGAThumbnailAdInternalAPI *internal = OCMPartialMock(self.internalAPI);
    internal.sequence = nil;
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    internal.configuration = configuration;
    NSArray *bundleIdentifiers = OCMClassMock([NSArray class]);
    [internal setWhitelistBundleIdentifiers:bundleIdentifiers];
    OCMVerify([configuration setWhitelistBundleIdentifiers:bundleIdentifiers]);
}

- (void)testSetWhiteListBundleIdentifier_WithSequence {
    OGAThumbnailAdInternalAPI *internal = OCMPartialMock(self.internalAPI);
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OGAAdSequence *sequence = [[OGAAdSequence alloc] initWithAdConfiguration:configuration];
    internal.sequence = sequence;
    internal.configuration = configuration;
    NSArray *bundleIdentifiers = OCMClassMock([NSArray class]);
    [internal setWhitelistBundleIdentifiers:bundleIdentifiers];
    OCMVerify([configuration setWhitelistBundleIdentifiers:bundleIdentifiers]);
}

- (void)testLoadWithCampaignIdCreativeId {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    self.internalAPI.sequence = previousSequence;
    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    OCMStub([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:[OCMArg any]]).andReturn(sequence);
    [self.internalAPI loadWithCampaignId:@"campaignId" creativeId:@"creativeId"];
    XCTAssertEqualObjects(self.internalAPI.configuration.campaignId, @"campaignId");
    XCTAssertEqualObjects(self.internalAPI.configuration.creativeId, @"creativeId");
    XCTAssertEqual(self.internalAPI.sequence, sequence);
}

- (void)testLoadWithCampaignIdCreativeIdThumbnailSize {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    self.internalAPI.sequence = previousSequence;
    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    OCMStub([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:[OCMArg any]]).andReturn(sequence);
    [self.internalAPI loadWithCampaignId:@"campaignId" creativeId:@"creativeId" thumbnailSize:CGSizeMake(100, 180)];
    XCTAssertEqualObjects(self.internalAPI.configuration.campaignId, @"campaignId");
    XCTAssertEqual(self.internalAPI.configuration.size.width, 100);
    XCTAssertEqual(self.internalAPI.configuration.size.height, 180);
    XCTAssertEqual(self.internalAPI.sequence, sequence);
}

- (void)testLoadWithCampaignIdCreativeIdDspCreativeIdDspRegionThumbnailSize {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    self.internalAPI.sequence = previousSequence;
    OCMStub([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:[OCMArg any]]).andReturn(sequence);
    [self.internalAPI loadWithCampaignId:@"campaignId" creativeId:@"creativeId" dspCreativeId:@"dspCreativeId" dspRegion:@"dspRegion" thumbnailSize:CGSizeMake(100, 180)];
    XCTAssertEqualObjects(self.internalAPI.configuration.campaignId, @"campaignId");
    XCTAssertEqualObjects(self.internalAPI.configuration.creativeId, @"creativeId");
    XCTAssertEqualObjects(self.internalAPI.configuration.adDsp.region, @"dspRegion");
    XCTAssertEqualObjects(self.internalAPI.configuration.adDsp.creativeId, @"dspCreativeId");
    XCTAssertEqual(self.internalAPI.configuration.size.width, 100);
    XCTAssertEqual(self.internalAPI.configuration.size.height, 180);
    XCTAssertEqual(self.internalAPI.sequence, sequence);
}

- (void)testLoadWithCampaignIdCreativeIdDspCreativeIdDspRegion {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    self.internalAPI.sequence = previousSequence;
    OCMStub([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:[OCMArg any]]).andReturn(sequence);
    [self.internalAPI loadWithCampaignId:@"campaignId" creativeId:@"creativeId" dspCreativeId:@"dspCreativeId" dspRegion:@"dspRegion"];
    XCTAssertEqualObjects(self.internalAPI.configuration.campaignId, @"campaignId");
    XCTAssertEqualObjects(self.internalAPI.configuration.creativeId, @"creativeId");
    XCTAssertEqualObjects(self.internalAPI.configuration.adDsp.region, @"dspRegion");
    XCTAssertEqualObjects(self.internalAPI.configuration.adDsp.creativeId, @"dspCreativeId");
    XCTAssertEqual(self.internalAPI.sequence, sequence);
}

- (void)testWhenForceValesChangesThenSequenceIsNil {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    // first call
    [self.internalAPI loadWithCampaignId:@"campaignId"
                              creativeId:@"creativeId"
                           dspCreativeId:@"dspCreativeId"
                               dspRegion:@"dspRegion"];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    self.internalAPI.sequence = previousSequence;
    [self.internalAPI loadWithCampaignId:@"campaignId"
                              creativeId:@"creativeId"
                           dspCreativeId:@"dspCreativeId"
                               dspRegion:@"dspRegion"];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:previousSequence]);
    // update values
    [self.internalAPI loadWithCampaignId:@"newCampaign"
                              creativeId:@"creativeId"
                           dspCreativeId:@"dspCreativeId"
                               dspRegion:@"dspRegion"];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    [self.internalAPI loadWithCampaignId:@"campaignId"
                              creativeId:@"DefaultCreativeId"
                           dspCreativeId:@"dspCreativeId"
                               dspRegion:@"dspRegion"];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    [self.internalAPI loadWithCampaignId:@"campaignId"
                              creativeId:@"creativeId"
                           dspCreativeId:@"DefaultDspCreativeId"
                               dspRegion:@"dspRegion"];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    [self.internalAPI loadWithCampaignId:@"campaignId"
                              creativeId:@"creativeId"
                           dspCreativeId:@"dspCreativeId"
                               dspRegion:@"DefaultDspRegion"];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);
}

@end
