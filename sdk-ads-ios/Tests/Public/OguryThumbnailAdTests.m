//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OguryThumbnailAd.h"
#import "OGAThumbnailAdInternalAPI.h"
#import "OguryThumbnailAdDelegateDispatcher.h"
#import <OCMock/OCMock.h>
#import "OGAThumbnailAdConstants.h"
#import "OGAAdConfiguration.h"

@interface OguryThumbnailAd ()

- (instancetype)initWithInternalAPI:(OGAThumbnailAdInternalAPI *_Nonnull)internalAPI;

- (void)loadWithCampaignId:(NSString *)campaignId;

- (void)loadWithCampaignId:(NSString *)campaignId thumbnailSize:(CGSize)thumbnailSize;

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId;

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId thumbnailSize:(CGSize)thumbnailSize;

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId dspCreativeId:(NSString *)dspCreativeId dspRegion:(NSString *)dspRegion thumbnailSize:(CGSize)thumbnailSize;

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId dspCreativeId:(NSString *)dspCreativeId dspRegion:(NSString *)dspRegion;
@property(nonatomic, strong) OGAThumbnailAdInternalAPI *internalAPI;

@end

@interface OGAThumbnailAdInternalAPI (Test)

@property(nonatomic, strong) OGAAdConfiguration *configuration;

@end

@interface OguryThumbnailAdTests : XCTestCase

@property(nonatomic, strong) OguryThumbnailAdDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAThumbnailAdInternalAPI *internalAPI;
@property(nonatomic, strong) OguryThumbnailAd *thumbnail;

@end

@implementation OguryThumbnailAdTests

static NSString *const TestAdUnitId = @"AD-UNIT-ID";
static NSString *const TestCampaignId = @"CAMPAIGN-ID";
static NSString *const TestCreativeId = @"CREATIVE-ID";
static NSString *const TestDspCreativeId = @"DSP-CREATIVE-ID";
static NSString *const TestDspRegion = @"REGION";
static NSString *const TestDelegate = @"DELEGATE";

- (void)setUp {
    self.delegateDispatcher = OCMClassMock([OguryThumbnailAdDelegateDispatcher class]);
    self.internalAPI = OCMClassMock([OGAThumbnailAdInternalAPI class]);
    OCMStub([self.internalAPI delegateDispatcher]).andReturn(self.delegateDispatcher);
    self.thumbnail = [[OguryThumbnailAd alloc] initWithInternalAPI:self.internalAPI];
}

- (void)testAdUnitId {
    NSString *expectedAdUnit = TestAdUnitId;
    OCMStub([self.internalAPI adUnitId]).andReturn(expectedAdUnit);
    NSString *adUnit = [self.thumbnail adUnitId];
    OCMVerify([self.internalAPI adUnitId]);
    XCTAssertEqualObjects(expectedAdUnit, adUnit);
}

- (void)testDelegate {
    NSString *expectedDelegate = TestDelegate;
    OCMStub([self.delegateDispatcher delegate]).andReturn(expectedDelegate);
    id delegate = [self.thumbnail delegate];
    OCMVerify([self.delegateDispatcher delegate]);
    XCTAssertEqualObjects(expectedDelegate, delegate);
}

- (void)testSetDelegate {
    id delegate = OCMStrictProtocolMock(@protocol(OguryThumbnailAdDelegate));
    [self.thumbnail setDelegate:delegate];
    OCMVerify([self.delegateDispatcher setDelegate:delegate]);
}

- (void)testLoad {
    [self.thumbnail load];
    OCMVerify([self.internalAPI load]);
}

- (void)testIsLoaded {
    OCMStub([self.internalAPI isLoaded]).andReturn(YES);
    XCTAssertTrue([self.thumbnail isLoaded]);
    OCMVerify([self.internalAPI isLoaded]);
}

- (void)test_ShouldReturnIsExpanded {
    OCMStub([self.internalAPI isExpanded]).andReturn(YES);

    XCTAssertTrue(self.thumbnail.isExpanded);

    OCMVerify([self.internalAPI isExpanded]);
}

- (void)testLoadWiththumbnailSize {
    [self.thumbnail load:CGSizeMake(180, 180)];
    OCMVerify([self.internalAPI load:CGSizeMake(180, 180)]);
}

- (void)testLoadWithCampaignId {
    [self.thumbnail loadWithCampaignId:TestCampaignId];
    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId]);
}

- (void)testLoadWithCampaignIdAndThumbnailSize {
    [self.thumbnail loadWithCampaignId:TestCampaignId thumbnailSize:CGSizeMake(OGAThumbnailDefaultWidth, OGAThumbnailDefaultHeight)];
    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId thumbnailSize:CGSizeMake(OGAThumbnailDefaultWidth, OGAThumbnailDefaultHeight)]);
}

