//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OguryBannerAdView.h"
#import "OGABannerAdViewInternalAPI.h"
#import "OGABannerAdInternalAPI+Testing.h"
#import "OGAAdManager.h"
#import "OGALog.h"
#import "OguryError+utility.h"
#import "OGAMonitoringDispatcher.h"

@interface OGABannerAdInternalAPITests : XCTestCase

#pragma mark - Properties

@property(nonatomic, strong) OGADelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) OGABannerAdViewInternalAPI *smallBannerInternalAPI;
@property(nonatomic, strong) OGABannerAdViewInternalAPI *mrecInternalAPI;
@property(nonatomic, strong) NSNotificationCenter *notificationCenter;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAInternal *internal;

@end

@implementation OGABannerAdInternalAPITests

#pragma mark - Constants

static NSString *const DefaultAdUnitId = @"AD-UNIT-ID";
static NSString *const DefaultCampaignId = @"CAMPAIGN-ID";
static NSString *const DefaultCreativeId = @"CreativeId";
static NSString *const DefaultDspCreativeId = @"dspCreativeId";
static NSString *const DefaultDspRegion = @"dspRegion";

#pragma mark - Methods

- (void)setUp {
    self.log = OCMClassMock([OGALog class]);
    self.delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    self.adManager = OCMClassMock([OGAAdManager class]);
    self.internal = OCMClassMock([OGAInternal class]);
    self.notificationCenter = OCMClassMock([NSNotificationCenter class]);
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);

    self.smallBannerInternalAPI = [[OGABannerAdViewInternalAPI alloc] initWithAdUnitId:DefaultAdUnitId
                                                                            bannerView:nil
                                                                                  size:OguryBannerAdSize.small_banner_320x50
                                                                    delegateDispatcher:self.delegateDispatcher
                                                                             adManager:self.adManager
                                                                    notificationCenter:self.notificationCenter
                                                                  monitoringDispatcher:self.monitoringDispatcher
                                                                              internal:self.internal
                                                                             mediation:nil
                                                                                   log:self.log];

    self.mrecInternalAPI = [[OGABannerAdViewInternalAPI alloc] initWithAdUnitId:DefaultAdUnitId
                                                                     bannerView:nil
                                                                           size:OguryBannerAdSize.mrec_300x250
                                                             delegateDispatcher:self.delegateDispatcher
                                                                      adManager:self.adManager
                                                             notificationCenter:self.notificationCenter
                                                           monitoringDispatcher:self.monitoringDispatcher
                                                                       internal:self.internal
                                                                      mediation:nil
                                                                            log:self.log];
}

- (void)testLoadInit300x250 {
    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    [self.mrecInternalAPI load];
    XCTAssertTrue(CGSizeEqualToSize([self.mrecInternalAPI.size getSize], [[OguryBannerAdSize mrec_300x250] getSize]));
    XCTAssertTrue(CGSizeEqualToSize(self.mrecInternalAPI.configuration.size, [[OguryBannerAdSize mrec_300x250] getSize]));
}

- (void)testLoadInit320x50 {
    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    [self.smallBannerInternalAPI load];

    XCTAssertTrue(CGSizeEqualToSize([self.smallBannerInternalAPI.size getSize], [[OguryBannerAdSize small_banner_320x50] getSize]));
    XCTAssertTrue(CGSizeEqualToSize(self.smallBannerInternalAPI.configuration.size, [[OguryBannerAdSize small_banner_320x50] getSize]));
}

- (void)testShouldLoad {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);

    self.smallBannerInternalAPI.sequence = previousSequence;

    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    OCMStub([self.adManager loadAdConfiguration:OCMOCK_ANY previousSequence:OCMOCK_ANY]).andReturn(sequence);
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.smallBannerInternalAPI.configuration);
    [self.smallBannerInternalAPI load];

    XCTAssertEqual(self.smallBannerInternalAPI.sequence, sequence);
    XCTAssertTrue(CGSizeEqualToSize(self.smallBannerInternalAPI.configuration.size, [[OguryBannerAdSize small_banner_320x50] getSize]));
    XCTAssertNil(self.smallBannerInternalAPI.configuration.campaignId);
    OCMVerify([self.adManager loadAdConfiguration:self.smallBannerInternalAPI.configuration previousSequence:previousSequence]);
}

