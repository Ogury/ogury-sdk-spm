//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAAdConfiguration.h"
#import "OGAAdSyncService+Testing.h"
#import "OGALog.h"

@interface OGAAdSyncServiceTests : XCTestCase

@property(nonatomic, strong) OguryNetworkClient *networkClient;
@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, strong) OGAProfigManager *profigManager;
@property(nonatomic, strong) OGAWebViewUserAgentService *webViewUserAgentService;
@property(nonatomic, strong) OGAOMIDService *omidService;
@property(nonatomic, strong) OGAProfigDao *profigPersistence;
@property(nonatomic, strong) OGAEnvironmentManager *environment;
@property(nonatomic, strong) OGAReachability *reachability;

@property(nonatomic, strong) OGAAdConfiguration *configuration;
@property(nonatomic, strong) OGAAdPrivacyConfiguration *privacyConfiguration;

@property(nonatomic, strong) OGAAdSyncService *adSyncService;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAMetricsService *metricsService;

@end

@implementation OGAAdSyncServiceTests

#pragma mark - Constants

static NSString *const DefaultURL = @"https://www.github.com";
static NSString *const DefaultOrientation = @"landscape";
static NSString *const DefaultAdUnitID = @"Default";

#pragma mark - Methods

- (void)setUp {
    self.networkClient = OCMClassMock([OguryNetworkClient class]);
    self.assetKeyManager = OCMClassMock([OGAAssetKeyManager class]);
    self.profigManager = OCMClassMock([OGAProfigManager class]);
    self.webViewUserAgentService = OCMClassMock([OGAWebViewUserAgentService class]);
    self.omidService = OCMClassMock([OGAOMIDService class]);
    self.profigPersistence = OCMClassMock([OGAProfigDao class]);
    self.environment = [OGAEnvironmentManager shared];
    self.reachability = [OGAReachability reachabilityForInternetConnection];
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    self.log = OCMClassMock([OGALog class]);
    self.privacyConfiguration = OCMClassMock([OGAAdPrivacyConfiguration class]);
    self.metricsService = OCMClassMock([OGAMetricsService class]);

    // Mock asset key and user agent
    OCMStub(self.assetKeyManager.assetKey).andReturn(@"272506");
    OCMStub(self.webViewUserAgentService.webViewUserAgent).andReturn(@"User-Agent");

    OGADelegateDispatcher *delegateDispatcher = OCMClassMock([OGADelegateDispatcher class]);
    self.configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial adUnitId:DefaultAdUnitID delegateDispatcher:delegateDispatcher viewControllerProvider:nil viewProvider:nil];

    self.adSyncService = [[OGAAdSyncService alloc] initWithNetworkClient:self.networkClient
                                                         assetKeyManager:self.assetKeyManager
                                                           profigManager:self.profigManager
                                                 webViewUserAgentService:self.webViewUserAgentService
                                                             omidService:self.omidService
                                                       profigPersistence:self.profigPersistence
                                                             environment:self.environment
                                                            reachability:self.reachability
                                                    monitoringDispatcher:self.monitoringDispatcher
                                                          metricsService:self.metricsService
                                                                     log:self.log];
}

