//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGASKAdNetworkService.h"
#import <OCMock/OCMock.h>
#import "OGAMonitoringDispatcher+SKNetwork.h"
#import "OGAAdConfiguration.h"
#import <StoreKitTest/StoreKitTest.h>

@interface OGASKAdNetworkService (Test)

+ (NSArray *)getInfoAdNetworkItems;

@end

@interface OGASKAdNetworkServiceTest : XCTestCase

@property(nonatomic, strong) id skAdNetworkService;

@end

@implementation OGASKAdNetworkServiceTest

- (void)setUp {
    self.skAdNetworkService = OCMClassMock([OGASKAdNetworkService class]);
}

- (void)testIsSDKCompatibleWithSKAdNetwork {
    OCMStub(ClassMethod([self.skAdNetworkService getSKAdNetworkVersion])).andReturn(@"3.0");
    OCMStub(ClassMethod([self.skAdNetworkService getInfoAdNetworkItems])).andReturn(@[ @"w7jznl3r6g.skadnetwork" ]);

    XCTAssertTrue([OGASKAdNetworkService sdkIsCompatibleWithSKAdNetwork]);
}

- (void)testGetInfoAdNetworkItemsEmptyArray {
    id mainBundleMock = OCMPartialMock([NSBundle mainBundle]);
    id networkList = @[];
    OCMStub([mainBundleMock objectForInfoDictionaryKey:@"SKAdNetworkItems"]).andReturn(networkList);
    XCTAssertEqualObjects(@[], [OGASKAdNetworkService getInfoAdNetworkItems]);
}

- (void)testGetInfoAdNetworkItemsBadlyFormated {
    id mainBundleMock = OCMPartialMock([NSBundle mainBundle]);
    id networkList = @[ @{} ];
    OCMStub([mainBundleMock objectForInfoDictionaryKey:@"SKAdNetworkItems"]).andReturn(networkList);
    XCTAssertEqualObjects(@[], [OGASKAdNetworkService getInfoAdNetworkItems]);
}

- (void)testGetInfoAdNetworkItemsPartiallyBadlyFormated {
    id mainBundleMock = OCMPartialMock([NSBundle mainBundle]);
    id networkList = @[ @{}, @{@"SKAdNetworkIdentifier" : @"4fzdc2evr5.skadnetwork"} ];
    OCMStub([mainBundleMock objectForInfoDictionaryKey:@"SKAdNetworkItems"]).andReturn(networkList);
    XCTAssertEqualObjects(@[ @"4fzdc2evr5.skadnetwork" ], [OGASKAdNetworkService getInfoAdNetworkItems]);
}

- (void)testGetInfoAdNetworkItemsPartiallyBadlyFormatedWithOtherType {
    id mainBundleMock = OCMPartialMock([NSBundle mainBundle]);
    id networkList = @[ @{}, @{@"SKAdNetworkIdentifier" : @"4fzdc2evr5.skadnetwork"}, @"string" ];
    OCMStub([mainBundleMock objectForInfoDictionaryKey:@"SKAdNetworkItems"]).andReturn(networkList);
    XCTAssertEqualObjects(@[ @"4fzdc2evr5.skadnetwork" ], [OGASKAdNetworkService getInfoAdNetworkItems]);
}

- (void)testGetInfoAdNetworkItemsPartiallyBadlyFormatedWithBadDictionnary {
    id mainBundleMock = OCMPartialMock([NSBundle mainBundle]);
    id networkList = @[ @{}, @{@"NotASKAdNetworkIdentifier" : @"4fzdc2evr5.skadnetwork"}, @"string" ];
    OCMStub([mainBundleMock objectForInfoDictionaryKey:@"SKAdNetworkItems"]).andReturn(networkList);
    XCTAssertEqualObjects(@[], [OGASKAdNetworkService getInfoAdNetworkItems]);
}

- (void)testIsSDKCompatibleWithSKAdNetworkVersion4 {
    OCMStub(ClassMethod([self.skAdNetworkService getSKAdNetworkVersion])).andReturn(@"4.0");
    OCMStub(ClassMethod([self.skAdNetworkService getInfoAdNetworkItems])).andReturn(@[ @"w7jznl3r6g.skadnetwork" ]);

    XCTAssertTrue([OGASKAdNetworkService sdkIsCompatibleWithSKAdNetwork]);
}

