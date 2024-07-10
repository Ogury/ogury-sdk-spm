//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OguryBannerAd.h"
#import "OGABannerAdInternalAPI.h"
#import "OGABannerAdInternalAPI+Testing.h"
#import "OGAAdManager.h"
#import "OGALog.h"
#import "OguryError+utility.h"
#import "OGAMonitoringDispatcher.h"

@interface OGABannerAdInternalAPITests : XCTestCase

#pragma mark - Properties

@property(nonatomic, strong) OGADelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) OGABannerAdInternalAPI *internalAPI;
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

    self.internalAPI = [[OGABannerAdInternalAPI alloc] initWithAdUnitId:DefaultAdUnitId
                                                             bannerView:nil
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
    [self.internalAPI loadWithSize:[OguryAdsBannerSize mpu_300x250]];

    XCTAssertTrue(CGSizeEqualToSize([self.internalAPI.size getSize], [[OguryAdsBannerSize mpu_300x250] getSize]));
    XCTAssertTrue(CGSizeEqualToSize(self.internalAPI.configuration.size, [[OguryAdsBannerSize mpu_300x250] getSize]));
}

- (void)testLoadInit320x50 {
    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    [self.internalAPI loadWithSize:[OguryAdsBannerSize small_banner_320x50]];

    XCTAssertTrue(CGSizeEqualToSize([self.internalAPI.size getSize], [[OguryAdsBannerSize small_banner_320x50] getSize]));
    XCTAssertTrue(CGSizeEqualToSize(self.internalAPI.configuration.size, [[OguryAdsBannerSize small_banner_320x50] getSize]));
}

- (void)testShouldLoad {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);

    self.internalAPI.sequence = previousSequence;

    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    OCMStub([self.adManager loadAdConfiguration:OCMOCK_ANY previousSequence:OCMOCK_ANY]).andReturn(sequence);
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.internalAPI.configuration);
    [self.internalAPI loadWithSize:[OguryAdsBannerSize mpu_300x250]];

    XCTAssertEqual(self.internalAPI.sequence, sequence);
    XCTAssertTrue(CGSizeEqualToSize(self.internalAPI.configuration.size, [[OguryAdsBannerSize mpu_300x250] getSize]));
    XCTAssertNil(self.internalAPI.configuration.campaignId);
    OCMVerify([self.adManager loadAdConfiguration:self.internalAPI.configuration previousSequence:previousSequence]);
}

- (void)testShouldLoadWithCampaign {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);

    self.internalAPI.sequence = previousSequence;
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.internalAPI.configuration);

    OCMStub([self.adManager loadAdConfiguration:OCMOCK_ANY previousSequence:OCMOCK_ANY]).andReturn(sequence);

    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    [self.internalAPI loadWithCampaignId:DefaultCampaignId size:[OguryAdsBannerSize mpu_300x250]];

    XCTAssertEqual(self.internalAPI.sequence, sequence);
    XCTAssertTrue(CGSizeEqualToSize(self.internalAPI.configuration.size, [[OguryAdsBannerSize mpu_300x250] getSize]));
    XCTAssertEqualObjects(self.internalAPI.configuration.campaignId, DefaultCampaignId);
    OCMVerify([self.adManager loadAdConfiguration:self.internalAPI.configuration previousSequence:previousSequence]);
}

- (void)testShouldLoadWithCampaignCreativeId {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);

    self.internalAPI.sequence = previousSequence;

    OCMStub([self.adManager loadAdConfiguration:OCMOCK_ANY previousSequence:OCMOCK_ANY]).andReturn(sequence);
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.internalAPI.configuration);

    [self.internalAPI loadWithCampaignId:DefaultCampaignId creativeId:DefaultCreativeId size:[OguryAdsBannerSize mpu_300x250]];

    XCTAssertEqual(self.internalAPI.sequence, sequence);
    XCTAssertTrue(CGSizeEqualToSize(self.internalAPI.configuration.size, [[OguryAdsBannerSize mpu_300x250] getSize]));
    XCTAssertEqualObjects(self.internalAPI.configuration.campaignId, DefaultCampaignId);
    XCTAssertEqualObjects(self.internalAPI.configuration.creativeId, DefaultCreativeId);
    OCMVerify([self.adManager loadAdConfiguration:self.internalAPI.configuration previousSequence:previousSequence]);
}

