//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "NSDictionary+OGABase64.h"
#import "OGAAdConfiguration.h"
#import "OGAAdLoadStateManager.h"
#import "OGAAdParser.h"
#import "OGAAdPrivacyConfiguration.h"
#import "OGAMonitoringDispatcher.h"
#import "OguryError+utility.h"

NSString *const OGAAdParserAdAdUnitId = @"test-ad-unit";
NSString *const OGAAdParserConfigurationAdUnitId = @"interstitial";

@interface OGAAdParserTests : XCTestCase
@property(nonatomic, retain) OGAMonitoringDispatcher *monitoringDispatcher;
@end

@interface OGAAdParser (Testing)

+ (BOOL)shouldParseAd:(OGAAd *)ad withConfiguration:(OGAAdConfiguration *)adConfig error:(NSError **)error;

@end

@implementation OGAAdParserTests

- (void)setUp {
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
}

+ (NSDictionary *_Nullable)dataForJSONFileNamed:(NSString *)name {
    NSString *JSONfile = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"json"];
    NSData *JSONdata = [NSData dataWithContentsOfFile:JSONfile];
    return [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingAllowFragments error:nil];
}

- (void)testShouldReturnParsedAd {
    NSDictionary *adJSON = [OGAAdParserTests dataForJSONFileNamed:@"adResponse"];

    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                                        adUnitId:@""
                                                              delegateDispatcher:delegateDispatcher
                                                          viewControllerProvider:nil
                                                                    viewProvider:nil];
    NSError *error = nil;
    NSArray *ads = [OGAAdParser parseJSONResponse:adJSON
                                  adConfiguration:configuration
                             privacyConfiguration:[OCMArg any]
                                            error:&error
                             monitoringDispatcher:self.monitoringDispatcher];

    XCTAssertNotNil(ads);
    XCTAssertEqual(ads.count, 1);

    OGAAd *ad = ads.firstObject;

    XCTAssertTrue([ad.landingPagePrefetchURL isEqualToString:@"https://www.google.com"]);
    XCTAssertTrue(ad.disableLandingPageJavascript);
    XCTAssertTrue([ad.landingPagePrefetchWhitelist isEqualToString:@"wwww.google.com|bing.com|duckduckgo.com"]);
    XCTAssertTrue([[ad getRawLoadedSource] isEqualToString:@"format"]);
    XCTAssertEqual(ad.expirationTime.intValue, 1400);
}

- (void)testAdParser {
    NSString *adJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"fakeAdResponse" ofType:@"json"];
    NSData *adJsonData = [NSData dataWithContentsOfFile:adJson];
    NSDictionary *fakeAdResponse = [NSJSONSerialization JSONObjectWithData:adJsonData options:NSJSONReadingAllowFragments error:nil];
    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                                        adUnitId:@""
                                                              delegateDispatcher:delegateDispatcher
                                                          viewControllerProvider:nil
                                                                    viewProvider:nil];

    NSError *error = nil;
    NSArray *ads = [OGAAdParser parseJSONResponse:fakeAdResponse
                                  adConfiguration:configuration
                             privacyConfiguration:[OCMArg any]
                                            error:&error
                             monitoringDispatcher:self.monitoringDispatcher];

    XCTAssertNotNil(ads, "Ad is NULL");
    XCTAssert([ads count], "1");
}

- (void)testAdParserNil {
    NSError *error = nil;
    NSArray *ads = [OGAAdParser parseJSONResponse:nil
                                  adConfiguration:nil
                             privacyConfiguration:[OCMArg any]
                                            error:&error
                             monitoringDispatcher:self.monitoringDispatcher];
    XCTAssertEqual(ads.count, 0, "Should be 0 ads");
}

