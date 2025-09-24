//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OGAInterstitialAdInternalAPI+Testing.h"
#import <OCMock/OCMock.h>
#import "OGALog.h"
#import "OguryError+utility.h"
#import "OGAMonitoringDispatcher.h"

static NSString *DefaultAdUnitId = @"AD-UNIT-ID";
static NSString *DefaultCampaignId = @"CAMPAIGN-ID";
static NSString *DefaultCreativeId = @"creativeId";
static NSString *DefaultDspCreativeId = @"DspCreativeId";
static NSString *DefaultDspRegion = @"DspRegion";

@interface OGAInterstitialAdInternalAPITests : XCTestCase

@property(nonatomic, strong) OGADelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) OGAInternetConnectionChecker *internetConnectionChecker;
@property(nonatomic, strong) OGAAnotherAdInFullScreenOverlayStateChecker *anotherAdInOverlayStateChecker;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAInterstitialAdInternalAPI *internalAPI;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAInternal *internal;
@property(nonatomic, strong) NSString *adMarkup;

@end

@implementation OGAInterstitialAdInternalAPITests

#pragma mark - Methods

- (void)setUp {
    self.log = OCMClassMock([OGALog class]);
    self.delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    self.adManager = OCMClassMock([OGAAdManager class]);
    self.internal = OCMClassMock([OGAInternal class]);
    self.internetConnectionChecker = OCMClassMock([OGAInternetConnectionChecker class]);
    self.anotherAdInOverlayStateChecker = OCMClassMock([OGAAnotherAdInFullScreenOverlayStateChecker class]);
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    self.adMarkup = @"eyJhZCI6W3siZm9ybWF0Ijp7InBhcmFtcyI6W3sibmFtZSI6InpvbmVzIiwidmFsdWUiOlt7Im5hbWUiOiJjb250cm9sbGVyIiwidXJsIjoiaHR0cHM6XC9cL3N0YWdpbmcubGl0ZWNkbi5jb21cLzIwMjEtMTAtMTMtYTgyZWIwYThcL2Zvcm1hdHNcL21yYWlkLXdyYXBwZXJcL2luZGV4Lmh0bWwiLCJzaXplIjp7IndpZHRoIjotMSwiaGVpZ2h0IjotMX19XX1dLCJ3ZWJ2aWV3X2Jhc2VfdXJsIjoiaHR0cDpcL1wvd3d3Lm9neWZtdHMuY29tXC8iLCJtcmFpZF9kb3dubG9hZF91cmwiOiJodHRwczpcL1wvbXJhaWQucHJlc2FnZS5pb1wvYmY2YWJiNlwvbXJhaWQuanMifSwiY2FtcGFpZ25faWQiOjM0NzE3LCJwYXJhbXMiOltdLCJhZF9jb250ZW50IjoiPGh0bWw+ICA8aGVhZD4gIDxtZXRhIGNoYXJzZXQ9XCJVVEYtOFwiPiAgPG1ldGEgbmFtZT1cInZpZXdwb3J0XCIgY29udGVudD1cIndpZHRoPWRldmljZS13aWR0aCwgaW5pdGlhbC1zY2FsZT0xLjAsIHVzZXItc2NhbGFibGU9bm9cIj4gIDxsaW5rIHJlbD1cImljb25cIiB0eXBlPVwiaW1hZ2VcL3BuZ1wiIGhyZWY9XCJkYXRhOmltYWdlXC9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvPVwiPiAgPFwvaGVhZD4gIDxib2R5PiAgPGRpdiBpZD1cInJvb3RcIj4gIDxcL2Rpdj4gIDxzY3JpcHQgc3JjPVwibXJhaWQuanNcIj48XC9zY3JpcHQ+ICA8c2NyaXB0IHNyYz1cImh0dHBzOlwvXC9tcy1hZHMuc3RhZ2luZy5wcmVzYWdlLmlvXC9tcmFpZD9kc3A9b2d1cnkmdD1mMDZkOTQyMS04MGJkLTQwZjEtYTBjYi1mMTEwZGQxZGYzMTImaW1wPWYzMzgxNGJlLWM2YzQtNGI0Yi1hM2ZlLTkzMDViNmUzNTQxMSZvY191dWlkPWJhNGU4NGQ1LTUwZGItNDIxNi04OWZiLTg0NTRiZTU2MTljYSZhaz0yNzI1MDYmdV9kbz1mYWxzZSZ1X2lkPTAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMCZhX3Nkaz0zLjAuMC1iZXRhLTEuMi4wJmF1aWQ9MjcyNTA2X2RlZmF1bHQmY29ubj1BTEwmdV9vcz1pb3MmYV9iPWNvLm9ndXJ5LmFkcy5Td2lmdFByZXNhZ2VUZXN0JmFfbj1pT1MlMjBOZXclMjBUZXN0JTIwQXBwJmF1dHlwZT1pbnRlcnN0aXRpYWwmYV9leD1vZ3VyeSZ0X2E9dHJ1ZSZiaWRfaGFzaD0mZG1uPSZwZz0mZF9tPXg4Nl82NCZkX3R5PW1vYmlsZSZ1X3RrPTVmYmIzNTNmLTBiNGUtNGZiMi04YTUyLTgzMmRhZGIxZDFiZCZhdWQ9dHJ1ZSZkdWFsYWQ9Jmc9JmNfcz1cIj48XC9zY3JpcHQ+ICA8XC9ib2R5PiAgPFwvaHRtbD4iLCJpZCI6ImYzMzgxNGJlLWM2YzQtNGI0Yi1hM2ZlLTkzMDViNmUzNTQxMSIsImlzX2ltcHJlc3Npb24iOnRydWUsImFkdmVydGlzZXIiOnsiaWQiOjEzNywibmFtZSI6IlBoaWxpcHMifSwiYWRfa2VlcF9hbGl2ZSI6dHJ1ZSwiYWRfdW5pdCI6eyJpZCI6IjI3MjUwNl9kZWZhdWx0IiwidHlwZSI6ImludGVyc3RpdGlhbCJ9LCJzZGtfY2xvc2VfYnV0dG9uX3VybCI6Imh0dHBzOlwvXC9tcy1hZHMtZXZlbnRzLnN0YWdpbmcucHJlc2FnZS5pb1wvY3JlYXRpdmU/ZT1zZGtfY2xvc2VfYnV0dG9uJmltcD1mMzM4MTRiZS1jNmM0LTRiNGItYTNmZS05MzA1YjZlMzU0MTEmb2NfaWQ9MzQ3MTcmYWs9MjcyNTA2JnVfaWQ9MDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwJmFfc2RrPTMuMC4wLWJldGEtMS4yLjAmdV9vcz1pb3MmYV9iPWNvLm9ndXJ5LmFkcy5Td2lmdFByZXNhZ2VUZXN0JmFfbj1pT1MlMjBOZXclMjBUZXN0JTIwQXBwIiwic2RrX2JhY2tncm91bmRfY29sb3IiOiIjMDAwMDAwIn1dfQ==";

    self.internalAPI = [[OGAInterstitialAdInternalAPI alloc] initWithAdUnitId:DefaultAdUnitId
                                                           delegateDispatcher:self.delegateDispatcher
                                                                    adManager:self.adManager
                                                    internetConnectionChecker:self.internetConnectionChecker
                                     anotherAdInFullScreenOverlayStateChecker:self.anotherAdInOverlayStateChecker
                                                         monitoringDispatcher:self.monitoringDispatcher
                                                                     internal:self.internal
                                                                    mediation:nil
                                                                          log:self.log];
}