- (void)testShouldLoadWithCampaignCreativeIdDspCreativeIdDspRegion {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);

    self.internalAPI.sequence = previousSequence;

    OCMStub([self.adManager loadAdConfiguration:OCMOCK_ANY previousSequence:OCMOCK_ANY]).andReturn(sequence);
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.internalAPI.configuration);

    [self.internalAPI loadWithCampaignId:DefaultCampaignId creativeId:DefaultCreativeId dspCreativeId:DefaultDspCreativeId dspRegion:DefaultDspRegion size:[OguryAdsBannerSize mpu_300x250]];

    XCTAssertEqual(self.internalAPI.sequence, sequence);
    XCTAssertTrue(CGSizeEqualToSize(self.internalAPI.configuration.size, [[OguryAdsBannerSize mpu_300x250] getSize]));
    XCTAssertEqualObjects(self.internalAPI.configuration.campaignId, DefaultCampaignId);
    XCTAssertEqualObjects(self.internalAPI.configuration.creativeId, DefaultCreativeId);
    XCTAssertEqualObjects(self.internalAPI.configuration.adDsp.region, DefaultDspRegion);
    XCTAssertEqualObjects(self.internalAPI.configuration.adDsp.creativeId, DefaultDspCreativeId);
    OCMVerify([self.adManager loadAdConfiguration:self.internalAPI.configuration previousSequence:previousSequence]);
}