- (void)testShouldLoadWithCampaign {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);

    self.smallBannerInternalAPI.sequence = previousSequence;
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.smallBannerInternalAPI.configuration);

    OCMStub([self.adManager loadAdConfiguration:OCMOCK_ANY previousSequence:OCMOCK_ANY]).andReturn(sequence);

    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    [self.smallBannerInternalAPI loadWithCampaignId:DefaultCampaignId];

    XCTAssertEqual(self.smallBannerInternalAPI.sequence, sequence);
    XCTAssertTrue(CGSizeEqualToSize(self.smallBannerInternalAPI.configuration.size, [[OguryBannerAdSize small_banner_320x50] getSize]));
    XCTAssertEqualObjects(self.smallBannerInternalAPI.configuration.campaignId, DefaultCampaignId);
    OCMVerify([self.adManager loadAdConfiguration:self.smallBannerInternalAPI.configuration previousSequence:previousSequence]);
}

- (void)testShouldLoadWithCampaignCreativeId {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);

    self.smallBannerInternalAPI.sequence = previousSequence;

    OCMStub([self.adManager loadAdConfiguration:OCMOCK_ANY previousSequence:OCMOCK_ANY]).andReturn(sequence);
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.smallBannerInternalAPI.configuration);

    [self.smallBannerInternalAPI loadWithCampaignId:DefaultCampaignId creativeId:DefaultCreativeId];

    XCTAssertEqual(self.smallBannerInternalAPI.sequence, sequence);
    XCTAssertTrue(CGSizeEqualToSize(self.smallBannerInternalAPI.configuration.size, [[OguryBannerAdSize small_banner_320x50] getSize]));
    XCTAssertEqualObjects(self.smallBannerInternalAPI.configuration.campaignId, DefaultCampaignId);
    XCTAssertEqualObjects(self.smallBannerInternalAPI.configuration.creativeId, DefaultCreativeId);
    OCMVerify([self.adManager loadAdConfiguration:self.smallBannerInternalAPI.configuration previousSequence:previousSequence]);
}

- (void)testShouldLoadWithCampaignCreativeIdDspCreativeIdDspRegion {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);

    self.smallBannerInternalAPI.sequence = previousSequence;

    OCMStub([self.adManager loadAdConfiguration:OCMOCK_ANY previousSequence:OCMOCK_ANY]).andReturn(sequence);
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.smallBannerInternalAPI.configuration);

    [self.smallBannerInternalAPI loadWithCampaignId:DefaultCampaignId
                                         creativeId:DefaultCreativeId
                                      dspCreativeId:DefaultDspCreativeId
                                          dspRegion:DefaultDspRegion];

    XCTAssertEqual(self.smallBannerInternalAPI.sequence, sequence);
    XCTAssertTrue(CGSizeEqualToSize(self.smallBannerInternalAPI.configuration.size, [[OguryBannerAdSize small_banner_320x50] getSize]));
    XCTAssertEqualObjects(self.smallBannerInternalAPI.configuration.campaignId, DefaultCampaignId);
    XCTAssertEqualObjects(self.smallBannerInternalAPI.configuration.creativeId, DefaultCreativeId);
    XCTAssertEqualObjects(self.smallBannerInternalAPI.configuration.adDsp.region, DefaultDspRegion);
    XCTAssertEqualObjects(self.smallBannerInternalAPI.configuration.adDsp.creativeId, DefaultDspCreativeId);
    OCMVerify([self.adManager loadAdConfiguration:self.smallBannerInternalAPI.configuration previousSequence:previousSequence]);
}