- (void)testShouldHandleResult {
    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should handle successful response"];

    [self.adSyncService handleAdSyncRequestWithAdConfiguration:self.configuration
                                          privacyConfiguration:self.privacyConfiguration
                                                        result:[@"{}" dataUsingEncoding:NSUTF8StringEncoding]
                                                      response:nil
                                                         error:nil
                                             completionHandler:^(NSArray<OGAAd *> *ads, NSError *_Nullable error) {
                                                 XCTAssertTrue(ads.count == 0);
                                                 XCTAssertNotNil(error);
                                                 [testExpectation fulfill];
                                             }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldHandleNetworkError {
    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should handle successful response"];

    [self.adSyncService handleAdSyncRequestWithAdConfiguration:self.configuration
                                          privacyConfiguration:self.privacyConfiguration
                                                        result:nil
                                                      response:nil
                                                         error:[NSError errorWithDomain:@"" code:-1 userInfo:nil]
                                             completionHandler:^(NSArray<OGAAd *> *ads, NSError *_Nullable error) {
                                                 XCTAssertTrue(ads.count == 0);
                                                 XCTAssertNotNil(error);
                                                 [testExpectation fulfill];
                                             }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldHandleEmptyAds {
    XCTestExpectation *testExpectation = [self expectationWithDescription:@"it should handle successful response"];

    [self.adSyncService handleAdSyncRequestWithAdConfiguration:self.configuration
                                          privacyConfiguration:self.privacyConfiguration
                                                        result:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                                      response:nil
                                                         error:nil
                                             completionHandler:^(NSArray<OGAAd *> *ads, NSError *_Nullable error) {
                                                 XCTAssertTrue(ads.count == 0);
                                                 XCTAssertNotNil(error);
                                                 [testExpectation fulfill];
                                             }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testShouldPostAdSync {
    [self.adSyncService postAdSyncForAdConfiguration:self.configuration
                                privacyConfiguration:self.privacyConfiguration
                                   completionHandler:^(NSArray<OGAAd *> *_Nonnull ads, NSError *_Nullable error){
                                       // Not used
                                   }];

    OCMVerify([self.networkClient performRequest:OCMOCK_ANY completionHandlerWithUrlResponse:OCMOCK_ANY]);
}

- (void)testShouldPostAdSyncHeaderBidingEmptyAdMarkup {
    self.configuration.isHeaderBidding = true;
    [self.adSyncService postAdSyncForAdConfiguration:self.configuration
                                privacyConfiguration:self.privacyConfiguration
                                   completionHandler:^(NSArray<OGAAd *> *_Nonnull ads, NSError *_Nullable error) {
                                       XCTAssertEqual(ads.count, 0);
                                       XCTAssertNotNil(error);
                                   }];
    OCMReject([self.metricsService sendEvent:[OCMArg any]]);
    OCMReject([self.networkClient performRequest:OCMOCK_ANY completionHandlerWithUrlResponse:OCMOCK_ANY]);
    XCTAssertNil(self.configuration.encodedAdMarkup);
}

- (void)testShouldPostAdSyncHeaderBidingGoodAdMarkup {
    self.configuration.isHeaderBidding = true;
    self.configuration.encodedAdMarkup = @"ewoJImFkIjogW3sKCQkiYWRfY29udGVudCI6ICJcdTAwM2NodG1sXHUwMDNlICBcdTAwM2NoZWFkXHUwMDNlICBcdTAwM2NtZXRhIGNoYXJzZXQ9XCJVVEYtOFwiXHUwMDNlICBcdTAwM2NtZXRhIG5hbWU9XCJ2aWV3cG9ydFwiIGNvbnRlbnQ9XCJ3aWR0aD1kZXZpY2Utd2lkdGgsIGluaXRpYWwtc2NhbGU9MS4wLCB1c2VyLXNjYWxhYmxlPW5vXCJcdTAwM2UgIFx1MDAzY2xpbmsgcmVsPVwiaWNvblwiIHR5cGU9XCJpbWFnZS9wbmdcIiBocmVmPVwiZGF0YTppbWFnZS9wbmc7YmFzZTY0LGlWQk9SdzBLR2dvPVwiXHUwMDNlICBcdTAwM2NzY3JpcHQgc3JjPVwiaHR0cHM6Ly9yZXNvdXJjZXMucHJlc2FnZS5pby92My45Mi42MC04MTVhOTNmNy9hc3NldHMvb21zZGstanMvb21zZGsuanNcIlx1MDAzZVx1MDAzYy9zY3JpcHRcdTAwM2UgIFx1MDAzYy9oZWFkXHUwMDNlICBcdTAwM2Nib2R5XHUwMDNlICBcdTAwM2NkaXYgaWQ9XCJyb290XCJcdTAwM2UgIFx1MDAzYy9kaXZcdTAwM2UgIFx1MDAzY3NjcmlwdCBzcmM9XCJtcmFpZC5qc1wiXHUwMDNlXHUwMDNjL3NjcmlwdFx1MDAzZSAgXHUwMDNjc2NyaXB0IHNyYz1cImh0dHBzOi8vbXMtYWRzLnByZXNhZ2UuaW8vbXJhaWQ/ZHNwPW9ndXJ5XHUwMDI2dD0xNjg5MDg2ODQ4XHUwMDI2aW1wPWExMjQ1OGU2LTkyYjQtNDkzYi1iZDk5LTRmZmVjMTJiYmQ1Mlx1MDAyNm9jX3V1aWQ9MjA0NmY5MjQtM2FlOS00Zjk0LTg4MWEtM2QyMGRkZDU0ZDFlXHUwMDI2YWs9MzEzMDc2XHUwMDI2dV9pZD0wMDAwMDAwMC0wMDAwLTAwMDAtMDAwMC0wMDAwMDAwMDAwMDBcdTAwMjZhX3Nkaz0zLjUuMFx1MDAyNmF1aWQ9MzEzMDc2X2RlZmF1bHRcdTAwMjZjb25uPVx1MDAyNnVfb3M9aW9zXHUwMDI2YV9iPWNvLm9ndXJ5LlRlc3QtQXBwbGljYXRpb25cdTAwMjZhX249VGVzdCtBcHBsaWNhdGlvbitBZHNcdTAwMjZhdXR5cGU9aW50ZXJzdGl0aWFsXHUwMDI2YV9leD1vZ3VyeVx1MDAyNmJpZF9oYXNoPVx1MDAyNmRtbj1cdTAwMjZwZz1cdTAwMjZkX209YXJtNjRcdTAwMjZkX3R5PW1vYmlsZVx1MDAyNnVfdGs9ODNkMjA5ZjItMDU4ZS00MzA1LTg3MTAtNzE3YzNiZTYyN2E1XHUwMDI2YXVkPVx1MDAyNmR1YWxhZD1cdTAwMjZnPVx1MDAyNmNfcz1cdTAwMjZjcl9pZD02NjIwMlx1MDAyNmFkX29iPWV5SmhiR2NpT2lKSVV6STFOaUlzSW5SNWNDSTZJa3BYVkNKOS5leUpoWkhabGNuUmZhV1FpT2lKaE1USTBOVGhsTmkwNU1tSTBMVFE1TTJJdFltUTVPUzAwWm1abFl6RXlZbUprTlRJaUxDSmhaSFpsY25ScGMyVnlYMkpwWkY5d2NtbGpaU0k2TUN3aVlXUjJaWEowYVhObGNsOWtiMjFoYVc0aU9pSWlMQ0ppYVdSZmNISnBZMlVpT2pBc0ltOWthV1FpT2lJMU5XVTJOekE0TXkxaE0yWXpMVFE1TVRndFlqTXlaaTB6WkRVNFpUQTRabVV6WmpJaUxDSnlaV2RwYjI0aU9pSmxkUzEzWlhOMExURWlMQ0p6WldGMElqb2lJbjAuaGhIdWw1clE0amVqRXFXVVJrbDU3U3pVVk1qdDNWTXFRSERKclFLVDVfVVx1MDAyNmNoX3BhPWZhbHNlXHUwMDI2cD1kYyUyQ29pJTJDc2ElMkNzZFx1MDAyNnVfY3Q9Mzg1OTUzZTEtNDY5ZS00ODVmLTgxY2MtNWVhZWZiNjhiMzk3XHUwMDI2c19pZD04MWQ1YThmOGUyNjFjNzRhNTE1ZmUwNDYwNzIwNjBmN1x1MDAyNnNrYW49ZmFsc2VcIlx1MDAzZVx1MDAzYy9zY3JpcHRcdTAwM2UgIFx1MDAzYy9ib2R5XHUwMDNlICBcdTAwM2MvaHRtbFx1MDAzZSIsCgkJImFkX2NvbnRlbnRfdXJsIjogImh0dHBzOi8vbXMtYWRzLnByZXNhZ2UuaW8vbXJhaWQ/ZHNwPW9ndXJ5XHUwMDI2dD0xNjg5MDg2ODQ4XHUwMDI2aW1wPWExMjQ1OGU2LTkyYjQtNDkzYi1iZDk5LTRmZmVjMTJiYmQ1Mlx1MDAyNm9jX3V1aWQ9MjA0NmY5MjQtM2FlOS00Zjk0LTg4MWEtM2QyMGRkZDU0ZDFlXHUwMDI2YWs9MzEzMDc2XHUwMDI2dV9pZD0wMDAwMDAwMC0wMDAwLTAwMDAtMDAwMC0wMDAwMDAwMDAwMDBcdTAwMjZhX3Nkaz0zLjUuMFx1MDAyNmF1aWQ9MzEzMDc2X2RlZmF1bHRcdTAwMjZjb25uPVx1MDAyNnVfb3M9aW9zXHUwMDI2YV9iPWNvLm9ndXJ5LlRlc3QtQXBwbGljYXRpb25cdTAwMjZhX249VGVzdCtBcHBsaWNhdGlvbitBZHNcdTAwMjZhdXR5cGU9aW50ZXJzdGl0aWFsXHUwMDI2YV9leD1vZ3VyeVx1MDAyNmJpZF9oYXNoPVx1MDAyNmRtbj1cdTAwMjZwZz1cdTAwMjZkX209YXJtNjRcdTAwMjZkX3R5PW1vYmlsZVx1MDAyNnVfdGs9ODNkMjA5ZjItMDU4ZS00MzA1LTg3MTAtNzE3YzNiZTYyN2E1XHUwMDI2YXVkPVx1MDAyNmR1YWxhZD1cdTAwMjZnPVx1MDAyNmNfcz1cdTAwMjZjcl9pZD02NjIwMlx1MDAyNmFkX29iPWV5SmhiR2NpT2lKSVV6STFOaUlzSW5SNWNDSTZJa3BYVkNKOS5leUpoWkhabGNuUmZhV1FpT2lKaE1USTBOVGhsTmkwNU1tSTBMVFE1TTJJdFltUTVPUzAwWm1abFl6RXlZbUprTlRJaUxDSmhaSFpsY25ScGMyVnlYMkpwWkY5d2NtbGpaU0k2TUN3aVlXUjJaWEowYVhObGNsOWtiMjFoYVc0aU9pSWlMQ0ppYVdSZmNISnBZMlVpT2pBc0ltOWthV1FpT2lJMU5XVTJOekE0TXkxaE0yWXpMVFE1TVRndFlqTXlaaTB6WkRVNFpUQTRabVV6WmpJaUxDSnlaV2RwYjI0aU9pSmxkUzEzWlhOMExURWlMQ0p6WldGMElqb2lJbjAuaGhIdWw1clE0amVqRXFXVVJrbDU3U3pVVk1qdDNWTXFRSERKclFLVDVfVVx1MDAyNmNoX3BhPWZhbHNlXHUwMDI2cD1kYyUyQ29pJTJDc2ElMkNzZFx1MDAyNnVfY3Q9Mzg1OTUzZTEtNDY5ZS00ODVmLTgxY2MtNWVhZWZiNjhiMzk3XHUwMDI2c19pZD04MWQ1YThmOGUyNjFjNzRhNTE1ZmUwNDYwNzIwNjBmN1x1MDAyNnNrYW49ZmFsc2VcdTAwMjZ0X2E9dHJ1ZSIsCgkJImFkX2tlZXBfYWxpdmUiOiBmYWxzZSwKCQkiY2FjaGUiIDogewoJCQkiYWRfZXhwaXJhdGlvbiIgOiAxMDAwCgkJfSwKCQkiYWRfdHJhY2tfdXJscyI6IHsKCQkJImFkX2hpc3RvcnlfdXJsIjogImhpc3RvcnkiLAoJCQkiYWRfcHJlY2FjaGVfdXJsIjogInByZWNhY2hlIiwKCQkJImFkX3RyYWNrX3VybCI6ICJ0cmFjayIKCQl9LAoJCSJhZF91bml0IjogewoJCQkiYXBwX3VzZXJfaWQiOiAiIiwKCQkJImlkIjogIjMxMzA3Nl9kZWZhdWx0IiwKCQkJInJld2FyZF9sYXVuY2giOiAiIiwKCQkJInJld2FyZF9uYW1lIjogIiIsCgkJCSJyZXdhcmRfdmFsdWUiOiAiIiwKCQkJInR5cGUiOiAiaW50ZXJzdGl0aWFsIgoJCX0sCgkJImFkdmVydGlzZXIiOiB7CgkJCSJpZCI6ICIxIgoJCX0sCgkJImJhbm5lciI6IHsKCQkJImF1dG9fcmVmcmVzaCI6IGZhbHNlLAoJCQkiYXV0b19yZWZyZXNoX3JhdGUiOiAwLAoJCQkiZnVsbF93aWR0aCI6IGZhbHNlCgkJfSwKCQkiY2FtcGFpZ25faWQiOiAiMTMiLAoJCSJjcmVhdGl2ZV9pZCI6ICIxNTAwIiwKCQkiY2xpZW50X3RyYWNrZXJfcGF0dGVybiI6ICIiLAoJCSJmb3JtYXQiOiB7CgkJCSJkZWxheV9mb3Jfc2VuZGluZ19sb2FkZWQiOiA0LAoJCQkibGF1bmNoX29taWRfbG9hZCI6IGZhbHNlLAoJCQkibXJhaWRfZG93bmxvYWRfdXJsIjogImh0dHBzOi8vbXJhaWQucHJlc2FnZS5pby9hMmFkOWYxL21yYWlkLmpzIiwKCQkJIndlYnZpZXdfYmFzZV91cmwiOiAiaHR0cHM6Ly93d3cub2d5Zm10cy5jb20vIgoJCX0sCgkJImV4dHJhcyI6IFt7CgkJCSJuYW1lIjogImRzcCIsCgkJCSJ2YWx1ZSI6ICJ7XCJjcmVhdGl2ZV9pZFwiOiBcIjEyM1wiLCBcInJlZ2lvblwiOlwiZWFzdC11c1wifSIsCgkJCSJ2ZXJzaW9uIjogMgoJCX0sewoJCQkibmFtZSI6ICJ2YXN0X3ZlcnNpb24iLAoJCQkidmFsdWUiOiAiNC4wIiwKCQkJInZlcnNpb24iOiAxCgkJfV0sCgkJImhhc190cmFuc3BhcmVuY3kiOiBmYWxzZSwKCQkiaWQiOiAiYTEyNDU4ZTYtOTJiNC00OTNiLWJkOTktNGZmZWMxMmJiZDUyIiwKCQkiaW1wcmVzc2lvbl91cmwiOiAiIiwKCQkiaXNfaW1wcmVzc2lvbiI6IHRydWUsCgkJImlzX3ZpZGVvIjogZmFsc2UsCgkJImxhbmRpbmdfcGFnZV9kaXNhYmxlX2phdmFzY3JpcHQiOiBmYWxzZSwKCQkibGFuZGluZ19wYWdlX3ByZWZldGNoX3VybCI6ICIiLAoJCSJsYW5kaW5nX3BhZ2VfcHJlZmV0Y2hfd2hpdGVsaXN0IjogIiIsCgkJImxvYWRlZF9zb3VyY2UiOiAiZm9ybWF0IiwKCQkibW9hdEVuYWJsZWQiOiBmYWxzZSwKCQkib21pZCI6IHRydWUsCgkJIm92ZXJsYXkiOiB7CgkJCSJkaXNhYmxlX211bHRpX2FjdGl2aXR5IjogMCwKCQkJImRyYWdnYWJsZSI6IGZhbHNlLAoJCQkiaW5pdGlhbF9zaXplIjoge30KCQl9LAoJCSJzZGtfY2xvc2VfYnV0dG9uX3VybCI6ICJodHRwczovL21zLWFkcy1ldmVudHMucHJlc2FnZS5pby9jcmVhdGl2ZT9lPXNka19jbG9zZV9idXR0b25cdTAwMjZpbXA9YTEyNDU4ZTYtOTJiNC00OTNiLWJkOTktNGZmZWMxMmJiZDUyXHUwMDI2b2NfaWQ9MTI0OTM2XHUwMDI2YWs9MzEzMDc2XHUwMDI2dV9pZD0wMDAwMDAwMC0wMDAwLTAwMDAtMDAwMC0wMDAwMDAwMDAwMDBcdTAwMjZhX3Nkaz0zLjUuMFx1MDAyNnVfb3M9aW9zXHUwMDI2YV9iPWNvLm9ndXJ5LlRlc3QtQXBwbGljYXRpb25cdTAwMjZhX249VGVzdCtBcHBsaWNhdGlvbitBZHNcdTAwMjZjcl9pZD02NjIwMlx1MDAyNnRfYT10cnVlIgoJfV0KfQ==";
    [self.adSyncService postAdSyncForAdConfiguration:self.configuration
                                privacyConfiguration:self.privacyConfiguration
                                   completionHandler:^(NSArray<OGAAd *> *_Nonnull ads, NSError *_Nullable error) {
                                       XCTAssertEqual(ads.count, 1);
                                       XCTAssertNil(error);
                                   }];
    OCMReject([self.metricsService sendEvent:[OCMArg any]]);
    OCMReject([self.networkClient performRequest:OCMOCK_ANY completionHandlerWithUrlResponse:OCMOCK_ANY]);
    XCTAssertNotNil(self.configuration.encodedAdMarkup);
}

- (void)testShouldParseAdSyncData {
    NSDictionary *rawAdPayload = @{
        @"ad" : @[
            @{
                @"ad_content" : @"<html><body>Hello world!</body></html>",
                @"ad_keep_alive" : @(1),
                @"ad_unit" : @{
                    @"id" : @"272506_default",
                    @"type" : @"interstitial"
                },
                @"advertiser" : @{
                    @"id" : @(137),
                    @"name" : @"Philips"
                },
                @"format" : @{
                    @"mraid_download_url" : @"https://mraid.presage.io/f838b9b/mraid.js",
                    @"params" : @[
                        @{
                            @"name" : @"zones",
                            @"value" : @[
                                @{
                                    @"name" : @"controller",
                                    @"size" : @{
                                        @"height" : @"-1",
                                        @"width" : @"-1"
                                    },
                                    @"url" : @"http://staging.litecdn.com/2020-11-18-5cffa751-jenkins/formats/mraid-wrapper/index.html"
                                }
                            ]
                        }
                    ],
                    @"webview_base_url" : @"http://www.ogyfmts.com/"
                },
                @"id" : @"d159647b-f62b-421a-8c9a-58095187458b",
                @"params" : @{

                },
                @"sdk_close_button_url" : @"https://ms-ads-events.staging.presage.io/creative?e=sdk_close_button&imp=d159647b-f62b-421a-8c9a-58095187458b&oc_id=34717&ak=272506&u_id=00000000-0000-0000-0000-000000000000&a_sdk=0.0.2&u_os=ios&a_b=co.ogury.ads.SwiftPresageTest&a_n=iOS%20New%20Test%20App"
            }
        ],
        @"cache" : @{
            @"advert_id" : @"0d59a518-9e07-4fcd-a18c-257e1b1fabe4",
            @"assets" : @[
                @"https://www.google.com"
            ],
            @"campaign_id" : @(34717)
        }
    };

    NSData *adPayload = [NSJSONSerialization dataWithJSONObject:rawAdPayload options:NSJSONWritingFragmentsAllowed error:nil];

    NSArray<OGAAd *> *ads = [self.adSyncService parseAdsFromData:adPayload adConfiguration:self.configuration privacyConfiguration:self.privacyConfiguration error:nil];

    XCTAssertNotNil(ads);
    XCTAssertEqual(ads.count, 1);
}

- (void)testShouldNotParseIncompleteAdSyncDataWith {
    NSDictionary *rawAdPayload = @{
        @"ad" : @[
            @{
                @"ad_content" : @"<html><body>Hello world!</body></html>",
                @"ad_keep_alive" : @(1),
                @"advertiser" : @{
                    @"id" : @(137),
                    @"name" : @"Philips"
                },
                @"format" : @{
                    @"mraid_download_url" : @"https://mraid.presage.io/f838b9b/mraid.js",
                    @"params" : @[
                        @{
                            @"name" : @"zones",
                            @"value" : @[
                                @{
                                    @"name" : @"controller",
                                    @"size" : @{
                                        @"height" : @"-1",
                                        @"width" : @"-1"
                                    },
                                    @"url" : @"http://staging.litecdn.com/2020-11-18-5cffa751-jenkins/formats/mraid-wrapper/index.html"
                                }
                            ]
                        }
                    ],
                    @"webview_base_url" : @"http://www.ogyfmts.com/"
                },
                @"id" : @"d159647b-f62b-421a-8c9a-58095187458b",
                @"params" : @{

                },
                @"sdk_close_button_url" : @"https://ms-ads-events.staging.presage.io/creative?e=sdk_close_button&imp=d159647b-f62b-421a-8c9a-58095187458b&oc_id=34717&ak=272506&u_id=00000000-0000-0000-0000-000000000000&a_sdk=0.0.2&u_os=ios&a_b=co.ogury.ads.SwiftPresageTest&a_n=iOS%20New%20Test%20App"
            }
        ],
        @"cache" : @{
            @"advert_id" : @"0d59a518-9e07-4fcd-a18c-257e1b1fabe4",
            @"assets" : @[
                @"https://www.google.com"
            ],
            @"campaign_id" : @(34717)
        }
    };

    NSData *adPayload = [NSJSONSerialization dataWithJSONObject:rawAdPayload options:NSJSONWritingFragmentsAllowed error:nil];
    NSError *error = nil;
    NSArray<OGAAd *> *ads = [self.adSyncService parseAdsFromData:adPayload adConfiguration:self.configuration privacyConfiguration:self.privacyConfiguration error:&error];

    XCTAssertNotNil(ads);
    XCTAssertEqual(ads.count, 0);
}

- (void)testShouldReturnAdSyncURLRequest {
    NSURLRequest *request = [self.adSyncService adSyncURLRequestForURL:[NSURL URLWithString:DefaultURL]
                                                       adConfiguration:self.configuration
                                                  privacyConfiguration:self.privacyConfiguration];
    XCTAssertNotNil(request);
    XCTAssertTrue([request.URL.absoluteString isEqualToString:DefaultURL]);
    XCTAssertEqual(request.allHTTPHeaderFields.count, 5);
    XCTAssertTrue([request.allHTTPHeaderFields[@"Accept"] isEqualToString:@"application/json"]);
    XCTAssertTrue([request.allHTTPHeaderFields[@"Accept-Encoding"] isEqualToString:@"gzip"]);
    XCTAssertTrue([request.allHTTPHeaderFields[@"Content-Encoding"] isEqualToString:@"gzip"]);
    XCTAssertNotNil(request.allHTTPHeaderFields[@"Content-Length"]);
    XCTAssertTrue([request.allHTTPHeaderFields[@"Content-Type"] isEqualToString:@"application/json"]);
}

- (void)testShouldFetchCustomClose {
    [self.adSyncService fetchCustomCloseWithURL:[NSURL URLWithString:DefaultURL]];

    OCMVerify([self.networkClient performRequest:OCMOCK_ANY completionHandler:OCMOCK_ANY]);
}

- (void)testShouldNotFetchCustomCloseWithInvalidURL {
    [self.adSyncService fetchCustomCloseWithURL:[NSURL URLWithString:@""]];

    OCMReject([self.networkClient performRequest:OCMOCK_ANY completionHandler:OCMOCK_ANY]);
}

- (void)testWhenAdParsingSucceedsThenParseMonitoringTrackShouldBeSent {
    NSHTTPURLResponse *response = OCMClassMock([NSHTTPURLResponse class]);
    OCMStub(response.statusCode).andReturn(200);
    [self.adSyncService handleAdSyncRequestWithAdConfiguration:self.configuration
                                          privacyConfiguration:self.privacyConfiguration
                                                        result:[@"{}" dataUsingEncoding:NSUTF8StringEncoding]
                                                      response:response
                                                         error:nil
                                             completionHandler:^(NSArray<OGAAd *> *ads, NSError *_Nullable error){
                                             }];
    OCMVerify([self.monitoringDispatcher sendLoadEvent:OGALoadEventAdParseStarted adConfiguration:[OCMArg any]]);
}

- (void)testWhenAdParsingFailsWithNoFilThenNoParseMonitoringTrackShouldBeSent {
    NSHTTPURLResponse *response = OCMClassMock([NSHTTPURLResponse class]);
    OCMStub(response.statusCode).andReturn(204);
    [self.adSyncService handleAdSyncRequestWithAdConfiguration:self.configuration
                                          privacyConfiguration:self.privacyConfiguration
                                                        result:[@"{}" dataUsingEncoding:NSUTF8StringEncoding]
                                                      response:response
                                                         error:nil
                                             completionHandler:^(NSArray<OGAAd *> *ads, NSError *_Nullable error){
                                             }];
    OCMReject([self.monitoringDispatcher sendLoadEvent:OGALoadEventAdParseStarted adConfiguration:[OCMArg any]]);
}

- (void)testWhenAdParsingFailsThenNoParseMonitoringTrackShouldBeSent {
    NSHTTPURLResponse *response = OCMClassMock([NSHTTPURLResponse class]);
    OCMStub(response.statusCode).andReturn(400);
    [self.adSyncService handleAdSyncRequestWithAdConfiguration:self.configuration
                                          privacyConfiguration:self.privacyConfiguration
                                                        result:[@"{}" dataUsingEncoding:NSUTF8StringEncoding]
                                                      response:response
                                                         error:nil
                                             completionHandler:^(NSArray<OGAAd *> *ads, NSError *_Nullable error){
                                             }];
    OCMReject([self.monitoringDispatcher sendLoadEvent:OGALoadEventAdParseStarted adConfiguration:[OCMArg any]]);
}

@end