- (void)testloadWithAdMarkUpPassed {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    self.internalAPI.sequence = previousSequence;
    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    OCMStub(previousSequence.monitoringAdConfiguration).andReturn(self.internalAPI.configuration);
    [self.internalAPI loadWithAdMarkup:@"eyJhZCI6W3siZm9ybWF0Ijp7InBhcmFtcyI6W3sibmFtZSI6InpvbmVzIiwidmFsdWUiOlt7Im5hbWUiOiJjb250cm9sbGVyIiwidXJsIjoiaHR0cHM6XC9cL3N0YWdpbmcubGl0ZWNkbi5jb21cLzIwMjEtMTAtMTMtYTgyZWIwYThcL2Zvcm1hdHNcL21yYWlkLXdyYXBwZXJcL2luZGV4Lmh0bWwiLCJzaXplIjp7IndpZHRoIjotMSwiaGVpZ2h0IjotMX19XX1dLCJ3ZWJ2aWV3X2Jhc2VfdXJsIjoiaHR0cDpcL1wvd3d3Lm9neWZtdHMuY29tXC8iLCJtcmFpZF9kb3dubG9hZF91cmwiOiJodHRwczpcL1wvbXJhaWQucHJlc2FnZS5pb1wvYmY2YWJiNlwvbXJhaWQuanMifSwiY2FtcGFpZ25faWQiOjM0NzE3LCJwYXJhbXMiOltdLCJhZF9jb250ZW50IjoiPGh0bWw+ICA8aGVhZD4gIDxtZXRhIGNoYXJzZXQ9XCJVVEYtOFwiPiAgPG1ldGEgbmFtZT1cInZpZXdwb3J0XCIgY29udGVudD1cIndpZHRoPWRldmljZS13aWR0aCwgaW5pdGlhbC1zY2FsZT0xLjAsIHVzZXItc2NhbGFibGU9bm9cIj4gIDxsaW5rIHJlbD1cImljb25cIiB0eXBlPVwiaW1hZ2VcL3BuZ1wiIGhyZWY9XCJkYXRhOmltYWdlXC9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvPVwiPiAgPFwvaGVhZD4gIDxib2R5PiAgPGRpdiBpZD1cInJvb3RcIj4gIDxcL2Rpdj4gIDxzY3JpcHQgc3JjPVwibXJhaWQuanNcIj48XC9zY3JpcHQ+ICA8c2NyaXB0IHNyYz1cImh0dHBzOlwvXC9tcy1hZHMuc3RhZ2luZy5wcmVzYWdlLmlvXC9tcmFpZD9kc3A9b2d1cnkmdD1mMDZkOTQyMS04MGJkLTQwZjEtYTBjYi1mMTEwZGQxZGYzMTImaW1wPWYzMzgxNGJlLWM2YzQtNGI0Yi1hM2ZlLTkzMDViNmUzNTQxMSZvY191dWlkPWJhNGU4NGQ1LTUwZGItNDIxNi04OWZiLTg0NTRiZTU2MTljYSZhaz0yNzI1MDYmdV9kbz1mYWxzZSZ1X2lkPTAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMCZhX3Nkaz0zLjAuMC1iZXRhLTEuMi4wJmF1aWQ9MjcyNTA2X2RlZmF1bHQmY29ubj1BTEwmdV9vcz1pb3MmYV9iPWNvLm9ndXJ5LmFkcy5Td2lmdFByZXNhZ2VUZXN0JmFfbj1pT1MlMjBOZXclMjBUZXN0JTIwQXBwJmF1dHlwZT1pbnRlcnN0aXRpYWwmYV9leD1vZ3VyeSZ0X2E9dHJ1ZSZiaWRfaGFzaD0mZG1uPSZwZz0mZF9tPXg4Nl82NCZkX3R5PW1vYmlsZSZ1X3RrPTVmYmIzNTNmLTBiNGUtNGZiMi04YTUyLTgzMmRhZGIxZDFiZCZhdWQ9dHJ1ZSZkdWFsYWQ9Jmc9JmNfcz1cIj48XC9zY3JpcHQ+ICA8XC9ib2R5PiAgPFwvaHRtbD4iLCJpZCI6ImYzMzgxNGJlLWM2YzQtNGI0Yi1hM2ZlLTkzMDViNmUzNTQxMSIsImlzX2ltcHJlc3Npb24iOnRydWUsImFkdmVydGlzZXIiOnsiaWQiOjEzNywibmFtZSI6IlBoaWxpcHMifSwiYWRfa2VlcF9hbGl2ZSI6dHJ1ZSwiYWRfdW5pdCI6eyJpZCI6IjI3MjUwNl9kZWZhdWx0IiwidHlwZSI6ImludGVyc3RpdGlhbCJ9LCJzZGtfY2xvc2VfYnV0dG9uX3VybCI6Imh0dHBzOlwvXC9tcy1hZHMtZXZlbnRzLnN0YWdpbmcucHJlc2FnZS5pb1wvY3JlYXRpdmU/ZT1zZGtfY2xvc2VfYnV0dG9uJmltcD1mMzM4MTRiZS1jNmM0LTRiNGItYTNmZS05MzA1YjZlMzU0MTEmb2NfaWQ9MzQ3MTcmYWs9MjcyNTA2JnVfaWQ9MDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwJmFfc2RrPTMuMC4wLWJldGEtMS4yLjAmdV9vcz1pb3MmYV9iPWNvLm9ndXJ5LmFkcy5Td2lmdFByZXNhZ2VUZXN0JmFfbj1pT1MlMjBOZXclMjBUZXN0JTIwQXBwIiwic2RrX2JhY2tncm91bmRfY29sb3IiOiIjMDAwMDAwIn1dfQ==" size:[OguryAdsBannerSize mpu_300x250]];
    XCTAssertNotNil(self.internalAPI.configuration.encodedAdMarkup);
    XCTAssertTrue(CGSizeEqualToSize(self.internalAPI.configuration.size, [[OguryAdsBannerSize mpu_300x250] getSize]));
    XCTAssertNil(self.internalAPI.configuration.campaignId);
    OCMVerify([self.adManager loadAdConfiguration:self.internalAPI.configuration previousSequence:previousSequence]);
    XCTAssertEqualObjects(self.internalAPI.configuration.encodedAdMarkup, @"eyJhZCI6W3siZm9ybWF0Ijp7InBhcmFtcyI6W3sibmFtZSI6InpvbmVzIiwidmFsdWUiOlt7Im5hbWUiOiJjb250cm9sbGVyIiwidXJsIjoiaHR0cHM6XC9cL3N0YWdpbmcubGl0ZWNkbi5jb21cLzIwMjEtMTAtMTMtYTgyZWIwYThcL2Zvcm1hdHNcL21yYWlkLXdyYXBwZXJcL2luZGV4Lmh0bWwiLCJzaXplIjp7IndpZHRoIjotMSwiaGVpZ2h0IjotMX19XX1dLCJ3ZWJ2aWV3X2Jhc2VfdXJsIjoiaHR0cDpcL1wvd3d3Lm9neWZtdHMuY29tXC8iLCJtcmFpZF9kb3dubG9hZF91cmwiOiJodHRwczpcL1wvbXJhaWQucHJlc2FnZS5pb1wvYmY2YWJiNlwvbXJhaWQuanMifSwiY2FtcGFpZ25faWQiOjM0NzE3LCJwYXJhbXMiOltdLCJhZF9jb250ZW50IjoiPGh0bWw+ICA8aGVhZD4gIDxtZXRhIGNoYXJzZXQ9XCJVVEYtOFwiPiAgPG1ldGEgbmFtZT1cInZpZXdwb3J0XCIgY29udGVudD1cIndpZHRoPWRldmljZS13aWR0aCwgaW5pdGlhbC1zY2FsZT0xLjAsIHVzZXItc2NhbGFibGU9bm9cIj4gIDxsaW5rIHJlbD1cImljb25cIiB0eXBlPVwiaW1hZ2VcL3BuZ1wiIGhyZWY9XCJkYXRhOmltYWdlXC9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvPVwiPiAgPFwvaGVhZD4gIDxib2R5PiAgPGRpdiBpZD1cInJvb3RcIj4gIDxcL2Rpdj4gIDxzY3JpcHQgc3JjPVwibXJhaWQuanNcIj48XC9zY3JpcHQ+ICA8c2NyaXB0IHNyYz1cImh0dHBzOlwvXC9tcy1hZHMuc3RhZ2luZy5wcmVzYWdlLmlvXC9tcmFpZD9kc3A9b2d1cnkmdD1mMDZkOTQyMS04MGJkLTQwZjEtYTBjYi1mMTEwZGQxZGYzMTImaW1wPWYzMzgxNGJlLWM2YzQtNGI0Yi1hM2ZlLTkzMDViNmUzNTQxMSZvY191dWlkPWJhNGU4NGQ1LTUwZGItNDIxNi04OWZiLTg0NTRiZTU2MTljYSZhaz0yNzI1MDYmdV9kbz1mYWxzZSZ1X2lkPTAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMCZhX3Nkaz0zLjAuMC1iZXRhLTEuMi4wJmF1aWQ9MjcyNTA2X2RlZmF1bHQmY29ubj1BTEwmdV9vcz1pb3MmYV9iPWNvLm9ndXJ5LmFkcy5Td2lmdFByZXNhZ2VUZXN0JmFfbj1pT1MlMjBOZXclMjBUZXN0JTIwQXBwJmF1dHlwZT1pbnRlcnN0aXRpYWwmYV9leD1vZ3VyeSZ0X2E9dHJ1ZSZiaWRfaGFzaD0mZG1uPSZwZz0mZF9tPXg4Nl82NCZkX3R5PW1vYmlsZSZ1X3RrPTVmYmIzNTNmLTBiNGUtNGZiMi04YTUyLTgzMmRhZGIxZDFiZCZhdWQ9dHJ1ZSZkdWFsYWQ9Jmc9JmNfcz1cIj48XC9zY3JpcHQ+ICA8XC9ib2R5PiAgPFwvaHRtbD4iLCJpZCI6ImYzMzgxNGJlLWM2YzQtNGI0Yi1hM2ZlLTkzMDViNmUzNTQxMSIsImlzX2ltcHJlc3Npb24iOnRydWUsImFkdmVydGlzZXIiOnsiaWQiOjEzNywibmFtZSI6IlBoaWxpcHMifSwiYWRfa2VlcF9hbGl2ZSI6dHJ1ZSwiYWRfdW5pdCI6eyJpZCI6IjI3MjUwNl9kZWZhdWx0IiwidHlwZSI6ImludGVyc3RpdGlhbCJ9LCJzZGtfY2xvc2VfYnV0dG9uX3VybCI6Imh0dHBzOlwvXC9tcy1hZHMtZXZlbnRzLnN0YWdpbmcucHJlc2FnZS5pb1wvY3JlYXRpdmU/ZT1zZGtfY2xvc2VfYnV0dG9uJmltcD1mMzM4MTRiZS1jNmM0LTRiNGItYTNmZS05MzA1YjZlMzU0MTEmb2NfaWQ9MzQ3MTcmYWs9MjcyNTA2JnVfaWQ9MDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwJmFfc2RrPTMuMC4wLWJldGEtMS4yLjAmdV9vcz1pb3MmYV9iPWNvLm9ndXJ5LmFkcy5Td2lmdFByZXNhZ2VUZXN0JmFfbj1pT1MlMjBOZXclMjBUZXN0JTIwQXBwIiwic2RrX2JhY2tncm91bmRfY29sb3IiOiIjMDAwMDAwIn1dfQ==");
}