- (void)testloadWithAdMarkUpPassed {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    self.smallBannerInternalAPI.sequence = previousSequence;
    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.smallBannerInternalAPI.configuration);
    [self.smallBannerInternalAPI loadWithAdMarkup:@"eyJhZCI6W3siZm9ybWF0Ijp7InBhcmFtcyI6W3sibmFtZSI6InpvbmVzIiwidmFsdWUiOlt7Im5hbWUiOiJjb250cm9sbGVyIiwidXJsIjoiaHR0cHM6XC9cL3N0YWdpbmcubGl0ZWNkbi5jb21cLzIwMjEtMTAtMTMtYTgyZWIwYThcL2Zvcm1hdHNcL21yYWlkLXdyYXBwZXJcL2luZGV4Lmh0bWwiLCJzaXplIjp7IndpZHRoIjotMSwiaGVpZ2h0IjotMX19XX1dLCJ3ZWJ2aWV3X2Jhc2VfdXJsIjoiaHR0cDpcL1wvd3d3Lm9neWZtdHMuY29tXC8iLCJtcmFpZF9kb3dubG9hZF91cmwiOiJodHRwczpcL1wvbXJhaWQucHJlc2FnZS5pb1wvYmY2YWJiNlwvbXJhaWQuanMifSwiY2FtcGFpZ25faWQiOjM0NzE3LCJwYXJhbXMiOltdLCJhZF9jb250ZW50IjoiPGh0bWw+ICA8aGVhZD4gIDxtZXRhIGNoYXJzZXQ9XCJVVEYtOFwiPiAgPG1ldGEgbmFtZT1cInZpZXdwb3J0XCIgY29udGVudD1cIndpZHRoPWRldmljZS13aWR0aCwgaW5pdGlhbC1zY2FsZT0xLjAsIHVzZXItc2NhbGFibGU9bm9cIj4gIDxsaW5rIHJlbD1cImljb25cIiB0eXBlPVwiaW1hZ2VcL3BuZ1wiIGhyZWY9XCJkYXRhOmltYWdlXC9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvPVwiPiAgPFwvaGVhZD4gIDxib2R5PiAgPGRpdiBpZD1cInJvb3RcIj4gIDxcL2Rpdj4gIDxzY3JpcHQgc3JjPVwibXJhaWQuanNcIj48XC9zY3JpcHQ+ICA8c2NyaXB0IHNyYz1cImh0dHBzOlwvXC9tcy1hZHMuc3RhZ2luZy5wcmVzYWdlLmlvXC9tcmFpZD9kc3A9b2d1cnkmdD1mMDZkOTQyMS04MGJkLTQwZjEtYTBjYi1mMTEwZGQxZGYzMTImaW1wPWYzMzgxNGJlLWM2YzQtNGI0Yi1hM2ZlLTkzMDViNmUzNTQxMSZvY191dWlkPWJhNGU4NGQ1LTUwZGItNDIxNi04OWZiLTg0NTRiZTU2MTljYSZhaz0yNzI1MDYmdV9kbz1mYWxzZSZ1X2lkPTAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMCZhX3Nkaz0zLjAuMC1iZXRhLTEuMi4wJmF1aWQ9MjcyNTA2X2RlZmF1bHQmY29ubj1BTEwmdV9vcz1pb3MmYV9iPWNvLm9ndXJ5LmFkcy5Td2lmdFByZXNhZ2VUZXN0JmFfbj1pT1MlMjBOZXclMjBUZXN0JTIwQXBwJmF1dHlwZT1pbnRlcnN0aXRpYWwmYV9leD1vZ3VyeSZ0X2E9dHJ1ZSZiaWRfaGFzaD0mZG1uPSZwZz0mZF9tPXg4Nl82NCZkX3R5PW1vYmlsZSZ1X3RrPTVmYmIzNTNmLTBiNGUtNGZiMi04YTUyLTgzMmRhZGIxZDFiZCZhdWQ9dHJ1ZSZkdWFsYWQ9Jmc9JmNfcz1cIj48XC9zY3JpcHQ+ICA8XC9ib2R5PiAgPFwvaHRtbD4iLCJpZCI6ImYzMzgxNGJlLWM2YzQtNGI0Yi1hM2ZlLTkzMDViNmUzNTQxMSIsImlzX2ltcHJlc3Npb24iOnRydWUsImFkdmVydGlzZXIiOnsiaWQiOjEzNywibmFtZSI6IlBoaWxpcHMifSwiYWRfa2VlcF9hbGl2ZSI6dHJ1ZSwiYWRfdW5pdCI6eyJpZCI6IjI3MjUwNl9kZWZhdWx0IiwidHlwZSI6ImludGVyc3RpdGlhbCJ9LCJzZGtfY2xvc2VfYnV0dG9uX3VybCI6Imh0dHBzOlwvXC9tcy1hZHMtZXZlbnRzLnN0YWdpbmcucHJlc2FnZS5pb1wvY3JlYXRpdmU/ZT1zZGtfY2xvc2VfYnV0dG9uJmltcD1mMzM4MTRiZS1jNmM0LTRiNGItYTNmZS05MzA1YjZlMzU0MTEmb2NfaWQ9MzQ3MTcmYWs9MjcyNTA2JnVfaWQ9MDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwJmFfc2RrPTMuMC4wLWJldGEtMS4yLjAmdV9vcz1pb3MmYV9iPWNvLm9ndXJ5LmFkcy5Td2lmdFByZXNhZ2VUZXN0JmFfbj1pT1MlMjBOZXclMjBUZXN0JTIwQXBwIiwic2RrX2JhY2tncm91bmRfY29sb3IiOiIjMDAwMDAwIn1dfQ=="];
    XCTAssertNotNil(self.smallBannerInternalAPI.configuration.encodedAdMarkup);
    XCTAssertTrue(CGSizeEqualToSize(self.smallBannerInternalAPI.configuration.size, [[OguryBannerAdSize small_banner_320x50] getSize]));
    XCTAssertNil(self.smallBannerInternalAPI.configuration.campaignId);
    OCMVerify([self.adManager loadAdConfiguration:self.smallBannerInternalAPI.configuration previousSequence:previousSequence]);
    XCTAssertEqualObjects(self.smallBannerInternalAPI.configuration.encodedAdMarkup, @"eyJhZCI6W3siZm9ybWF0Ijp7InBhcmFtcyI6W3sibmFtZSI6InpvbmVzIiwidmFsdWUiOlt7Im5hbWUiOiJjb250cm9sbGVyIiwidXJsIjoiaHR0cHM6XC9cL3N0YWdpbmcubGl0ZWNkbi5jb21cLzIwMjEtMTAtMTMtYTgyZWIwYThcL2Zvcm1hdHNcL21yYWlkLXdyYXBwZXJcL2luZGV4Lmh0bWwiLCJzaXplIjp7IndpZHRoIjotMSwiaGVpZ2h0IjotMX19XX1dLCJ3ZWJ2aWV3X2Jhc2VfdXJsIjoiaHR0cDpcL1wvd3d3Lm9neWZtdHMuY29tXC8iLCJtcmFpZF9kb3dubG9hZF91cmwiOiJodHRwczpcL1wvbXJhaWQucHJlc2FnZS5pb1wvYmY2YWJiNlwvbXJhaWQuanMifSwiY2FtcGFpZ25faWQiOjM0NzE3LCJwYXJhbXMiOltdLCJhZF9jb250ZW50IjoiPGh0bWw+ICA8aGVhZD4gIDxtZXRhIGNoYXJzZXQ9XCJVVEYtOFwiPiAgPG1ldGEgbmFtZT1cInZpZXdwb3J0XCIgY29udGVudD1cIndpZHRoPWRldmljZS13aWR0aCwgaW5pdGlhbC1zY2FsZT0xLjAsIHVzZXItc2NhbGFibGU9bm9cIj4gIDxsaW5rIHJlbD1cImljb25cIiB0eXBlPVwiaW1hZ2VcL3BuZ1wiIGhyZWY9XCJkYXRhOmltYWdlXC9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvPVwiPiAgPFwvaGVhZD4gIDxib2R5PiAgPGRpdiBpZD1cInJvb3RcIj4gIDxcL2Rpdj4gIDxzY3JpcHQgc3JjPVwibXJhaWQuanNcIj48XC9zY3JpcHQ+ICA8c2NyaXB0IHNyYz1cImh0dHBzOlwvXC9tcy1hZHMuc3RhZ2luZy5wcmVzYWdlLmlvXC9tcmFpZD9kc3A9b2d1cnkmdD1mMDZkOTQyMS04MGJkLTQwZjEtYTBjYi1mMTEwZGQxZGYzMTImaW1wPWYzMzgxNGJlLWM2YzQtNGI0Yi1hM2ZlLTkzMDViNmUzNTQxMSZvY191dWlkPWJhNGU4NGQ1LTUwZGItNDIxNi04OWZiLTg0NTRiZTU2MTljYSZhaz0yNzI1MDYmdV9kbz1mYWxzZSZ1X2lkPTAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMCZhX3Nkaz0zLjAuMC1iZXRhLTEuMi4wJmF1aWQ9MjcyNTA2X2RlZmF1bHQmY29ubj1BTEwmdV9vcz1pb3MmYV9iPWNvLm9ndXJ5LmFkcy5Td2lmdFByZXNhZ2VUZXN0JmFfbj1pT1MlMjBOZXclMjBUZXN0JTIwQXBwJmF1dHlwZT1pbnRlcnN0aXRpYWwmYV9leD1vZ3VyeSZ0X2E9dHJ1ZSZiaWRfaGFzaD0mZG1uPSZwZz0mZF9tPXg4Nl82NCZkX3R5PW1vYmlsZSZ1X3RrPTVmYmIzNTNmLTBiNGUtNGZiMi04YTUyLTgzMmRhZGIxZDFiZCZhdWQ9dHJ1ZSZkdWFsYWQ9Jmc9JmNfcz1cIj48XC9zY3JpcHQ+ICA8XC9ib2R5PiAgPFwvaHRtbD4iLCJpZCI6ImYzMzgxNGJlLWM2YzQtNGI0Yi1hM2ZlLTkzMDViNmUzNTQxMSIsImlzX2ltcHJlc3Npb24iOnRydWUsImFkdmVydGlzZXIiOnsiaWQiOjEzNywibmFtZSI6IlBoaWxpcHMifSwiYWRfa2VlcF9hbGl2ZSI6dHJ1ZSwiYWRfdW5pdCI6eyJpZCI6IjI3MjUwNl9kZWZhdWx0IiwidHlwZSI6ImludGVyc3RpdGlhbCJ9LCJzZGtfY2xvc2VfYnV0dG9uX3VybCI6Imh0dHBzOlwvXC9tcy1hZHMtZXZlbnRzLnN0YWdpbmcucHJlc2FnZS5pb1wvY3JlYXRpdmU/ZT1zZGtfY2xvc2VfYnV0dG9uJmltcD1mMzM4MTRiZS1jNmM0LTRiNGItYTNmZS05MzA1YjZlMzU0MTEmb2NfaWQ9MzQ3MTcmYWs9MjcyNTA2JnVfaWQ9MDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwJmFfc2RrPTMuMC4wLWJldGEtMS4yLjAmdV9vcz1pb3MmYV9iPWNvLm9ndXJ5LmFkcy5Td2lmdFByZXNhZ2VUZXN0JmFfbj1pT1MlMjBOZXclMjBUZXN0JTIwQXBwIiwic2RrX2JhY2tncm91bmRfY29sb3IiOiIjMDAwMDAwIn1dfQ==");
}

