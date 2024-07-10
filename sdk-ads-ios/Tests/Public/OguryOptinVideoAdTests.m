//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OguryOptinVideoAd.h"
#import "OGAOptinVideoAdInternalAPI.h"
#import "OguryOptinVideoAdDelegateDispatcher.h"
#import <OCMock/OCMock.h>

@interface OguryOptinVideoAd ()

- (instancetype)initWithInternalAPI:(OGAOptinVideoAdInternalAPI *_Nonnull)internalAPI;

- (void)loadWithCampaignId:(NSString *)campaignId;

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId;

- (void)loadWithCampaignId:(NSString *)campaignId creativeId:(NSString *)creativeId dspCreativeId:(NSString *)dspCreativeId dspRegion:(NSString *)dspRegion;
@property(nonatomic, strong) OGAOptinVideoAdInternalAPI *internalAPI;

@end

@interface OGAOptinVideoAdInternalAPI (Test)

@property(nonatomic, strong) OGAAdConfiguration *configuration;

@end

@interface OguryOptinVideoAdTests : XCTestCase

@property(nonatomic, strong) OguryOptinVideoAdDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAOptinVideoAdInternalAPI *internalAPI;
@property(nonatomic, strong) OguryOptinVideoAd *optinVideo;

@end

@implementation OguryOptinVideoAdTests

static NSString *const TestAdUnitId = @"AD-UNIT-ID";
static NSString *const TestCampaignId = @"CAMPAIGN-ID";
static NSString *const TestCreativeId = @"CREATIVE-ID";
static NSString *const TestDspCreativeId = @"DSP-CREATIVE-ID";
static NSString *const TestDspRegion = @"REGION";
static NSString *const TestDelegate = @"DELEGATE";

- (void)setUp {
    self.delegateDispatcher = OCMClassMock([OguryOptinVideoAdDelegateDispatcher class]);
    self.internalAPI = OCMClassMock([OGAOptinVideoAdInternalAPI class]);
    OCMStub([self.internalAPI delegateDispatcher]).andReturn(self.delegateDispatcher);
    self.optinVideo = [[OguryOptinVideoAd alloc] initWithInternalAPI:self.internalAPI];
}

- (void)testLoad {
    [self.optinVideo load];
    OCMVerify([self.internalAPI load]);
}

- (void)testLoadWithAdMarkUp {
    [self.optinVideo loadWithAdMarkup:@"AdMarkup"];
    OCMVerify([self.internalAPI loadWithAdMarkup:@"AdMarkup"]);
}

- (void)testIsLoaded {
    OCMStub([self.internalAPI isLoaded]).andReturn(YES);
    XCTAssertTrue([self.optinVideo isLoaded]);
    OCMVerify([self.internalAPI isLoaded]);
}

- (void)testShowAdInViewController {
    UIViewController *viewController = OCMClassMock([UIViewController class]);
    [self.optinVideo showAdInViewController:viewController];
    OCMVerify([self.internalAPI showAdInViewController:viewController]);
}

- (void)testLoadWithCampaignId {
    [self.optinVideo loadWithCampaignId:TestCampaignId];
    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId]);
}

- (void)testLoadWithCampaignIdAndCreativeId {
    [self.optinVideo loadWithCampaignId:TestCampaignId creativeId:TestCreativeId];
    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId creativeId:TestCreativeId]);
}

- (void)testLoadWithCampaignIdAndCreativeIdDspCreativeIdDspRegion {
    [self.optinVideo loadWithCampaignId:TestCampaignId creativeId:TestCreativeId dspCreativeId:TestDspCreativeId dspRegion:TestDspRegion];
    OCMVerify([self.internalAPI loadWithCampaignId:TestCampaignId creativeId:TestCreativeId dspCreativeId:TestDspCreativeId dspRegion:TestDspRegion]);
}

- (void)testAdUnitId {
    NSString *expectedAdUnit = TestAdUnitId;
    OCMStub([self.internalAPI adUnitId]).andReturn(expectedAdUnit);
    NSString *adUnit = [self.optinVideo adUnitId];
    OCMVerify([self.internalAPI adUnitId]);
    XCTAssertEqualObjects(expectedAdUnit, adUnit);
}

- (void)testDelegate {
    NSString *expectedDelegate = TestDelegate;
    OCMStub([self.delegateDispatcher delegate]).andReturn(expectedDelegate);
    id delegate = [self.optinVideo delegate];
    OCMVerify([self.delegateDispatcher delegate]);
    XCTAssertEqualObjects(expectedDelegate, delegate);
}

- (void)testSetDelegate {
    id delegate = OCMStrictProtocolMock(@protocol(OguryOptinVideoAdDelegate));
    [self.optinVideo setDelegate:delegate];
    OCMVerify([self.delegateDispatcher setDelegate:delegate]);
}

- (void)testWhenCreatingAnAdWithMediationThenMediationIsSavedInInternalApi {
    OguryMediation *mediation = [[OguryMediation alloc] initWithName:@"name" version:@"version"];
    OguryOptinVideoAd *ad = [[OguryOptinVideoAd alloc] initWithAdUnitId:@"adUnit" mediation:mediation];
    XCTAssertEqualObjects(ad.internalAPI.configuration.mediation, mediation);
}

@end