- (void)testAdEmpty {
    NSString *invalidJson = @"{}";
    NSData *adJsonData = [invalidJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *fakeAdResponse = [NSJSONSerialization JSONObjectWithData:adJsonData options:NSJSONReadingAllowFragments error:nil];
    NSError *error = nil;

    NSArray *ads = [OGAAdParser parseJSONResponse:fakeAdResponse
                                  adConfiguration:nil
                             privacyConfiguration:[OCMArg any]
                                            error:&error
                             monitoringDispatcher:self.monitoringDispatcher];

    XCTAssertEqual(ads.count, 0, "Should be 0 ads");
}

- (void)testIncompleteAd {
    NSString *adJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testIncompleteAd" ofType:@"json"];
    NSData *adJsonData = [NSData dataWithContentsOfFile:adJson];
    NSDictionary *fakeAdResponse = [NSJSONSerialization JSONObjectWithData:adJsonData options:NSJSONReadingAllowFragments error:nil];
    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                                        adUnitId:OGAAdParserConfigurationAdUnitId
                                                              delegateDispatcher:delegateDispatcher
                                                          viewControllerProvider:nil
                                                                    viewProvider:nil];
    NSError *error = nil;

    NSArray<OGAAd *> *ads = [OGAAdParser parseJSONResponse:fakeAdResponse
                                           adConfiguration:configuration
                                      privacyConfiguration:[OCMArg any]
                                                     error:&error
                                      monitoringDispatcher:self.monitoringDispatcher];

    XCTAssertEqual([ads count], 0);
}

- (void)testBadAd {
    NSString *adJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"badAdResponse" ofType:@"json"];
    NSData *adJsonData = [NSData dataWithContentsOfFile:adJson];
    NSDictionary *fakeAdResponse = [NSJSONSerialization JSONObjectWithData:adJsonData options:NSJSONReadingAllowFragments error:nil];
    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                                        adUnitId:OGAAdParserConfigurationAdUnitId
                                                              delegateDispatcher:delegateDispatcher
                                                          viewControllerProvider:nil
                                                                    viewProvider:nil];
    NSError *error = nil;

    NSArray<OGAAd *> *ads = [OGAAdParser parseJSONResponse:fakeAdResponse
                                           adConfiguration:configuration
                                      privacyConfiguration:[OCMArg any]
                                                     error:&error
                                      monitoringDispatcher:self.monitoringDispatcher];

    XCTAssertNotNil(ads, "Ads is not NULL");
    XCTAssertEqual([ads count], 0, "Not empty");
}

- (void)testAdParserParseParams {
    NSString *adJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testAdsOrientationParams" ofType:@"json"];
    NSData *adJsonData = [NSData dataWithContentsOfFile:adJson];
    NSDictionary *fakeAdResponse = [NSJSONSerialization JSONObjectWithData:adJsonData options:NSJSONReadingAllowFragments error:nil];
    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                                        adUnitId:OGAAdParserConfigurationAdUnitId
                                                              delegateDispatcher:delegateDispatcher
                                                          viewControllerProvider:nil
                                                                    viewProvider:nil];
    NSError *error = nil;

    NSArray *ads = [OGAAdParser parseJSONResponse:fakeAdResponse
                                  adConfiguration:configuration
                             privacyConfiguration:[OCMArg any]
                                            error:&error
                             monitoringDispatcher:self.monitoringDispatcher];

    XCTAssertNotNil(ads, "AD is NULL");
    XCTAssert([ads count], "1");
    OGAAd *ad = ads[0];
    XCTAssertNotNil(ad.orientation, "orientation field is empty");
}

- (void)testAdParserNoParseFormatParams {
    NSString *adJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"testAdsNoFormatParams" ofType:@"json"];
    NSData *adJsonData = [NSData dataWithContentsOfFile:adJson];
    NSDictionary *fakeAdResponse = [NSJSONSerialization JSONObjectWithData:adJsonData options:NSJSONReadingAllowFragments error:nil];
    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                                        adUnitId:OGAAdParserConfigurationAdUnitId
                                                              delegateDispatcher:delegateDispatcher
                                                          viewControllerProvider:nil
                                                                    viewProvider:nil];
    NSError *error = nil;

    NSArray *ads = [OGAAdParser parseJSONResponse:fakeAdResponse
                                  adConfiguration:configuration
                             privacyConfiguration:[OCMArg any]
                                            error:&error
                             monitoringDispatcher:self.monitoringDispatcher];

    XCTAssertNotNil(ads, "AD is NULL");
    XCTAssert([ads count], "1");
    OGAAd *ad = ads[0];
    XCTAssertNil(ad.adWebViewId, "ad webview id field is not empty");
}

