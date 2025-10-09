//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OguryInterstitialAd.h"
#import "OGAInterstitialAdInternalAPI.h"
#import "OguryInterstitialAdDelegateDispatcher.h"
#import "OGAAdConfiguration.h"
#import <OCMock/OCMock.h>

@interface OguryInterstitialAd ()

@property(nonatomic, strong) OguryInterstitialAdDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAInterstitialAdInternalAPI *internalAPI;

- (instancetype)initWithInternalAPI:(OGAInterstitialAdInternalAPI *_Nonnull)internalAPI;

- (void)loadWithCampaignId:(NSString *)campaignId;

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId;

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId dspCreativeId:(NSString *)dspCreativeId dspRegion:(NSString *)dspRegion;

@end

@interface OGAInterstitialAdInternalAPI (Test)

@property(nonatomic, strong) OGAAdConfiguration *configuration;

@end

@interface OguryInterstitialAdTests : XCTestCase

@property(nonatomic, strong) OguryInterstitialAdDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAInterstitialAdInternalAPI *internalAPI;
@property(nonatomic, strong) OguryInterstitialAd *interstitial;

@end

@implementation OguryInterstitialAdTests

static NSString *const TestAdUnitId = @"AD-UNIT-ID";
static NSString *const TestCampaignId = @"CAMPAIGN-ID";
static NSString *const TestCreativeId = @"CREATIVE-ID";
static NSString *const TestDspCreativeId = @"DSP-CREATIVE-ID";
static NSString *const TestDspRegion = @"REGION";
static NSString *const TestDelegate = @"DELEGATE";

- (void)setUp {
    self.delegateDispatcher = OCMClassMock([OguryInterstitialAdDelegateDispatcher class]);
    self.internalAPI = OCMClassMock([OGAInterstitialAdInternalAPI class]);
    OCMStub([self.internalAPI delegateDispatcher]).andReturn(self.delegateDispatcher);
    self.interstitial = [[OguryInterstitialAd alloc] initWithInternalAPI:self.internalAPI];
}

- (void)testLoad {
    [self.interstitial load];
    OCMVerify([self.internalAPI load]);
}

- (void)testLoadWithAdMarkUp {
    [self.interstitial loadWithAdMarkup:@""];
    OCMVerify([self.internalAPI loadWithAdMarkup:@""]);
}

- (void)testIsLoaded {
    OCMStub([self.internalAPI isLoaded]).andReturn(YES);
    XCTAssertTrue([self.interstitial isLoaded]);
    OCMVerify([self.internalAPI isLoaded]);
}

- (void)testShowAdInViewController {
    UIViewController *viewController = OCMClassMock([UIViewController class]);
    [self.interstitial showAdInViewController:viewController];
    OCMVerify([self.internalAPI showAdInViewController:viewController]);
}

- (void)testLoadWithCampaignId {
    [self.interstitial loadWithCampaignId:TestCampaignId];
    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId]);
}

- (void)testLoadWithCampaignIdAndCreativeId {
    [self.interstitial loadWithCampaignId:TestCampaignId creativeId:TestCreativeId];
    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId creativeId:TestCreativeId]);
}

- (void)testLoadWithCampaignIdAndCreativeIdDspCreativeIdDspRegion {
    [self.interstitial loadWithCampaignId:TestCampaignId creativeId:TestCreativeId dspCreativeId:TestDspCreativeId dspRegion:TestDspRegion];
    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId creativeId:TestCreativeId dspCreativeId:TestDspCreativeId dspRegion:TestDspRegion]);
}

- (void)testAdUnitId {
    NSString *expectedAdUnit = TestAdUnitId;
    OCMStub([self.internalAPI adUnitId]).andReturn(expectedAdUnit);
    NSString *adUnit = [self.interstitial adUnitId];
    OCMVerify([self.internalAPI adUnitId]);
    XCTAssertEqualObjects(expectedAdUnit, adUnit);
}

- (void)testDelegate {
    NSString *expectedDelegate = TestDelegate;
    OCMStub([self.delegateDispatcher delegate]).andReturn(expectedDelegate);
    id delegate = [self.interstitial delegate];
    OCMVerify([self.delegateDispatcher delegate]);
    XCTAssertEqualObjects(expectedDelegate, delegate);
}

- (void)testSetDelegate {
    id delegate = OCMStrictProtocolMock(@protocol(OguryInterstitialAdDelegate));
    [self.interstitial setDelegate:delegate];
    OCMVerify([self.delegateDispatcher setDelegate:delegate]);
}

- (void)testWhenCreatingAnAdWithMediationThenMediationIsSavedInInternalApi {
    OguryMediation *mediation = [[OguryMediation alloc] initWithName:@"name" version:@"version"];
    OguryInterstitialAd *ad = [[OguryInterstitialAd alloc] initWithAdUnitId:@"adUnit" mediation:mediation];
    XCTAssertEqualObjects(ad.internalAPI.configuration.mediation, mediation);
}

@end