- (void)testLoad {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    self.internalAPI.sequence = previousSequence;
    OCMStub([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:[OCMArg any]]).andReturn(sequence);
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.internalAPI.configuration);

    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    [self.internalAPI load];

    XCTAssertEqual(self.internalAPI.sequence, sequence);
    XCTAssertNil(self.internalAPI.configuration.campaignId);
    OCMVerify([self.adManager loadAdConfiguration:self.internalAPI.configuration previousSequence:previousSequence]);
}

- (void)testloadWithAdMarkUpPassed {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    self.internalAPI.sequence = previousSequence;
    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.internalAPI.configuration);
    [self.internalAPI loadWithAdMarkup:self.adMarkup];
    XCTAssertTrue(self.internalAPI.configuration.isHeaderBidding);
    XCTAssertNil(self.internalAPI.configuration.campaignId);
    OCMVerify([self.adManager loadAdConfiguration:self.internalAPI.configuration previousSequence:previousSequence]);
    XCTAssertEqualObjects(self.internalAPI.configuration.encodedAdMarkup, self.adMarkup);
}

- (void)testLoadWithCampaign {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    self.internalAPI.sequence = previousSequence;
    OCMStub([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:[OCMArg any]]).andReturn(sequence);
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.internalAPI.configuration);

    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    [self.internalAPI loadWithCampaignId:DefaultCampaignId];

    XCTAssertEqual(self.internalAPI.sequence, sequence);
    XCTAssertEqualObjects(self.internalAPI.configuration.campaignId, DefaultCampaignId);
    OCMVerify([self.adManager loadAdConfiguration:self.internalAPI.configuration previousSequence:previousSequence]);
}