- (void)testShouldParseAd {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.adUnit = [[OGAAdUnit alloc] init];
    ad.adUnit.identifier = OGAAdParserAdAdUnitId;
    ad.adUnit.type = OGAAdConfigurationAdTypeInterstitial;
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeInterstitial);
    NSError *error = nil;

    XCTAssertFalse([OGAAdParser shouldParseAd:ad withConfiguration:configuration error:&error]);
}

- (void)testShouldParseAd_skipAdWithoutAdIdentifier {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.adUnit = [[OGAAdUnit alloc] init];
    ad.adUnit.identifier = @"";
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    NSError *error = nil;

    XCTAssertFalse([OGAAdParser shouldParseAd:ad withConfiguration:configuration error:&error]);
}

- (void)testShouldParseAd_skipAdWithoutAdType {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.adUnit = [[OGAAdUnit alloc] init];
    ad.adUnit.identifier = OGAAdParserAdAdUnitId;
    ad.adUnit.type = @"";
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    NSError *error = nil;

    XCTAssertFalse([OGAAdParser shouldParseAd:ad withConfiguration:configuration error:&error]);
}

- (void)testShouldParseAd_skipAdIfAdTypeDoNotMatchConfiguration {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.adUnit = [[OGAAdUnit alloc] init];
    ad.adUnit.identifier = OGAAdParserAdAdUnitId;
    ad.adUnit.type = OGAAdConfigurationAdTypeThumbnailAd;
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    NSError *error = nil;
    OCMStub(configuration.adType).andReturn(OguryAdsTypeInterstitial);

    XCTAssertFalse([OGAAdParser shouldParseAd:ad withConfiguration:configuration error:&error]);
}

