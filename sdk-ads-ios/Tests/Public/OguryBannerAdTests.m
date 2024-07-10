//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OguryBannerAdDelegateDispatcher.h"
#import "OGABannerAdInternalAPI.h"
#import "OguryBannerAd.h"
#import "OguryBannerAd+Testing.h"
#import "OguryAdsBannerSize.h"

@interface OguryBannerAdTests : XCTestCase

#pragma mark - Properties

@property(nonatomic, strong) OguryBannerAdDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGABannerAdInternalAPI *internalAPI;
@property(nonatomic, strong) OguryBannerAd *banner;

@end

@implementation OguryBannerAdTests

#pragma mark - Constants

static NSString *const TestAdUnitId = @"AD-UNIT-ID";
static NSString *const TestCampaignId = @"CAMPAIGN-ID";
static NSString *const TestCreativeId = @"CREATIVE-ID";
static NSString *const TestDspCreativeId = @"DSP-CREATIVE-ID";
static NSString *const TestDspRegion = @"REGION";
static NSString *const TestDelegate = @"DELEGATE";

#pragma mark - Methods

- (void)setUp {
    self.delegateDispatcher = OCMClassMock([OguryBannerAdDelegateDispatcher class]);
    self.internalAPI = OCMClassMock([OGABannerAdInternalAPI class]);
    OCMStub([self.internalAPI delegateDispatcher]).andReturn(self.delegateDispatcher);
    self.banner = [[OguryBannerAd alloc] initWithInternalAPI:self.internalAPI];
}

- (void)testShouldInstantiateWithAdUnitId {
    OguryBannerAd *banner = [[OguryBannerAd alloc] initWithAdUnitId:TestAdUnitId];

    XCTAssertNotNil(banner.adUnitId);
    XCTAssertNotNil(banner.delegateDispatcher);
    XCTAssertNotNil(banner.internalAPI);
}

- (void)testShouldLoadWithSize {
    OguryAdsBannerSize *size = [OguryAdsBannerSize mpu_300x250];
    [self.banner loadWithSize:size];
    OCMVerify([self.internalAPI loadWithSize:size]);
}

- (void)testShouldLoadWithAdMarkupAndSize {
    OguryAdsBannerSize *size = [OguryAdsBannerSize mpu_300x250];
    [self.banner loadWithAdMarkup:@"adMarkup" size:size];
    OCMVerify([self.internalAPI loadWithAdMarkup:@"adMarkup" size:size]);
}

- (void)testShouldReturnIsLoaded {
    OCMStub([self.internalAPI isLoaded]).andReturn(YES);
    XCTAssertTrue([self.banner isLoaded]);
    OCMVerify([self.internalAPI isLoaded]);
}

- (void)testShouldReturnIsExpanded {
    OCMStub([self.internalAPI isExpanded]).andReturn(YES);
    XCTAssertTrue(self.banner.isExpanded);
    OCMVerify([self.internalAPI isExpanded]);
}

- (void)testShouldLoadWithCampaignId {
    OguryAdsBannerSize *size = [OguryAdsBannerSize mpu_300x250];
    OCMExpect([self.internalAPI loadWithCampaignId:TestCampaignId size:size]);
    [self.banner loadWithCampaignId:TestCampaignId size:size];
    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId size:size]);
}

- (void)testLoadWithCampaignIdCreativeIdDspCreativeIdDspRegionSize {
    OguryAdsBannerSize *size = [OguryAdsBannerSize mpu_300x250];

    OCMExpect([self.internalAPI loadWithCampaignId:TestCampaignId
                                        creativeId:TestCreativeId
                                     dspCreativeId:TestDspCreativeId
                                         dspRegion:TestDspRegion
                                              size:size]);

    [self.banner loadWithCampaignId:TestCampaignId
                         creativeId:TestCreativeId
                      dspCreativeId:TestDspCreativeId
                          dspRegion:TestDspRegion
                               size:size];

    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId
                                        creativeId:TestCreativeId
                                     dspCreativeId:TestDspCreativeId
                                         dspRegion:TestDspRegion
                                              size:size]);
}

- (void)testLoadWithCampaignIdCreativeId {
    OguryAdsBannerSize *size = [OguryAdsBannerSize mpu_300x250];

    OCMExpect([self.internalAPI loadWithCampaignId:TestCampaignId
                                        creativeId:TestCreativeId
                                              size:size]);

    [self.banner loadWithCampaignId:TestCampaignId
                         creativeId:TestCreativeId
                               size:size];

    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId
                                        creativeId:TestCreativeId
                                              size:size]);
}

- (void)testShouldDestroy {
    OCMExpect([self.internalAPI destroy]);
    [self.banner destroy];
    OCMVerify([self.internalAPI destroy]);
}

- (void)testShouldAdUnitId {
    NSString *expectedAdUnit = TestAdUnitId;
    OCMStub([self.internalAPI adUnitId]).andReturn(expectedAdUnit);
    NSString *adUnit = [self.banner adUnitId];
    OCMVerify([self.internalAPI adUnitId]);
    XCTAssertEqualObjects(expectedAdUnit, adUnit);
}

- (void)testSdhouldReturnDelegate {
    NSString *expectedDelegate = TestDelegate;
    OCMStub([self.delegateDispatcher delegate]).andReturn(expectedDelegate);
    id delegate = [self.banner delegate];
    OCMVerify([self.delegateDispatcher delegate]);
    XCTAssertEqualObjects(expectedDelegate, delegate);
}

- (void)testShouldSetDelegate {
    id delegate = OCMStrictProtocolMock(@protocol(OguryBannerAdDelegate));
    OCMExpect([self.delegateDispatcher setDelegate:delegate]);
    [self.banner setDelegate:delegate];
    OCMVerify([self.delegateDispatcher setDelegate:delegate]);
}

- (void)testShouldDispatchDidMoveToSuperview {
    OCMExpect([self.internalAPI didMoveToSuperview]);
    [self.banner didMoveToSuperview];
    OCMVerify([self.internalAPI didMoveToSuperview]);
}

- (void)testShouldDispatchDidMoveToWindow {
    OCMExpect([self.internalAPI didMoveToWindow]);
    [self.banner didMoveToWindow];
    OCMVerify([self.internalAPI didMoveToWindow]);
}

- (void)testWhenCreatingAnAdWithMediationThenMediationIsSavedInInternalApi {
    OguryMediation *mediation = [[OguryMediation alloc] initWithName:@"name" version:@"version"];
    OguryBannerAd *ad = [[OguryBannerAd alloc] initWithAdUnitId:@"adUnit" mediation:mediation];
    XCTAssertEqualObjects(ad.internalAPI.configuration.mediation, mediation);
}

@end