- (void)testLoadWithCampaignIdAndCreativeId {
    [self.thumbnail loadWithCampaignId:TestCampaignId creativeId:TestCreativeId];
    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId creativeId:TestCreativeId]);
}

- (void)testLoadWithCampaignIdAndCreativeIdAndThumbnailSize {
    [self.thumbnail loadWithCampaignId:TestCampaignId creativeId:TestCreativeId thumbnailSize:CGSizeMake(OGAThumbnailDefaultWidth, OGAThumbnailDefaultHeight)];
    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId creativeId:TestCreativeId thumbnailSize:CGSizeMake(OGAThumbnailDefaultWidth, OGAThumbnailDefaultHeight)]);
}

- (void)testLoadWithCampaignIdCreativeIdDspCreativeId {
    [self.thumbnail loadWithCampaignId:TestCampaignId creativeId:TestCreativeId dspCreativeId:TestDspCreativeId dspRegion:TestDspRegion];
    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId creativeId:TestCreativeId dspCreativeId:TestDspCreativeId dspRegion:TestDspRegion]);
}

- (void)testLoadWithCampaignIdCreativeIdDspCreativeIdThumbnailSize {
    [self.thumbnail loadWithCampaignId:TestCampaignId creativeId:TestCreativeId dspCreativeId:TestDspCreativeId dspRegion:TestDspRegion thumbnailSize:CGSizeMake(OGAThumbnailDefaultWidth, OGAThumbnailDefaultHeight)];
    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId creativeId:TestCreativeId dspCreativeId:TestDspCreativeId dspRegion:TestDspRegion thumbnailSize:CGSizeMake(OGAThumbnailDefaultWidth, OGAThumbnailDefaultHeight)]);
}

- (void)testShow {
    [self.thumbnail show];
    OCMVerify([self.internalAPI show]);
}

- (void)testShowWithPosition {
    [self.thumbnail show:CGPointMake(10, 10)];
    OCMVerify([self.internalAPI show:CGPointMake(10, 10)]);
}

- (void)testShowWithOguryRectCornerAndMargin {
    [self.thumbnail showWithOguryRectCorner:OguryTopLeft margin:OguryOffsetMake(10, 10)];
    OCMVerify([self.internalAPI showWithOguryRectCorner:OguryTopLeft margin:OguryOffsetMake(10, 10)]);
}

- (void)testShowInScene API_AVAILABLE(ios(13.0)) {
    UIWindowScene *scene = OCMClassMock([UIWindowScene class]);
    [self.thumbnail showInScene:scene];
    OCMVerify([self.internalAPI showInScene:scene]);
}

- (void)testShowInSceneAtPosition API_AVAILABLE(ios(13.0)) {
    UIWindowScene *scene = OCMClassMock([UIWindowScene class]);
    [self.thumbnail showInScene:scene atPosition:CGPointMake(10, 10)];
    OCMVerify([self.internalAPI showInScene:scene atPosition:CGPointMake(10, 10)]);
}

- (void)testShowInSceneWithOguryRectCornerMargin API_AVAILABLE(ios(13.0)) {
    UIWindowScene *scene = OCMClassMock([UIWindowScene class]);
    [self.thumbnail showInScene:scene withOguryRectCorner:OguryTopLeft margin:OguryOffsetMake(10, 10)];
    OCMVerify([self.internalAPI showInScene:scene withOguryRectCorner:OguryTopLeft margin:OguryOffsetMake(10, 10)]);
}

- (void)testSetBlacklistViewControllers API_AVAILABLE(ios(13.0)) {
    NSArray *viewControllers = OCMClassMock([NSArray class]);
    [self.thumbnail setBlacklistViewControllers:viewControllers];
    OCMVerify([self.internalAPI setBlacklistViewControllers:viewControllers]);
}

- (void)testSetWhitelistBundleIdentifiers API_AVAILABLE(ios(13.0)) {
    NSArray *bundleIdentifiers = OCMClassMock([NSArray class]);
    [self.thumbnail setWhitelistBundleIdentifiers:bundleIdentifiers];
    OCMVerify([self.internalAPI setWhitelistBundleIdentifiers:bundleIdentifiers]);
}

- (void)testWhenCreatingAnAdWithMediationThenMediationIsSavedInInternalApi {
    OguryMediation *mediation = [[OguryMediation alloc] initWithName:@"name" version:@"version"];
    OguryThumbnailAd *ad = [[OguryThumbnailAd alloc] initWithAdUnitId:@"adUnit" mediation:mediation];
    XCTAssertEqualObjects(ad.internalAPI.configuration.mediation, mediation);
}

@end