- (void)testParseJSONResponseadConfiguration {
    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                                        adUnitId:@""
                                                              delegateDispatcher:delegateDispatcher
                                                          viewControllerProvider:nil
                                                                    viewProvider:nil];
    OGAAdPrivacyConfiguration *privacyConfiguration = OCMClassMock([OGAAdPrivacyConfiguration class]);
    NSError *error = nil;
    NSDictionary *adJSON = [NSDictionary
        ogaDecodeFromBase64:
            @"ewoJImFkIjogW3sKCQkiYWRfY29udGVudCI6ICJcdTAwM2NodG1sXHUwMDNlICBcdTAwM2NoZWFkXHUwMDNlICBcdTAwM2NtZXRhIGNoYXJzZXQ9XCJVVEYtOFwiXHUwMDNlICBcdTAwM2NtZXRhIG5hbWU9XCJ2aWV3cG9ydFwiIGNvbnRlbnQ9XCJ3aWR0aD1kZXZpY2Utd2lkdGgsIGluaXRpYWwtc2NhbGU9MS4wLCB1c2VyLXNjYWxhYmxlPW5vXCJcdTAwM2UgIFx1MDAzY2xpbmsgcmVsPVwiaWNvblwiIHR5cGU9XCJpbWFnZS9wbmdcIiBocmVmPVwiZGF0YTppbWFnZS9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvPVwiXHUwMDNlICBcdTAwM2NzY3JpcHQgc3JjPVwiaHR0cHM6Ly9yZXNvdXJjZXMucHJlc2FnZS5pby92My45Mi42MC04MTVhOTNmNy9hc3NldHMvb21zZGstanMvb21zZGsuanNcIlx1MDAzZVx1MDAzYy9zY3JpcHRcdTAwM2UgIFx1MDAzYy9oZWFkXHUwMDNlICBcdTAwM2Nib2R5XHUwMDNlICBcdTAwM2NkaXYgaWQ9XCJyb290XCJcdTAwM2UgIFx1MDAzYy9kaXZcdTAwM2UgIFx1MDAzY3NjcmlwdCBzcmM9XCJtcmFpZC5qc1wiXHUwMDNlXHUwMDNjL3NjcmlwdFx1MDAzZSAgXHUwMDNjc2NyaXB0IHNyYz1cImh0dHBzOi8vbXMtYWRzLnByZXNhZ2UuaW8vbXJhaWQ/ZHNwPW9ndXJ5XHUwMDI2dD0xNjg5MDg2ODQ4XHUwMDI2aW1wPWExMjQ1OGU2LTkyYjQtNDkzYi1iZDk5LTRmZmVjMTJiYmQ1Mlx1MDAyNm9jX3V1aWQ9MjA0NmY5MjQtM2FlOS00Zjk0LTg4MWEtM2QyMGRkZDU0ZDFlXHUwMDI2YWs9MzEzMDc2XHUwMDI2dV9pZD0wMDAwMDAwMC0wMDAwLTAwMDAtMDAwMC0wMDAwMDAwMDAwMDBcdTAwMjZhX3Nkaz0zLjUuMFx1MDAyNmF1aWQ9MzEzMDc2X2RlZmF1bHRcdTAwMjZjb25uPVx1MDAyNnVfb3M9aW9zXHUwMDI2YV9iPWNvLm9ndXJ5LlRlc3QtQXBwbGljYXRpb25cdTAwMjZhX249VGVzdCtBcHBsaWNhdGlvbitBZHNcdTAwMjZhdXR5cGU9aW50ZXJzdGl0aWFsXHUwMDI2YV9leD1vZ3VyeVx1MDAyNmJpZF9oYXNoPVx1MDAyNmRtbj1cdTAwMjZwZz1cdTAwMjZkX209YXJtNjRcdTAwMjZkX3R5PW1vYmlsZVx1MDAyNnVfdGs9ODNkMjA5ZjItMDU4ZS00MzA1LTg3MTAtNzE3YzNiZTYyN2E1XHUwMDI2YXVkPVx1MDAyNmR1YWxhZD1cdTAwMjZnPVx1MDAyNmNfcz1cdTAwMjZjcl9pZD02NjIwMlx1MDAyNmFkX29iPWV5SmhiR2NpT2lKSVV6STFOaUlzSW5SNWNDSTZJa3BYVkNKOS5leUpoWkhabGNuUmZhV1FpT2lKaE1USTBOVGhsTmkwNU1tSTBMVFE1TTJJdFltUTVPUzAwWm1abFl6RXlZbUprTlRJaUxDSmhaSFpsY25ScGMyVnlYMkpwWkY5d2NtbGpaU0k2TUN3aVlXUjJaWEowYVhObGNsOWtiMjFoYVc0aU9pSWlMQ0ppYVdSZmNISnBZMlVpT2pBc0ltOWthV1FpT2lJMU5XVTJOekE0TXkxaE0yWXpMVFE1TVRndFlqTXlaaTB6WkRVNFpUQTRabVV6WmpJaUxDSnlaV2RwYjI0aU9pSmxkUzEzWlhOMExURWlMQ0p6WldGMElqb2lJbjAuaGhIdWw1clE0amVqRXFXVVJrbDU3U3pVVk1qdDNWTXFRSERKclFLVDVfVVx1MDAyNmNoX3BhPWZhbHNlXHUwMDI2cD1kYyUyQ29pJTJDc2ElMkNzZFx1MDAyNnVfY3Q9Mzg1OTUzZTEtNDY5ZS00ODVmLTgxY2MtNWVhZWZiNjhiMzk3XHUwMDI2c19pZD04MWQ1YThmOGUyNjFjNzRhNTE1ZmUwNDYwNzIwNjBmN1x1MDAyNnNrYW49ZmFsc2VcIlx1MDAzZVx1MDAzYy9zY3JpcHRcdTAwM2UgIFx1MDAzYy9ib2R5XHUwMDNlICBcdTAwM2MvaHRtbFx1MDAzZSIsCgkJImFkX2NvbnRlbnRfdXJsIjogImh0dHBzOi8vbXMtYWRzLnByZXNhZ2UuaW8vbXJhaWQ/ZHNwPW9ndXJ5XHUwMDI2dD0xNjg5MDg2ODQ4XHUwMDI2aW1wPWExMjQ1OGU2LTkyYjQtNDkzYi1iZDk5LTRmZmVjMTJiYmQ1Mlx1MDAyNm9jX3V1aWQ9MjA0NmY5MjQtM2FlOS00Zjk0LTg4MWEtM2QyMGRkZDU0ZDFlXHUwMDI2YWs9MzEzMDc2XHUwMDI2dV9pZD0wMDAwMDAwMC0wMDAwLTAwMDAtMDAwMC0wMDAwMDAwMDAwMDBcdTAwMjZhX3Nkaz0zLjUuMFx1MDAyNmF1aWQ9MzEzMDc2X2RlZmF1bHRcdTAwMjZjb25uPVx1MDAyNnVfb3M9aW9zXHUwMDI2YV9iPWNvLm9ndXJ5LlRlc3QtQXBwbGljYXRpb25cdTAwMjZhX249VGVzdCtBcHBsaWNhdGlvbitBZHNcdTAwMjZhdXR5cGU9aW50ZXJzdGl0aWFsXHUwMDI2YV9leD1vZ3VyeVx1MDAyNmJpZF9oYXNoPVx1MDAyNmRtbj1cdTAwMjZwZz1cdTAwMjZkX209YXJtNjRcdTAwMjZkX3R5PW1vYmlsZVx1MDAyNnVfdGs9ODNkMjA5ZjItMDU4ZS00MzA1LTg3MTAtNzE3YzNiZTYyN2E1XHUwMDI2YXVkPVx1MDAyNmR1YWxhZD1cdTAwMjZnPVx1MDAyNmNfcz1cdTAwMjZjcl9pZD02NjIwMlx1MDAyNmFkX29iPWV5SmhiR2NpT2lKSVV6STFOaUlzSW5SNWNDSTZJa3BYVkNKOS5leUpoWkhabGNuUmZhV1FpT2lKaE1USTBOVGhsTmkwNU1tSTBMVFE1TTJJdFltUTVPUzAwWm1abFl6RXlZbUprTlRJaUxDSmhaSFpsY25ScGMyVnlYMkpwWkY5d2NtbGpaU0k2TUN3aVlXUjJaWEowYVhObGNsOWtiMjFoYVc0aU9pSWlMQ0ppYVdSZmNISnBZMlVpT2pBc0ltOWthV1FpT2lJMU5XVTJOekE0TXkxaE0yWXpMVFE1TVRndFlqTXlaaTB6WkRVNFpUQTRabVV6WmpJaUxDSnlaV2RwYjI0aU9pSmxkUzEzWlhOMExURWlMQ0p6WldGMElqb2lJbjAuaGhIdWw1clE0amVqRXFXVVJrbDU3U3pVVk1qdDNWTXFRSERKclFLVDVfVVx1MDAyNmNoX3BhPWZhbHNlXHUwMDI2cD1kYyUyQ29pJTJDc2ElMkNzZFx1MDAyNnVfY3Q9Mzg1OTUzZTEtNDY5ZS00ODVmLTgxY2MtNWVhZWZiNjhiMzk3XHUwMDI2c19pZD04MWQ1YThmOGUyNjFjNzRhNTE1ZmUwNDYwNzIwNjBmN1x1MDAyNnNrYW49ZmFsc2VcdTAwMjZ0X2E9dHJ1ZSIsCgkJImFkX2tlZXBfYWxpdmUiOiBmYWxzZSwKCQkiY2FjaGUiIDogewoJCQkiYWRfZXhwaXJhdGlvbiIgOiAxMDAwCgkJfSwKCQkiYWRfdW5pdCI6IHsKCQkJImFwcF91c2VyX2lkIjogIiIsCgkJCSJpZCI6ICIzMTMwNzZfZGVmYXVsdCIsCgkJCSJyZXdhcmRfbGF1bmNoIjogIiIsCgkJCSJyZXdhcmRfbmFtZSI6ICIiLAoJCQkicmV3YXJkX3ZhbHVlIjogIiIsCgkJCSJ0eXBlIjogImludGVyc3RpdGlhbCIKCQl9LAoJCSJhZHZlcnRpc2VyIjogewoJCQkiaWQiOiAiMSIKCQl9LAoJCSJiYW5uZXIiOiB7CgkJCSJhdXRvX3JlZnJlc2giOiBmYWxzZSwKCQkJImF1dG9fcmVmcmVzaF9yYXRlIjogMCwKCQkJImZ1bGxfd2lkdGgiOiBmYWxzZQoJCX0sCgkJImNhbXBhaWduX2lkIjogIjEzIiwKCQkiY3JlYXRpdmVfaWQiOiAiMTUwMCIsCgkJImNsaWVudF90cmFja2VyX3BhdHRlcm4iOiAiIiwKCQkiZm9ybWF0IjogewoJCQkiZGVsYXlfZm9yX3NlbmRpbmdfbG9hZGVkIjogNCwKCQkJImxhdW5jaF9vbWlkX2xvYWQiOiBmYWxzZSwKCQkJIm1yYWlkX2Rvd25sb2FkX3VybCI6ICJodHRwczovL21yYWlkLnByZXNhZ2UuaW8vYTJhZDlmMS9tcmFpZC5qcyIsCgkJCSJ3ZWJ2aWV3X2Jhc2VfdXJsIjogImh0dHBzOi8vd3d3Lm9neWZtdHMuY29tLyIKCQl9LAoJCSJleHRyYXMiOiBbewoJCQkibmFtZSI6ICJkc3AiLAoJCQkidmFsdWUiOiAie1wiY3JlYXRpdmVfaWRcIjogXCIxMjNcIiwgXCJyZWdpb25cIjpcImVhc3QtdXNcIn0iLAoJCQkidmVyc2lvbiI6IDIKCQl9LHsKCQkJIm5hbWUiOiAidmFzdF92ZXJzaW9uIiwKCQkJInZhbHVlIjogIjQuMCIsCgkJCSJ2ZXJzaW9uIjogMQoJCX1dLAoJCSJoYXNfdHJhbnNwYXJlbmN5IjogZmFsc2UsCgkJImlkIjogImExMjQ1OGU2LTkyYjQtNDkzYi1iZDk5LTRmZmVjMTJiYmQ1MiIsCgkJImltcHJlc3Npb25fdXJsIjogIiIsCgkJImlzX2ltcHJlc3Npb24iOiB0cnVlLAoJCSJpc192aWRlbyI6IGZhbHNlLAoJCSJsYW5kaW5nX3BhZ2VfZGlzYWJsZV9qYXZhc2NyaXB0IjogZmFsc2UsCgkJImxhbmRpbmdfcGFnZV9wcmVmZXRjaF91cmwiOiAiIiwKCQkibGFuZGluZ19wYWdlX3ByZWZldGNoX3doaXRlbGlzdCI6ICIiLAoJCSJsb2FkZWRfc291cmNlIjogImZvcm1hdCIsCgkJIm1vYXRFbmFibGVkIjogZmFsc2UsCgkJIm9taWQiOiB0cnVlLAoJCSJvdmVybGF5IjogewoJCQkiZGlzYWJsZV9tdWx0aV9hY3Rpdml0eSI6IDAsCgkJCSJkcmFnZ2FibGUiOiBmYWxzZSwKCQkJImluaXRpYWxfc2l6ZSI6IHt9CgkJfSwKCQkic2RrX2Nsb3NlX2J1dHRvbl91cmwiOiAiaHR0cHM6Ly9tcy1hZHMtZXZlbnRzLnByZXNhZ2UuaW8vY3JlYXRpdmU/ZT1zZGtfY2xvc2VfYnV0dG9uXHUwMDI2aW1wPWExMjQ1OGU2LTkyYjQtNDkzYi1iZDk5LTRmZmVjMTJiYmQ1Mlx1MDAyNm9jX2lkPTEyNDkzNlx1MDAyNmFrPTMxMzA3Nlx1MDAyNnVfaWQ9MDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwXHUwMDI2YV9zZGs9My41LjBcdTAwMjZ1X29zPWlvc1x1MDAyNmFfYj1jby5vZ3VyeS5UZXN0LUFwcGxpY2F0aW9uXHUwMDI2YV9uPVRlc3QrQXBwbGljYXRpb24rQWRzXHUwMDI2Y3JfaWQ9NjYyMDJcdTAwMjZ0X2E9dHJ1ZSIKCX1dCn0="
                      error:&error];
    NSArray<NSDictionary *> *adsJSON = adJSON[@"ad"];
    OGAAd *ad = [OGAAdParser parseAdJSON:adsJSON[0]
                         adConfiguration:configuration
                    privacyConfiguration:privacyConfiguration
                                   error:&error
                    monitoringDispatcher:self.monitoringDispatcher];
    XCTAssertNotNil(ad);
    XCTAssertTrue([ad.identifier isEqualToString:@"a12458e6-92b4-493b-bd99-4ffec12bbd52"]);
    XCTAssertTrue([ad.adConfiguration.campaignId isEqualToString:@"13"]);
    XCTAssertTrue([ad.adConfiguration.creativeId isEqualToString:@"1500"]);
    XCTAssertEqual([ad.adConfiguration.extras count], 2);
    NSDictionary *firstDictionnary = @{@"name" : @"dsp", @"value" : @"{\"creative_id\": \"123\", \"region\":\"east-us\"}", @"version" : @2};
    NSDictionary *secondDictionnary = @{@"name" : @"vast_version", @"value" : @"4.0", @"version" : @1};
    NSArray *expectedArray = @[ firstDictionnary, secondDictionnary ];
    XCTAssertEqualObjects(ad.adConfiguration.extras, expectedArray);
    XCTAssertEqual(ad.privacyConfiguration, privacyConfiguration);
}