- (void)testIsSDKCompatibleWithSKAdNetworkFailedDueToVersion {
    OCMStub(ClassMethod([self.skAdNetworkService getSKAdNetworkVersion])).andReturn(@"2.0");
    OCMStub(ClassMethod([self.skAdNetworkService getInfoAdNetworkItems])).andReturn(@[ @{@"SKAdNetworkIdentifier" : @"w7jznl3r6g.skadnetwork"} ]);
    XCTAssertFalse([OGASKAdNetworkService sdkIsCompatibleWithSKAdNetwork]);
}

- (void)testIsSDKCompatibleWithSKAdNetworkFailedDueToVersion2 {
    OCMStub(ClassMethod([self.skAdNetworkService getSKAdNetworkVersion])).andReturn(@"2.1");
    OCMStub(ClassMethod([self.skAdNetworkService getInfoAdNetworkItems])).andReturn(@[ @"w7jznl3r6g.skadnetwork" ]);
    XCTAssertFalse([OGASKAdNetworkService sdkIsCompatibleWithSKAdNetwork]);
}

- (void)testIsSDKCompatibleWithSKAdNetworkFailedDueToVersion3 {
    OCMStub(ClassMethod([self.skAdNetworkService getSKAdNetworkVersion])).andReturn(@"1.0");
    OCMStub(ClassMethod([self.skAdNetworkService getInfoAdNetworkItems])).andReturn(@[ @{@"SKAdNetworkIdentifier" : @"w7jznl3r6g.skadnetwork"} ]);
    XCTAssertFalse([OGASKAdNetworkService sdkIsCompatibleWithSKAdNetwork]);
}

- (void)testCreateImpression {
    OCMStub(ClassMethod([self.skAdNetworkService getSKAdNetworkVersion])).andReturn(@"3.0");

    if (@available(iOS 14.5, *)) {
        SKAdImpression *impression = [OGASKAdNetworkService createImpression:@"signature"
                                                sourceAppStoreItemIdentifier:@132465
                                            advertisedAppStoreItemIdentifier:@124578
                                                        adCampaignIdentifier:@45
                                                            sourceIdentifier:@10
                                                         adNetworkIdentifier:@"132456.skadnetwork"
                                                                     version:@"2.2"
                                                      adImpressionIdentifier:@"identifierString"
                                                                   timestamp:@1666715001];
        XCTAssertTrue([impression.signature isEqualToString:@"signature"]);
        XCTAssertTrue([impression.adImpressionIdentifier isEqualToString:@"identifierString"]);
        XCTAssertTrue([impression.adNetworkIdentifier isEqualToString:@"132456.skadnetwork"]);
        XCTAssertTrue([impression.version isEqualToString:@"2.2"]);
        XCTAssertEqual(impression.sourceAppStoreItemIdentifier, @(132465));
        XCTAssertEqual(impression.adCampaignIdentifier, @(45));
        XCTAssertEqual(impression.timestamp, @(1666715001));
        XCTAssertEqual(impression.advertisedAppStoreItemIdentifier, @(124578));

        if (@available(iOS 16.0, *)) {
            XCTAssertEqualObjects(impression.sourceIdentifier, @10);
        }
    }
}

- (void)testStartImpression_OK {
    if (@available(iOS 14.5, *)) {
        id sKAdNetwork = OCMClassMock([SKAdNetwork class]);
        SKAdImpression *impression = OCMClassMock([SKAdImpression class]);
        NSNumber *advertisedAppStoreItemIdentifier = @123456;
        OCMStub(impression.advertisedAppStoreItemIdentifier).andReturn(advertisedAppStoreItemIdentifier);
        OGAMonitoringDispatcher *monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
        OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
        OCMStub(ClassMethod([sKAdNetwork startImpression:impression completionHandler:([OCMArg invokeBlockWithArgs:[NSNull null], nil])]));
        OCMReject([monitoringDispatcher sendSKNetworkFailedImpressionEvent:OGASKNetworkShowErrorEventFailedToStartImpression advertisedAppStoreItemIdentifier:[OCMArg any] adConfiguration:[OCMArg any]]);
        [OGASKAdNetworkService startImpression:impression monitoringDispatcher:monitoringDispatcher adConfiguration:adConfiguration];
        OCMVerify([monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventStartImpression advertisedAppStoreItemIdentifier:advertisedAppStoreItemIdentifier adConfiguration:adConfiguration]);
    }
}