- (void)testShouldReturnIsLoaded {
    self.smallBannerInternalAPI.sequence = OCMClassMock([OGAAdSequence class]);

    OCMStub([self.adManager isLoaded:self.smallBannerInternalAPI.sequence]).andReturn(YES);

    XCTAssertTrue([self.smallBannerInternalAPI isLoaded]);

    OCMVerify([self.adManager isLoaded:self.smallBannerInternalAPI.sequence]);
}

- (void)test_ShouldReturnIsExpanded {
    self.smallBannerInternalAPI.sequence = OCMClassMock([OGAAdSequence class]);

    OCMStub([self.adManager isExpanded:self.smallBannerInternalAPI.sequence]).andReturn(YES);

    XCTAssertTrue(self.smallBannerInternalAPI.isExpanded);

    OCMVerify([self.adManager isExpanded:self.smallBannerInternalAPI.sequence]);
}

- (void)testShouldShowBannerIfLoaded {
    OGABannerAdViewInternalAPI *internalAPI = OCMPartialMock(self.smallBannerInternalAPI);
    internalAPI.adManager = self.adManager;

    UIWindow *windowParentView = OCMClassMock(UIWindow.class);
    UIViewController *viewcontrollerParentView = OCMClassMock(UIViewController.class);
    UIView *bannerView = OCMClassMock(UIView.class);

    [viewcontrollerParentView.view addSubview:bannerView];

    OCMStub([internalAPI bannerView]).andReturn(bannerView);
    OCMStub(bannerView.window).andReturn(windowParentView);
    OCMStub(windowParentView.rootViewController).andReturn(viewcontrollerParentView);
    OCMStub([internalAPI isLoaded]).andReturn(YES);

    OCMExpect([internalAPI isLoaded]);
    OCMExpect([internalAPI.adManager show:OCMOCK_ANY additionalConditions:[OCMArg any]]);

    [self.smallBannerInternalAPI showBannerIfLoaded];

    OCMVerify([internalAPI isLoaded]);
    OCMVerify([internalAPI.adManager show:OCMOCK_ANY additionalConditions:[OCMArg any]]);
}