- (void)testWhenAdUnitIsEmptyThenMonitoringTrackShouldBeSent {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.adUnit = [[OGAAdUnit alloc] init];
    ad.adUnit.identifier = OGAAdParserAdAdUnitId;
    ad.adUnit.type = @"";
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    NSError *error = nil;
    [OGAAdParser shouldParseAd:ad withConfiguration:configuration error:&error];
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.localizedDescription, @"The ad could not be loaded due to a failure in parsing (No adUnit on Ad object)");
    XCTAssertEqual(error.code, OguryLoadErrorCodeAdParsingFailed);
}

- (void)testWhenThereIsATypeMismatchThenMonitoringTrackShouldBeSent {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.adUnit = [[OGAAdUnit alloc] init];
    ad.adUnit.identifier = OGAAdParserAdAdUnitId;
    ad.adUnit.type = OGAAdConfigurationAdTypeThumbnailAd;
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeInterstitial);
    OCMStub([configuration getAdTypeString]).andReturn(@"interstitial");
    NSError *error = nil;
    [OGAAdParser shouldParseAd:ad withConfiguration:configuration error:&error];
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.localizedDescription, @"The ad could not be loaded due to a failure in parsing (Type mismatch. Awaited (interstitial) - received (overlay_thumbnail))");
    XCTAssertEqual(error.code, OguryLoadErrorCodeAdParsingFailed);
}

- (void)testWhenAdIsParsedThenProperMonitoringTracksAreSent {
    NSString *adJson = [[NSBundle bundleForClass:[self class]] pathForResource:@"fakeAdResponse" ofType:@"json"];
    NSData *adJsonData = [NSData dataWithContentsOfFile:adJson];
    NSDictionary *fakeAdResponse = [NSJSONSerialization JSONObjectWithData:adJsonData options:NSJSONReadingAllowFragments error:nil];
    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    OGAAdConfiguration *configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial
                                                                        adUnitId:@""
                                                              delegateDispatcher:delegateDispatcher
                                                          viewControllerProvider:nil
                                                                    viewProvider:nil];

    NSError *error = nil;
    [OGAAdParser parseJSONResponse:fakeAdResponse
                   adConfiguration:configuration
              privacyConfiguration:[OCMArg any]
                             error:&error
              monitoringDispatcher:self.monitoringDispatcher];
    OCMVerify([self.monitoringDispatcher sendLoadEvent:OGALoadEventAdParseEnded adConfiguration:[OCMArg any]]);
}

@end
