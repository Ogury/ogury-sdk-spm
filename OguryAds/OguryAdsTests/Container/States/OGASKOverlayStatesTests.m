//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGASKOverlayState.h"
#import "OGAMonitoringDispatcher+SKNetwork.h"
#import <StoreKit/StoreKit.h>

API_AVAILABLE(ios(14.0))
@interface OGASKOverlayState (Tests)

@property(nonatomic, strong) NSError *loadError;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) SKOverlay *skOverlay;

- (instancetype)initWithAd:(OGAAd *)ad monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher viewControllerProvider:(UIViewController * (^)(void))viewControllerProvider;
- (void)loadStoreKitViewController:(OGAAd *)ad;
- (SKOverlayAppConfiguration *)getSKOverlayConfiguration:(OGAAd *)ad;

@end

API_AVAILABLE(ios(14.0))
@interface OGASKOverlayStatesTests : XCTestCase

@property(nonatomic, strong) OGASKOverlayState *state;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) UIViewController *rootViewController;

@end

@implementation OGASKOverlayStatesTests

- (void)setUp {
    self.rootViewController = OCMClassMock([UIViewController class]);
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    OGAAd *ad = OCMClassMock([OGAAd class]);
    self.state = OCMPartialMock([[OGASKOverlayState alloc] initWithAd:ad
                                                 monitoringDispatcher:self.monitoringDispatcher
                                               viewControllerProvider:^UIViewController * {
                                                   return self.rootViewController;
                                               }]);
}

#pragma mark - Properties

- (void)testState {
    XCTAssertEqualObjects(self.state.name, @"SKOverlay");
}

- (void)testType {
    XCTAssertEqual(self.state.type, OGAAdContainerStateTypeFullScreenOverlay);
}

- (void)test_ShouldReturnIsExpandedAsTrue {
    XCTAssertTrue(self.state.isExpanded);
}

#pragma mark - methodes

- (void)test_getSKOverlayConfiguration {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OGASKAdNetworkResponse *skAdResponse = OCMClassMock([OGASKAdNetworkResponse class]);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(skAdResponse.sourceAppId).andReturn(@0);
    OCMStub(skAdResponse.itunesItemId).andReturn(@1596467464);
    OCMStub(skAdResponse.signature).andReturn(@"MEQCIBQA0kEuLF7bUJyY3sJ2WNgfQInCLWmctwJq5speR8q4AiADjWBpadjcTNhzjoWKUo+fFjWVD2QS0z3saAX7pG0r0A==");
    OCMStub(skAdResponse.nonce).andReturn(@"b5d81675-26f5-41c0-ab92-fdfdc540465c");
    OCMStub(skAdResponse.version).andReturn(@"2.2");
    OCMStub(skAdResponse.networkIdentifier).andReturn(@"w7jznl3r6g.skadnetwork");
    OCMStub(skAdResponse.isStoreKitDisplay).andReturn(YES);
    OCMStub(skAdResponse.fidelity).andReturn(@1);
    OCMStub(skAdResponse.campaignId).andReturn(@89);
    OCMStub(skAdResponse.timestamp).andReturn(@1682001371);
    OCMStub(ad.skAdNetworkResponse).andReturn(skAdResponse);
    OCMStub(ad.adConfiguration).andReturn(adConfiguration);

    SKOverlayAppConfiguration *configuration = [self.state getSKOverlayConfiguration:ad];

    XCTAssertTrue([configuration.appIdentifier isEqualToString:@"1596467464"]);
    XCTAssertEqual(configuration.position, SKOverlayPositionBottom);

    XCTAssertTrue([[configuration additionalValueForKey:SKStoreProductParameterITunesItemIdentifier] isEqualToString:@"1596467464"]);
    XCTAssertTrue([[configuration additionalValueForKey:SKStoreProductParameterAdNetworkVersion] isEqualToString:@"2.2"]);
    XCTAssertTrue([[configuration additionalValueForKey:SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] isEqualToString:@"0"]);
    XCTAssertTrue([[configuration additionalValueForKey:SKStoreProductParameterAdNetworkAttributionSignature] isEqualToString:@"MEQCIBQA0kEuLF7bUJyY3sJ2WNgfQInCLWmctwJq5speR8q4AiADjWBpadjcTNhzjoWKUo+fFjWVD2QS0z3saAX7pG0r0A=="]);
    XCTAssertTrue([[configuration additionalValueForKey:SKStoreProductParameterAdNetworkTimestamp] isEqualToString:@"1682001371"]);
    XCTAssertTrue([[configuration additionalValueForKey:SKStoreProductParameterAdNetworkIdentifier] isEqualToString:@"w7jznl3r6g.skadnetwork"]);
    NSLog([[configuration additionalValueForKey:SKStoreProductParameterAdNetworkNonce] UUIDString]);
    XCTAssertTrue([[[configuration additionalValueForKey:SKStoreProductParameterAdNetworkNonce] UUIDString] isEqualToString:@"B5D81675-26F5-41C0-AB92-FDFDC540465C"]);
    XCTAssertTrue([[configuration additionalValueForKey:SKStoreProductParameterAdNetworkCampaignIdentifier] isEqualToString:@"89"]);
}