- (void)testShouldShowBannerWhenMovedToAnotherSuperview {
    OGABannerAdViewInternalAPI *internalAPI = OCMPartialMock(self.smallBannerInternalAPI);

    OCMExpect([internalAPI showBannerIfLoaded]);

    [self.smallBannerInternalAPI didMoveToSuperview];

    OCMVerify([internalAPI showBannerIfLoaded]);
}

- (void)testShouldShowBannerWhenMovedToAnotherWindow {
    OGABannerAdViewInternalAPI *internalAPI = OCMPartialMock(self.smallBannerInternalAPI);

    [self.smallBannerInternalAPI didMoveToWindow];

    OCMVerify([internalAPI showBannerIfLoaded]);
    OCMVerify([self.notificationCenter postNotificationName:OGABannerAdInternalAPIBannerDidMoveToWindowNotificationName object:[OCMArg isKindOfClass:NSString.self] userInfo:nil]);
}

- (void)testShouldDestroy {
    self.smallBannerInternalAPI.sequence = OCMClassMock([OGAAdSequence class]);

    OCMExpect([self.adManager close:self.smallBannerInternalAPI.sequence]);

    [self.smallBannerInternalAPI destroy];

    OCMVerify([self.adManager close:self.smallBannerInternalAPI.sequence]);
}

