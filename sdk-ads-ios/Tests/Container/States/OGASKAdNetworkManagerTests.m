//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGASKAdNetworkManager.h"
#import "OGASKAdNetworkService.h"
#import "OGAAd.h"
#import "OGALog.h"
#import "OGAMonitoringDispatcher+SKNetwork.h"

@interface OGASKAdNetworkManager (Tests)

@property(nonatomic, strong) SKAdImpression *impression API_AVAILABLE(ios(14.5));
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;

- (instancetype)initWithLog:(OGALog *)log monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher;

@end

@interface OGASKAdNetworkManagerTests : XCTestCase

@property(nonatomic, strong) OGASKAdNetworkManager *sKAdNetworkManager;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;

@end

@implementation OGASKAdNetworkManagerTests

- (void)setUp {
    self.log = OCMClassMock([OGALog class]);
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    self.sKAdNetworkManager = OCMPartialMock([[OGASKAdNetworkManager alloc] initWithLog:self.log monitoringDispatcher:self.monitoringDispatcher]);
}

- (void)testStartImpression {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    NSNumber *itunesItemId = @1596467464;
    OGASKAdNetworkResponse *skAdResponse = OCMClassMock([OGASKAdNetworkResponse class]);
    OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(skAdResponse.sourceAppId).andReturn(@0);
    OCMStub(skAdResponse.itunesItemId).andReturn(itunesItemId);
    OCMStub(skAdResponse.signature).andReturn(@"MEUCID9mCqh55FNXQ+Kt7J1E2Up6pGRHY/wU/34TAM9lmdhoAiEAotIhmm+jaouZ57QkaoKS5Z7mchlQgWbSJvJhzaNq4fA=");
    OCMStub(skAdResponse.nonce).andReturn(@"44ca0ea1-98e4-4180-9193-d0259de38875");
    OCMStub(skAdResponse.version).andReturn(@"2.2");
    OCMStub(skAdResponse.networkIdentifier).andReturn(@"w7jznl3r6g.skadnetwork");
    OCMStub(skAdResponse.isStoreKitDisplay).andReturn(NO);
    OCMStub(skAdResponse.fidelity).andReturn(@1);
    OCMStub(skAdResponse.campaignId).andReturn(@89);
    OCMStub(skAdResponse.timestamp).andReturn(@1681992712);
    OCMStub(ad.skAdNetworkResponse).andReturn(skAdResponse);
    OCMStub(ad.adConfiguration).andReturn(adConfiguration);

    [self.sKAdNetworkManager startImpressionWithAd:ad];
    OCMVerify([self.monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventStartingImpression advertisedAppStoreItemIdentifier:itunesItemId adConfiguration:adConfiguration]);
    if (@available(iOS 14.5, *)) {
        XCTAssertNotNil(self.sKAdNetworkManager.impression);
    } else {
        OCMVerify([self.monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression advertisedAppStoreItemIdentifier:itunesItemId adConfiguration:adConfiguration]);
    }
}

- (void)testStartImpression_StoreKit_YES {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OGASKAdNetworkResponse *skAdResponse = OCMClassMock([OGASKAdNetworkResponse class]);
    OCMStub(skAdResponse.isStoreKitDisplay).andReturn(YES);
    OCMStub(ad.skAdNetworkResponse).andReturn(skAdResponse);
    OCMReject([self.monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventStartingImpression advertisedAppStoreItemIdentifier:[OCMArg any] adConfiguration:[OCMArg any]]);
    OCMReject([self.monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression advertisedAppStoreItemIdentifier:[OCMArg any] adConfiguration:[OCMArg any]]);
    [self.sKAdNetworkManager startImpressionWithAd:ad];
    if (@available(iOS 14.5, *)) {
        XCTAssertNil(self.sKAdNetworkManager.impression);
    }
}

- (void)testStartImpression_SkAdResponset_NO {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub(ad.skAdNetworkResponse).andReturn(nil);
    OCMReject([self.monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventIncompatibleIOSVersionToStartImpression advertisedAppStoreItemIdentifier:[OCMArg any] adConfiguration:[OCMArg any]]);
    OCMReject([self.monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventStartingImpression advertisedAppStoreItemIdentifier:[OCMArg any] adConfiguration:[OCMArg any]]);
    [self.sKAdNetworkManager startImpressionWithAd:ad];
    if (@available(iOS 14.5, *)) {
        XCTAssertNil(self.sKAdNetworkManager.impression);
    }
}

@end