- (void)testIsLoaded {
    self.internalAPI.sequence = OCMClassMock([OGAAdSequence class]);
    OCMStub([self.adManager isLoaded:self.internalAPI.sequence]).andReturn(YES);

    XCTAssertTrue([self.internalAPI isLoaded]);
    OCMVerify([self.adManager isLoaded:self.internalAPI.sequence]);
}

- (void)testShowAdInViewController {
    self.internalAPI.sequence = OCMClassMock([OGAAdSequence class]);

    [self.internalAPI showAdInViewController:OCMClassMock([UIViewController class])];

    __block NSArray<id<OGAConditionChecker>> *additionalConditions;
    OCMVerify([self.adManager show:self.internalAPI.sequence
              additionalConditions:[OCMArg checkWithBlock:^BOOL(id obj) {
                  additionalConditions = obj;
                  return YES;
              }]]);
    XCTAssertEqual(additionalConditions.count, 1);
    XCTAssertEqual(additionalConditions[0], self.anotherAdInOverlayStateChecker);
}

#pragma mark - Properties

- (void)testAdUnitId {
    XCTAssertEqualObjects(self.internalAPI.adUnitId, DefaultAdUnitId);
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

- (void)testLoadWithCampaignIdCreativeIdDspCreativeIdDspRegion {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    self.internalAPI.sequence = previousSequence;
    OCMStub([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:[OCMArg any]]).andReturn(sequence);
    [self.internalAPI loadWithCampaignId:DefaultCampaignId creativeId:DefaultCreativeId dspCreativeId:DefaultDspCreativeId dspRegion:DefaultDspRegion];
    XCTAssertEqualObjects(self.internalAPI.configuration.campaignId, DefaultCampaignId);
    XCTAssertEqualObjects(self.internalAPI.configuration.creativeId, DefaultCreativeId);
    XCTAssertEqualObjects(self.internalAPI.configuration.adDsp.creativeId, DefaultDspCreativeId);
    XCTAssertEqualObjects(self.internalAPI.configuration.adDsp.region, DefaultDspRegion);
    XCTAssertEqual(self.internalAPI.sequence, sequence);
}

- (void)testWhenForceValesChangesThenSequenceIsNil {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    // first call
    [self.internalAPI loadWithCampaignId:DefaultCampaignId
                              creativeId:DefaultCreativeId
                           dspCreativeId:DefaultDspCreativeId
                               dspRegion:DefaultDspRegion];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    self.internalAPI.sequence = previousSequence;
    [self.internalAPI loadWithCampaignId:DefaultCampaignId
                              creativeId:DefaultCreativeId
                           dspCreativeId:DefaultDspCreativeId
                               dspRegion:DefaultDspRegion];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:previousSequence]);
    // update values
    [self.internalAPI loadWithCampaignId:@"newCampaign"
                              creativeId:DefaultCreativeId
                           dspCreativeId:DefaultDspCreativeId
                               dspRegion:DefaultDspRegion];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    [self.internalAPI loadWithCampaignId:DefaultCampaignId
                              creativeId:@"DefaultCreativeId"
                           dspCreativeId:DefaultDspCreativeId
                               dspRegion:DefaultDspRegion];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    [self.internalAPI loadWithCampaignId:DefaultCampaignId
                              creativeId:DefaultCreativeId
                           dspCreativeId:@"DefaultDspCreativeId"
                               dspRegion:DefaultDspRegion];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    [self.internalAPI loadWithCampaignId:DefaultCampaignId
                              creativeId:DefaultCreativeId
                           dspCreativeId:DefaultDspCreativeId
                               dspRegion:@"DefaultDspRegion"];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);
}

@end