- (void)testShouldShowBannerAfterLoadIsCompleted {
    OGABannerAdViewInternalAPI *internalAPI = OCMPartialMock(self.smallBannerInternalAPI);
    internalAPI.adManager = self.adManager;

    UIWindow *windowParentView = OCMClassMock(UIWindow.class);
    UIViewController *viewcontrollerParentView = OCMClassMock(UIViewController.class);
    UIView *bannerView = OCMClassMock(UIView.class);

    [viewcontrollerParentView.view addSubview:bannerView];

    OCMStub([internalAPI bannerView]).andReturn(bannerView);
    OCMStub(bannerView.window).andReturn(windowParentView);
    OCMStub(windowParentView.rootViewController).andReturn(viewcontrollerParentView);
    OCMStub([internalAPI isLoaded]).andReturn(YES);

    OguryBannerAdView *bannerAd = OCMClassMock([OguryBannerAdView class]);

    OCMExpect([internalAPI.delegateDispatcher loaded]);
    OCMExpect([internalAPI.adManager show:OCMOCK_ANY additionalConditions:[OCMArg any]]);

    [internalAPI bannerAdViewDidLoad:bannerAd];

    OCMVerify([internalAPI.delegateDispatcher loaded]);
    OCMVerify([internalAPI.adManager show:OCMOCK_ANY additionalConditions:[OCMArg any]]);
}