- (void)test_getSKOverlayConfiguration_notStoreKit {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OGASKAdNetworkResponse *skanResponse = OCMClassMock([OGASKAdNetworkResponse class]);
    NSNumber *itunesItemId = @124456;
    NSString *nonce = @"68753A44-4D6F-1226-9C60-0050E4C00067";
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(skanResponse.sourceAppId).andReturn(@123456);
    OCMStub(skanResponse.itunesItemId).andReturn(itunesItemId);
    OCMStub(skanResponse.signature).andReturn(@"124456");
    OCMStub(skanResponse.nonce).andReturn(nonce);
    OCMStub(skanResponse.version).andReturn(@"2.2");
    OCMStub(skanResponse.networkIdentifier).andReturn(@"124456");
    OCMStub(skanResponse.campaignId).andReturn(@44);
    OCMStub(skanResponse.isStoreKitDisplay).andReturn(NO);
    OCMStub(skanResponse.timestamp).andReturn([NSNumber numberWithLongLong:([[NSDate date] timeIntervalSince1970])]);
    OCMStub(ad.skAdNetworkResponse).andReturn(skanResponse);
    OCMStub(ad.adConfiguration).andReturn(adConfiguration);
    OCMStub(self.state.loadError).andReturn(NULL);

    [self.state getSKOverlayConfiguration:ad];

    OCMReject([self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerLoading nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration]);
}

- (void)test_display_No_Data {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub(displayer.ad).andReturn(ad);
    OCMStub(self.state.loadError).andReturn(NULL);

    OguryError *error = nil;
    XCTAssertFalse([self.state display:displayer error:&error]);
}

- (void)test_display_Load_Failed {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub(displayer.ad).andReturn(ad);
    OGASKAdNetworkResponse *skanResponse = OCMClassMock([OGASKAdNetworkResponse class]);
    OCMStub(skanResponse.isStoreKitDisplay).andReturn(YES);
    OCMStub(ad.skAdNetworkResponse).andReturn(skanResponse);
    OCMStub(self.state.loadError).andReturn([[NSError alloc] init]);

    OguryError *error = nil;
    XCTAssertFalse([self.state display:displayer error:&error]);
}

- (void)test_display_no_error {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub(displayer.ad).andReturn(ad);
    OGASKAdNetworkResponse *skAdResponse = OCMClassMock([OGASKAdNetworkResponse class]);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(skAdResponse.sourceAppId).andReturn(@0);
    OCMStub(skAdResponse.itunesItemId).andReturn(@1596467464);
    OCMStub(skAdResponse.signature).andReturn(@"MEQCIBQA0kEuLF7bUJyY3sJ2WNgfQInCLWmctwJq5speR8q4AiADjWBpadjcTNhzjoWKUo+fFjWVD2QS0z3saAX7pG0r0A==");
    OCMStub(skAdResponse.nonce).andReturn(@"b5d81675-26f5-41c0-ab92-fdfdc540465c");
    OCMStub(skAdResponse.version).andReturn(@"2.2");
    OCMStub(skAdResponse.networkIdentifier).andReturn(@"w7jznl3r6g.skadnetwork");
    OCMStub(skAdResponse.isStoreKitDisplay).andReturn(YES);
    OCMStub(skAdResponse.fidelity).andReturn(@1);
    OCMStub(skAdResponse.campaignId).andReturn(@89);
    OCMStub(skAdResponse.timestamp).andReturn(@1682001371);
    OCMStub(ad.skAdNetworkResponse).andReturn(skAdResponse);
    OCMStub(ad.adConfiguration).andReturn(adConfiguration);

    OguryError *error = nil;
    XCTAssertTrue([self.state display:displayer error:&error]);
    OCMVerify([self.state.skOverlay presentInScene:[OCMArg any]]);
}

@end