- (void)testStartImpression_KO {
    if (@available(iOS 14.5, *)) {
        NSError *error = OCMClassMock([NSError class]);
        id sKAdNetwork = OCMClassMock([SKAdNetwork class]);
        SKAdImpression *impression = OCMClassMock([SKAdImpression class]);
        NSNumber *advertisedAppStoreItemIdentifier = @123456;
        OCMStub(impression.advertisedAppStoreItemIdentifier).andReturn(advertisedAppStoreItemIdentifier);
        OGAMonitoringDispatcher *monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
        OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
        OCMStub(ClassMethod([sKAdNetwork startImpression:impression completionHandler:([OCMArg invokeBlockWithArgs:error, nil])]));
        OCMReject([monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventStopImpression advertisedAppStoreItemIdentifier:[OCMArg any] adConfiguration:[OCMArg any]]);
        [OGASKAdNetworkService startImpression:impression monitoringDispatcher:monitoringDispatcher adConfiguration:adConfiguration];
        OCMVerify([monitoringDispatcher sendSKNetworkFailedImpressionEvent:OGASKNetworkShowErrorEventFailedToStartImpression advertisedAppStoreItemIdentifier:advertisedAppStoreItemIdentifier adConfiguration:adConfiguration]);
    }
}

- (void)testStopImpression_OK {
    if (@available(iOS 14.5, *)) {
        id sKAdNetwork = OCMClassMock([SKAdNetwork class]);
        SKAdImpression *impression = OCMClassMock([SKAdImpression class]);
        NSNumber *advertisedAppStoreItemIdentifier = @123456;
        OCMStub(impression.advertisedAppStoreItemIdentifier).andReturn(advertisedAppStoreItemIdentifier);
        OGAMonitoringDispatcher *monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
        OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
        OCMStub(ClassMethod([sKAdNetwork endImpression:impression completionHandler:([OCMArg invokeBlockWithArgs:[NSNull null], nil])]));
        OCMReject([monitoringDispatcher sendSKNetworkFailedImpressionEvent:OGASKNetworkShowErrorEventFailedToStopImpression advertisedAppStoreItemIdentifier:[OCMArg any] adConfiguration:[OCMArg any]]);
        [OGASKAdNetworkService endImpression:impression monitoringDispatcher:monitoringDispatcher adConfiguration:adConfiguration];
        OCMVerify([monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventStopImpression advertisedAppStoreItemIdentifier:advertisedAppStoreItemIdentifier adConfiguration:adConfiguration]);
    }
}

- (void)testStopImpression_KO {
    if (@available(iOS 14.5, *)) {
        NSError *error = OCMClassMock([NSError class]);
        id sKAdNetwork = OCMClassMock([SKAdNetwork class]);
        NSNumber *advertisedAppStoreItemIdentifier = @123456;
        SKAdImpression *impression = OCMClassMock([SKAdImpression class]);
        OCMStub(impression.advertisedAppStoreItemIdentifier).andReturn(advertisedAppStoreItemIdentifier);
        OGAMonitoringDispatcher *monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
        OGAAdConfiguration *adConfiguration = OCMClassMock([OGAAdConfiguration class]);
        OCMStub(ClassMethod([sKAdNetwork endImpression:impression completionHandler:([OCMArg invokeBlockWithArgs:error, nil])]));
        OCMReject([monitoringDispatcher sendSKNetworkImpressionEvent:OGASKNetworkShowEventStopImpression advertisedAppStoreItemIdentifier:[OCMArg any] adConfiguration:[OCMArg any]]);
        [OGASKAdNetworkService endImpression:impression monitoringDispatcher:monitoringDispatcher adConfiguration:adConfiguration];
        OCMVerify([monitoringDispatcher sendSKNetworkFailedImpressionEvent:OGASKNetworkShowErrorEventFailedToStopImpression advertisedAppStoreItemIdentifier:advertisedAppStoreItemIdentifier adConfiguration:adConfiguration]);
    }
}