- (void)testShouldReturnIsLoaded {
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

- (void)testShouldShowBannerIfLoaded {
    OGABannerAdInternalAPI *internalAPI = OCMPartialMock(self.internalAPI);
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

    [self.internalAPI showBannerIfLoaded];

    OCMVerify([internalAPI isLoaded]);
    OCMVerify([internalAPI.adManager show:OCMOCK_ANY additionalConditions:[OCMArg any]]);
}

- (void)testShouldShowBannerWhenMovedToAnotherSuperview {
    OGABannerAdInternalAPI *internalAPI = OCMPartialMock(self.internalAPI);

    OCMExpect([internalAPI showBannerIfLoaded]);

    [self.internalAPI didMoveToSuperview];

    OCMVerify([internalAPI showBannerIfLoaded]);
}

- (void)testShouldShowBannerWhenMovedToAnotherWindow {
    OGABannerAdInternalAPI *internalAPI = OCMPartialMock(self.internalAPI);

    [self.internalAPI didMoveToWindow];

    OCMVerify([internalAPI showBannerIfLoaded]);
    OCMVerify([self.notificationCenter postNotificationName:OGABannerAdInternalAPIBannerDidMoveToWindowNotificationName object:[OCMArg isKindOfClass:NSString.self] userInfo:nil]);
}

- (void)testShouldDestroy {
    self.internalAPI.sequence = OCMClassMock([OGAAdSequence class]);

    OCMExpect([self.adManager close:self.internalAPI.sequence]);

    [self.internalAPI destroy];

    OCMVerify([self.adManager close:self.internalAPI.sequence]);
}

- (void)testShouldShowBannerAfterLoadIsCompleted {
    OGABannerAdInternalAPI *internalAPI = OCMPartialMock(self.internalAPI);
    internalAPI.adManager = self.adManager;

    UIWindow *windowParentView = OCMClassMock(UIWindow.class);
    UIViewController *viewcontrollerParentView = OCMClassMock(UIViewController.class);
    UIView *bannerView = OCMClassMock(UIView.class);

    [viewcontrollerParentView.view addSubview:bannerView];

    OCMStub([internalAPI bannerView]).andReturn(bannerView);
    OCMStub(bannerView.window).andReturn(windowParentView);
    OCMStub(windowParentView.rootViewController).andReturn(viewcontrollerParentView);
    OCMStub([internalAPI isLoaded]).andReturn(YES);

    OguryBannerAd *bannerAd = OCMClassMock([OguryBannerAd class]);

    OCMExpect([internalAPI.delegateDispatcher loaded]);
    OCMExpect([internalAPI.adManager show:OCMOCK_ANY additionalConditions:[OCMArg any]]);

    [internalAPI didLoadOguryBannerAd:bannerAd];

    OCMVerify([internalAPI.delegateDispatcher loaded]);
    OCMVerify([internalAPI.adManager show:OCMOCK_ANY additionalConditions:[OCMArg any]]);
}

- (void)testShouldDispatchDidDisplay {
    OGABannerAdInternalAPI *internalAPI = OCMPartialMock(self.internalAPI);

    OguryBannerAd *bannerAd = OCMClassMock([OguryBannerAd class]);

    OCMExpect([internalAPI.delegateDispatcher displayed]);

    [internalAPI didDisplayOguryBannerAd:bannerAd];

    OCMVerify([internalAPI.delegateDispatcher displayed]);
}

- (void)testShouldDispatchDidClick {
    OGABannerAdInternalAPI *internalAPI = OCMPartialMock(self.internalAPI);

    OguryBannerAd *bannerAd = OCMClassMock([OguryBannerAd class]);

    OCMExpect([internalAPI.delegateDispatcher clicked]);

    [internalAPI didClickOguryBannerAd:bannerAd];

    OCMVerify([internalAPI.delegateDispatcher clicked]);
}

- (void)testShouldDispatchDidClose {
    OGABannerAdInternalAPI *internalAPI = OCMPartialMock(self.internalAPI);

    OguryBannerAd *bannerAd = OCMClassMock([OguryBannerAd class]);

    OCMExpect([internalAPI.delegateDispatcher closed]);

    [internalAPI didCloseOguryBannerAd:bannerAd];

    OCMVerify([internalAPI.delegateDispatcher closed]);
}

- (void)testShouldDispatchDidFailWithError {
    OGABannerAdInternalAPI *internalAPI = OCMPartialMock(self.internalAPI);

    OguryBannerAd *bannerAd = OCMClassMock([OguryBannerAd class]);

    OCMExpect([internalAPI.delegateDispatcher failedWithError:OCMOCK_ANY]);

    [internalAPI didFailOguryBannerAdWithError:OCMOCK_ANY forAd:bannerAd];

    OCMVerify([internalAPI.delegateDispatcher failedWithError:(OguryError *)OCMOCK_ANY]);
}

- (void)testHaveParentViewcontrollerSuperView {
    OGABannerAdInternalAPI *internalAPI = OCMPartialMock(self.internalAPI);
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
    OGABannerAdInternalAPI *internalAPI = OCMPartialMock(self.internalAPI);
    internalAPI.adManager = self.adManager;

    UIViewController *viewcontrollerParentView = OCMClassMock(UIViewController.class);
    UIView *bannerView = OCMClassMock(UIView.class);

    OCMStub([self.delegateDispatcher bannerViewController]).andReturn(viewcontrollerParentView);
    OCMStub([internalAPI bannerView]).andReturn(bannerView);

    XCTAssertTrue([internalAPI haveParentViewcontroller]);
}

- (void)testHaveParentViewcontrollerNoParent {
    OGABannerAdInternalAPI *internalAPI = OCMPartialMock(self.internalAPI);
    internalAPI.adManager = self.adManager;

    UIView *bannerView = OCMClassMock(UIView.class);

    OCMStub([internalAPI bannerView]).andReturn(bannerView);

    XCTAssertFalse([internalAPI haveParentViewcontroller]);
}

#pragma mark - Properties

- (void)testShouldReturnAdUnitId {
    XCTAssertEqualObjects(self.internalAPI.adUnitId, DefaultAdUnitId);
}

- (void)testLoadWithCampaignIdCreativeId {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    OGAAdSequence *sequence = OCMClassMock([OGAAdSequence class]);
    self.internalAPI.sequence = previousSequence;
    OCMStub(self.internal.sdkInitialized).andReturn(YES);
    OCMStub([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:[OCMArg any]]).andReturn(sequence);
    [self.internalAPI loadWithCampaignId:@"campaignId" creativeId:@"creativeId" size:[OguryAdsBannerSize mpu_300x250]];
    XCTAssertEqualObjects(self.internalAPI.configuration.campaignId, @"campaignId");
    XCTAssertEqualObjects(self.internalAPI.configuration.creativeId, @"creativeId");
    XCTAssertEqual(self.internalAPI.size.getSize.width, [OguryAdsBannerSize mpu_300x250].getSize.width);
    XCTAssertEqual(self.internalAPI.size.getSize.height, [OguryAdsBannerSize mpu_300x250].getSize.height);
    XCTAssertEqual(self.internalAPI.configuration.size.width, [OguryAdsBannerSize mpu_300x250].getSize.width);
    XCTAssertEqual(self.internalAPI.configuration.size.height, [OguryAdsBannerSize mpu_300x250].getSize.height);
    XCTAssertEqual(self.internalAPI.sequence, sequence);
}

- (void)testDidTriggerImpressionOguryBannerAd {
    OguryBannerAd *banner = OCMClassMock([OguryBannerAd class]);
    [self.internalAPI didTriggerImpressionOguryBannerAd:banner];
    OCMVerify([self.internalAPI.delegateDispatcher adImpression]);
}

- (void)testWhenForceValesChangesThenSequenceIsNil {
    OGAAdSequence *previousSequence = OCMClassMock([OGAAdSequence class]);
    // first call
    [self.internalAPI loadWithCampaignId:DefaultCampaignId
                              creativeId:DefaultCreativeId
                           dspCreativeId:DefaultDspCreativeId
                               dspRegion:DefaultDspRegion
                                    size:[OguryAdsBannerSize mpu_300x250]];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    self.internalAPI.sequence = previousSequence;
    [self.internalAPI loadWithCampaignId:DefaultCampaignId
                              creativeId:DefaultCreativeId
                           dspCreativeId:DefaultDspCreativeId
                               dspRegion:DefaultDspRegion
                                    size:[OguryAdsBannerSize mpu_300x250]];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:previousSequence]);
    // update values
    [self.internalAPI loadWithCampaignId:@"newCampaign"
                              creativeId:DefaultCreativeId
                           dspCreativeId:DefaultDspCreativeId
                               dspRegion:DefaultDspRegion
                                    size:[OguryAdsBannerSize mpu_300x250]];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    [self.internalAPI loadWithCampaignId:DefaultCampaignId
                              creativeId:@"DefaultCreativeId"
                           dspCreativeId:DefaultDspCreativeId
                               dspRegion:DefaultDspRegion
                                    size:[OguryAdsBannerSize mpu_300x250]];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    [self.internalAPI loadWithCampaignId:DefaultCampaignId
                              creativeId:DefaultCreativeId
                           dspCreativeId:@"DefaultDspCreativeId"
                               dspRegion:DefaultDspRegion
                                    size:[OguryAdsBannerSize mpu_300x250]];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);

    [self.internalAPI loadWithCampaignId:DefaultCampaignId
                              creativeId:DefaultCreativeId
                           dspCreativeId:DefaultDspCreativeId
                               dspRegion:@"DefaultDspRegion"
                                    size:[OguryAdsBannerSize mpu_300x250]];
    OCMVerify([self.adManager loadAdConfiguration:[OCMArg any] previousSequence:nil]);
}

@end
