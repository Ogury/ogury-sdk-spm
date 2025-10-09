//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAStoreKitState.h"
#import "OGAMonitoringDispatcher+SKNetwork.h"
#import <StoreKit/StoreKit.h>

@interface OGAStoreKitState (Tests)

@property(nonatomic, strong) NSError *loadError;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) SKStoreProductViewController *storeProductViewController;

- (instancetype)initWithAd:(OGAAd *)ad monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher viewControllerProvider:(UIViewController * (^)(void))viewControllerProvider;
- (void)loadStoreKitViewController:(OGAAd *)ad;

@end

@interface OGAStoreKitStateTests : XCTestCase

@property(nonatomic, strong) OGAStoreKitState *state;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) UIViewController *rootViewController;
@property(nonatomic, strong) SKStoreProductViewController *storeProductViewController;

@end

@implementation OGAStoreKitStateTests

- (void)setUp {
    self.rootViewController = OCMClassMock([UIViewController class]);
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    OGAAd *ad = OCMClassMock([OGAAd class]);
    self.storeProductViewController = OCMClassMock([SKStoreProductViewController class]);
    self.state = OCMPartialMock([[OGAStoreKitState alloc] initWithAd:ad
                                                monitoringDispatcher:self.monitoringDispatcher
                                              viewControllerProvider:^UIViewController * {
                                                  return self.rootViewController;
                                              }]);
}

#pragma mark - Properties

- (void)testState {
    XCTAssertEqualObjects(self.state.name, @"storekit");
}

- (void)testType {
    XCTAssertEqual(self.state.type, OGAAdContainerStateTypeFullScreenOverlay);
}

- (void)test_ShouldReturnIsExpandedAsFalse {
    XCTAssertTrue(self.state.isExpanded);
}

#pragma mark - methodes

- (void)testLoadStoreKitViewController {
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
    OCMStub(skanResponse.isStoreKitDisplay).andReturn(YES);
    OCMStub(skanResponse.timestamp).andReturn([NSNumber numberWithLongLong:([[NSDate date] timeIntervalSince1970])]);
    OCMStub(ad.skAdNetworkResponse).andReturn(skanResponse);
    OCMStub(ad.adConfiguration).andReturn(adConfiguration);
    OCMStub(self.state.loadError).andReturn(NULL);

    if (@available(iOS 14.0, *)) {
        OCMStub([self.storeProductViewController loadProductWithParameters:[OCMArg any] completionBlock:([OCMArg invokeBlockWithArgs:@YES, [NSNull null], nil])]);
    }
    self.state.storeProductViewController = self.storeProductViewController;
    [self.state loadStoreKitViewController:ad];
    OCMVerify([self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerLoading nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration]);
    if (@available(iOS 14.0, *)) {
        OCMVerify([self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerLoaded nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration]);
    } else {
        OCMVerify([self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration]);
    }
}

- (void)testLoadStoreKitViewController_notStoreKit {
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

    self.state.storeProductViewController = self.storeProductViewController;
    OCMReject([self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerLoading nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration]);
    if (@available(iOS 14.0, *)) {
        OCMReject([self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerLoaded nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration]);
    } else {
        OCMReject([self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration]);
    }
    [self.state loadStoreKitViewController:ad];
}

- (void)testLoadStoreKitViewController_Error {
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
    OCMStub(skanResponse.isStoreKitDisplay).andReturn(YES);
    OCMStub(skanResponse.timestamp).andReturn([NSNumber numberWithLongLong:([[NSDate date] timeIntervalSince1970])]);
    OCMStub(ad.skAdNetworkResponse).andReturn(skanResponse);
    OCMStub(ad.adConfiguration).andReturn(adConfiguration);
    OCMStub(self.state.loadError).andReturn(NULL);

    if (@available(iOS 14.0, *)) {
        NSError *error = OCMClassMock([NSError class]);
        OCMStub([self.storeProductViewController loadProductWithParameters:[OCMArg any] completionBlock:([OCMArg invokeBlockWithArgs:@YES, error, nil])]);
    }
    self.state.storeProductViewController = self.storeProductViewController;
    [self.state loadStoreKitViewController:ad];
    OCMVerify([self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerLoading nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration]);
    if (@available(iOS 14.0, *)) {
        OCMVerify([self.monitoringDispatcher sendSKNetworkFailedLoadStoreControllerEvent:OGASKNetworkLoadErrorEventFailedLoadingStoreController nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration]);
    } else {
        OCMVerify([self.monitoringDispatcher sendSKNetworkLoadStoreControllerEvent:OGASKNetworkLoadEventStoreViewControllerIncompatibleIOSVersion nonce:nonce itunesItemId:itunesItemId adConfiguration:adConfiguration]);
    }
}

- (void)test_display_Storekit {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub(displayer.ad).andReturn(ad);
    OGASKAdNetworkResponse *skanResponse = OCMClassMock([OGASKAdNetworkResponse class]);
    OCMStub(skanResponse.isStoreKitDisplay).andReturn(YES);
    OCMStub(ad.skAdNetworkResponse).andReturn(skanResponse);
    OCMStub(self.state.loadError).andReturn(NULL);

    OguryError *error = nil;
    XCTAssertTrue([self.state display:displayer error:&error]);
    OCMVerify([self.rootViewController presentViewController:[OCMArg any] animated:YES completion:[OCMArg any]]);
}

- (void)test_display_Not_Storekit {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub(displayer.ad).andReturn(ad);
    OGASKAdNetworkResponse *skanResponse = OCMClassMock([OGASKAdNetworkResponse class]);
    OCMStub(skanResponse.isStoreKitDisplay).andReturn(NO);
    OCMStub(ad.skAdNetworkResponse).andReturn(skanResponse);
    OCMStub(self.state.loadError).andReturn(NULL);

    OguryError *error = nil;
    XCTAssertFalse([self.state display:displayer error:&error]);
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

@end