- (void)testSKParameterFromSKAdResponse {
    if (@available(iOS 14.0, *)) {
        OGASKAdNetworkResponse *response = [[OGASKAdNetworkResponse alloc] initWithDictionary:@{@"campaign_id" : @98,
                                                                                                @"itunes_item_id" : @1596467464,
                                                                                                @"ad_impression_identifier" : @"e007b571-b367-4251-82cc-069c27b845c5",
                                                                                                @"source_app_id" : @1596467469,
                                                                                                @"timestamp" : @1673539341,
                                                                                                @"signature" : @"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg==",
                                                                                                @"fidelity_type" : @1,
                                                                                                @"store_kit_display" : @true,
                                                                                                @"version" : @"2.2",
                                                                                                @"network_identifier" : @"w7jznl3r6g.skadnetwork",
                                                                                                @"source_identifier" : @99}
                                                                                        error:NULL];

        NSDictionary *dict = [OGASKAdNetworkService getSKParameterFrom:response];
        if (@available(iOS 16.1, *)) {
            XCTAssertEqual(dict.count, 9);
        } else {
            XCTAssertEqual(dict.count, 8);
        }
        XCTAssertTrue([dict[SKStoreProductParameterITunesItemIdentifier] isEqualToString:@"1596467464"]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkVersion] isEqualToString:@"2.2"]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] isEqualToString:@"1596467469"]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkAttributionSignature] isEqualToString:@"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkTimestamp] isEqualToString:@"1673539341"]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkIdentifier] isEqualToString:@"w7jznl3r6g.skadnetwork"]);
        XCTAssertTrue([((NSUUID *)dict[SKStoreProductParameterAdNetworkNonce]).UUIDString isEqualToString:@"E007B571-B367-4251-82CC-069C27B845C5"]);
        if (@available(iOS 16.1, *)) {
            XCTAssertEqual(dict[SKStoreProductParameterAdNetworkSourceIdentifier], @99);
        }
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkCampaignIdentifier] isEqualToString:@"98"]);
    }
}

- (void)testSKParameterFromSKAdResponseWithNoSourceId {
    if (@available(iOS 14.0, *)) {
        OGASKAdNetworkResponse *response = [[OGASKAdNetworkResponse alloc] initWithDictionary:@{@"campaign_id" : @98,
                                                                                                @"itunes_item_id" : @1596467464,
                                                                                                @"ad_impression_identifier" : @"e007b571-b367-4251-82cc-069c27b845c5",
                                                                                                @"source_app_id" : @1596467469,
                                                                                                @"timestamp" : @1673539341,
                                                                                                @"signature" : @"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg==",
                                                                                                @"fidelity_type" : @1,
                                                                                                @"store_kit_display" : @true,
                                                                                                @"version" : @"2.2",
                                                                                                @"network_identifier" : @"w7jznl3r6g.skadnetwork"}
                                                                                        error:NULL];

        NSDictionary *dict = [OGASKAdNetworkService getSKParameterFrom:response];
        XCTAssertEqual(dict.count, 8);
        XCTAssertTrue([dict[SKStoreProductParameterITunesItemIdentifier] isEqualToString:@"1596467464"]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkVersion] isEqualToString:@"2.2"]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] isEqualToString:@"1596467469"]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkAttributionSignature] isEqualToString:@"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkTimestamp] isEqualToString:@"1673539341"]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkIdentifier] isEqualToString:@"w7jznl3r6g.skadnetwork"]);
        XCTAssertTrue([((NSUUID *)dict[SKStoreProductParameterAdNetworkNonce]).UUIDString isEqualToString:@"E007B571-B367-4251-82CC-069C27B845C5"]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkCampaignIdentifier] isEqualToString:@"98"]);
    }
}