- (void)testShouldDispatchDidClick {
    OGABannerAdViewInternalAPI *internalAPI = OCMPartialMock(self.smallBannerInternalAPI);

    OguryBannerAdView *bannerAd = OCMClassMock([OguryBannerAdView class]);

    OCMExpect([internalAPI.delegateDispatcher clicked]);

    [internalAPI bannerAdViewDidClick:bannerAd];

    OCMVerify([internalAPI.delegateDispatcher clicked]);
}

- (void)testShouldDispatchDidClose {
    OGABannerAdViewInternalAPI *internalAPI = OCMPartialMock(self.smallBannerInternalAPI);

    OguryBannerAdView *bannerAd = OCMClassMock([OguryBannerAdView class]);

    OCMExpect([internalAPI.delegateDispatcher closed]);

    [internalAPI bannerAdViewDidClose:bannerAd];

    OCMVerify([internalAPI.delegateDispatcher closed]);
}

- (void)testShouldDispatchDidFailWithError {
    OGABannerAdViewInternalAPI *internalAPI = OCMPartialMock(self.smallBannerInternalAPI);

    OguryBannerAdView *bannerAd = OCMClassMock([OguryBannerAdView class]);

    OCMExpect([internalAPI.delegateDispatcher failedWithError:OCMOCK_ANY]);

    [internalAPI bannerAdView:bannerAd didFailWithError:OCMOCK_ANY];

    OCMVerify([internalAPI.delegateDispatcher failedWithError:(OguryAdError *)OCMOCK_ANY]);
}

- (void)testHaveParentViewcontrollerSuperView {
    OGABannerAdViewInternalAPI *internalAPI = OCMPartialMock(self.smallBannerInternalAPI);
    internalAPI.adManager = self.adManager;

    UIWindow *windowParentView = OCMClassMock(UIWindow.class);
    UIViewController *viewcontrollerParentView = OCMClassMock(UIViewController.class);
    UIView *bannerView = OCMClassMock(UIView.class);

    [viewcontrollerParentView.view addSubview:bannerView];

    OCMStub([internalAPI bannerView]).andReturn(bannerView);
    OCMStub(bannerView.window).andReturn(windowParentView);
    OCMStub(windowParentView.rootViewController).andReturn(viewcontrollerParentView);

    XCTAssertTrue([internalAPI haveParentViewcontroller]);
}

- (void)testHaveParentViewcontrollerdelegate {
    OGABannerAdViewInternalAPI *internalAPI = OCMPartialMock(self.smallBannerInternalAPI);
    internalAPI.adManager = self.adManager;

    UIViewController *viewcontrollerParentView = OCMClassMock(UIViewController.class);
    UIView *bannerView = OCMClassMock(UIView.class);

    OCMStub([self.delegateDispatcher bannerViewController]).andReturn(viewcontrollerParentView);
    OCMStub([internalAPI bannerView]).andReturn(bannerView);

    XCTAssertTrue([internalAPI haveParentViewcontroller]);
}