- (void)testSKParameterFromSKAdResponseWithNoCampaign {
    if (@available(iOS 16.1, *)) {
        OGASKAdNetworkResponse *response = [[OGASKAdNetworkResponse alloc] initWithDictionary:@{
            @"itunes_item_id" : @1596467464,
            @"ad_impression_identifier" : @"e007b571-b367-4251-82cc-069c27b845c5",
            @"source_app_id" : @1596467469,
            @"timestamp" : @1673539341,
            @"signature" : @"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg==",
            @"fidelity_type" : @1,
            @"store_kit_display" : @true,
            @"version" : @"2.2",
            @"network_identifier" : @"w7jznl3r6g.skadnetwork",
            @"source_identifier" : @99
        }
                                                                                        error:NULL];

        NSDictionary *dict = [OGASKAdNetworkService getSKParameterFrom:response];
        XCTAssertEqual(dict.count, 8);
        XCTAssertTrue([dict[SKStoreProductParameterITunesItemIdentifier] isEqualToString:@"1596467464"]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkVersion] isEqualToString:@"2.2"]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] isEqualToString:@"1596467469"]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkAttributionSignature] isEqualToString:@"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkTimestamp] isEqualToString:@"1673539341"]);
        XCTAssertTrue([dict[SKStoreProductParameterAdNetworkIdentifier] isEqualToString:@"w7jznl3r6g.skadnetwork"]);
        XCTAssertTrue([((NSUUID *)dict[SKStoreProductParameterAdNetworkNonce]).UUIDString isEqualToString:@"E007B571-B367-4251-82CC-069C27B845C5"]);
        XCTAssertEqual(dict[SKStoreProductParameterAdNetworkSourceIdentifier], @99);
    }
}

- (void)testSKParameterFromSKAdResponseWithWrong {
    if (@available(iOS 14.0, *)) {
        OGASKAdNetworkResponse *response = [[OGASKAdNetworkResponse alloc] initWithDictionary:@{@"campaign_id" : @98,
                                                                                                @"itunes_item_id" : @1596467464,
                                                                                                @"ad_impression_identifier" : @"e007b571-b367-4251-82cc-069c27b845c5",
                                                                                                @"source_app_id" : @1596467469,
                                                                                                @"signature" : @"MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg==",
                                                                                                @"fidelity_type" : @1,
                                                                                                @"store_kit_display" : @true,
                                                                                                @"version" : @"2.2",
                                                                                                @"network_identifier" : @"w7jznl3r6g.skadnetwork"}
                                                                                        error:NULL];

        NSDictionary *dict = [OGASKAdNetworkService getSKParameterFrom:response];
        XCTAssertEqual(dict.count, 0);
    }
}

- (void)testSKParameterValidWithSignature {
    OGASKAdNetworkResponse *skAdResponse = OCMClassMock([OGASKAdNetworkResponse class]);

    OCMStub(skAdResponse.sourceAppId).andReturn(@0);
    OCMStub(skAdResponse.itunesItemId).andReturn(@1596467464);
    OCMStub(skAdResponse.signature).andReturn(@"MEQCIBQA0kEuLF7bUJyY3sJ2WNgfQInCLWmctwJq5speR8q4AiADjWBpadjcTNhzjoWKUo+fFjWVD2QS0z3saAX7pG0r0A==");
    OCMStub(skAdResponse.nonce).andReturn(@"b5d81675-26f5-41c0-ab92-fdfdc540465c");
    OCMStub(skAdResponse.version).andReturn(@"2.2");
    OCMStub(skAdResponse.networkIdentifier).andReturn(@"w7jznl3r6g.skadnetwork");
    OCMStub(skAdResponse.isStoreKitDisplay).andReturn(NO);
    OCMStub(skAdResponse.fidelity).andReturn(@1);
    OCMStub(skAdResponse.campaignId).andReturn(@89);
    OCMStub(skAdResponse.timestamp).andReturn(@1682001371);

    NSError *error = [[NSError alloc] init];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"ogury_skadnetwork_public_key"
                                      ofType:@"pem"];

    NSString *content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];

    NSString *startPublicKey = @"-----BEGIN PUBLIC KEY-----";
    NSString *endPublicKey = @"-----END PUBLIC KEY-----";

    NSString *publicKey;
    NSScanner *scanner = [NSScanner scannerWithString:content];
    [scanner scanUpToString:startPublicKey intoString:nil];
    [scanner scanString:startPublicKey intoString:nil];
    [scanner scanUpToString:endPublicKey intoString:&publicKey];

    publicKey = [publicKey stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    if (@available(iOS 15.4, *)) {
        BOOL success = [[[SKAdTestSession alloc] init] validateImpressionWithParameters:[OGASKAdNetworkService getSKParameterFrom:skAdResponse] publicKey:publicKey error:&error];

        XCTAssertTrue(success);
    }
}

@end