- (void)testHaveParentViewcontrollerNoParent {
    OGABannerAdViewInternalAPI *internalAPI = OCMPartialMock(self.smallBannerInternalAPI);
    internalAPI.adManager = self.adManager;

    UIView *bannerView = OCMClassMock(UIView.class);

    OCMStub([internalAPI bannerView]).andReturn(bannerView);

    XCTAssertFalse([internalAPI haveParentViewcontroller]);
}

#pragma mark - Properties

- (void)testShouldReturnAdUnitId {
    XCTAssertEqualObjects(self.smallBannerInternalAPI.adUnitId, DefaultAdUnitId);
}

- (void)testLoadWithCampaignIdCreativeId {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    self.smallBannerInternalAPI.sequence = previousSequence;
    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    OCMStub([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:[OCMArg any]]).andReturn(sequence);
    [self.smallBannerInternalAPI loadWithCampaignId:@"campaignId" creativeId:@"creativeId"];
    XCTAssertEqualObjects(self.smallBannerInternalAPI.configuration.campaignId, @"campaignId");
    XCTAssertEqualObjects(self.smallBannerInternalAPI.configuration.creativeId, @"creativeId");
    XCTAssertEqual(self.smallBannerInternalAPI.size.getSize.width, [OguryBannerAdSize small_banner_320x50].getSize.width);
    XCTAssertEqual(self.smallBannerInternalAPI.size.getSize.height, [OguryBannerAdSize small_banner_320x50].getSize.height);
    XCTAssertEqual(self.smallBannerInternalAPI.configuration.size.width, [OguryBannerAdSize small_banner_320x50].getSize.width);
    XCTAssertEqual(self.smallBannerInternalAPI.configuration.size.height, [OguryBannerAdSize small_banner_320x50].getSize.height);
    XCTAssertEqual(self.smallBannerInternalAPI.sequence, sequence);
}

- (void)testDidTriggerImpressionOguryBannerAd {
    OguryBannerAdView *banner = OCMClassMock([OguryBannerAdView class]);
    [self.smallBannerInternalAPI bannerAdViewDidTriggerImpression:banner];
    OCMVerify([self.smallBannerInternalAPI.delegateDispatcher adImpression]);
}

- (void)testWhenForceValesChangesThenSequenceIsNil {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    // first call
    [self.smallBannerInternalAPI loadWithCampaignId:DefaultCampaignId
                                         creativeId:DefaultCreativeId
                                      dspCreativeId:DefaultDspCreativeId
                                          dspRegion:DefaultDspRegion];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    self.smallBannerInternalAPI.sequence = previousSequence;
    [self.smallBannerInternalAPI loadWithCampaignId:DefaultCampaignId
                                         creativeId:DefaultCreativeId
                                      dspCreativeId:DefaultDspCreativeId
                                          dspRegion:DefaultDspRegion];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:previousSequence]);
    // update values
    [self.smallBannerInternalAPI loadWithCampaignId:@"newCampaign"
                                         creativeId:DefaultCreativeId
                                      dspCreativeId:DefaultDspCreativeId
                                          dspRegion:DefaultDspRegion];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    [self.smallBannerInternalAPI loadWithCampaignId:DefaultCampaignId
                                         creativeId:@"DefaultCreativeId"
                                      dspCreativeId:DefaultDspCreativeId
                                          dspRegion:DefaultDspRegion];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    [self.smallBannerInternalAPI loadWithCampaignId:DefaultCampaignId
                                         creativeId:DefaultCreativeId
                                      dspCreativeId:@"DefaultDspCreativeId"
                                          dspRegion:DefaultDspRegion];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    [self.smallBannerInternalAPI loadWithCampaignId:DefaultCampaignId
                                         creativeId:DefaultCreativeId
                                      dspCreativeId:DefaultDspCreativeId
                                          dspRegion:@"DefaultDspRegion"];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);
}

@end
