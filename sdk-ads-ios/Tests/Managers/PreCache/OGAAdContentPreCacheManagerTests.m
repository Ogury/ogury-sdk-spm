//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OGAAdContentPreCacheManager+Testing.h"
#import "OGAMonitoringDispatcher.h"
#import "OGATrackEvent.h"
#import "OguryAdsError.h"
#import "OguryError+utility.h"
#import "OguryAdsError+Internal.h"

NSString *const TestAdIdentifier = @"ad-identifier";
NSString *const TestMraidDownloadUrl = @"https://example.com/mraid.js";
NSString *const TestMraidDownloadUrl2 = @"https://example.com/mraid2.js";

@interface OGAAdContentPreCacheManagerTests : XCTestCase

@property(nonatomic, strong) OGAUserDefaultsStore *userDefaultsStore;
@property(nonatomic, strong) OGAMraidFileDownloader *mraidFileDownloader;
@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;

@property(nonatomic, strong) OGAAdContentPreCacheManager *manager;

@end

@implementation OGAAdContentPreCacheManagerTests

- (void)setUp {
    self.userDefaultsStore = OCMClassMock([OGAUserDefaultsStore class]);
    self.mraidFileDownloader = OCMClassMock([OGAMraidFileDownloader class]);
    self.metricsService = OCMClassMock([OGAMetricsService class]);
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);

    OGAAdContentPreCacheManager *manager = [[OGAAdContentPreCacheManager alloc] initWithUserDefaultsStore:self.userDefaultsStore
                                                                                      mraidFileDownloader:self.mraidFileDownloader
                                                                                     monitoringDispatcher:self.monitoringDispatcher
                                                                                           metricsService:self.metricsService];
    self.manager = OCMPartialMock(manager);
}

- (void)testHasAtLeastOneMraidDownload_noAdWithMraidDownloadUrl {
    OGAAd *adOne = OCMClassMock([OGAAd class]);
    OCMStub(adOne.mraidDownloadUrl).andReturn(nil);
    OGAAd *adTwo = OCMClassMock([OGAAd class]);
    OCMStub(adTwo.mraidDownloadUrl).andReturn(nil);
    NSArray<OGAAd *> *ads = @[ adOne, adTwo ];

    XCTAssertFalse([self.manager hasAtLeastOneMraidDownload:ads]);
}

- (void)testHasAtLeastOneMraidDownload_atLeastOneAdWithMraidDownloadUrl {
    OGAAd *adOne = OCMClassMock([OGAAd class]);
    OCMStub(adOne.mraidDownloadUrl).andReturn(nil);
    OGAAd *adTwo = OCMClassMock([OGAAd class]);
    OCMStub(adTwo.mraidDownloadUrl).andReturn(TestMraidDownloadUrl);
    NSArray<OGAAd *> *ads = @[ adOne, adTwo ];

    XCTAssertTrue([self.manager hasAtLeastOneMraidDownload:ads]);
}

- (void)testDownloadMraidScript_alreadyCachedInUserDefaults {
    OCMStub([self.userDefaultsStore stringForKey:TestMraidDownloadUrl]).andReturn(@"");

    XCTestExpectation *expectation = [self expectationWithDescription:@"Download mraid completion handler"];
    OGAAd *adOne = OCMClassMock([OGAAd class]);
    OCMStub(adOne.mraidDownloadUrl).andReturn(TestMraidDownloadUrl);
    [self.manager downloadMraidScript:adOne
                    completionHandler:^(NSString *mraidDownloadUrl, OguryError *error) {
                        XCTAssertEqualObjects(mraidDownloadUrl, TestMraidDownloadUrl);
                        XCTAssertNil(error);
                        [expectation fulfill];
                    }];

    [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testDownloadMraidScript_downloadMraidSuccessfuly {
    __block MraidFileCompletion capturedCompletionHandler = nil;
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub(ad.mraidDownloadUrl).andReturn(TestMraidDownloadUrl);
    OCMStub([self.userDefaultsStore stringForKey:TestMraidDownloadUrl]).andReturn(nil);
    OCMExpect([self.mraidFileDownloader downloadMraidJSFromURL:ad
                                                    completion:[OCMArg checkWithBlock:^BOOL(id obj) {
                                                        capturedCompletionHandler = obj;
                                                        return YES;
                                                    }]]);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Download mraid completion handler"];

    OCMStub(ad.mraidDownloadUrl).andReturn(TestMraidDownloadUrl);
    [self.manager downloadMraidScript:ad
                    completionHandler:^(NSString *mraidDownloadUrl, OguryError *error) {
                        XCTAssertEqualObjects(mraidDownloadUrl, TestMraidDownloadUrl);
                        XCTAssertNil(error);
                        [expectation fulfill];
                    }];

    OCMVerifyAll((id)self.mraidFileDownloader);
    XCTAssertNotNil(capturedCompletionHandler);
    capturedCompletionHandler(TestMraidDownloadUrl, nil);

    [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testDownloadMraidScript_downloadMraidFailed {
    NSError *throwError = OCMClassMock([NSError class]);
    __block MraidFileCompletion capturedCompletionHandler = nil;
    OCMStub([self.userDefaultsStore stringForKey:TestMraidDownloadUrl]).andReturn(nil);
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub(ad.mraidDownloadUrl).andReturn(TestMraidDownloadUrl);
    OCMExpect([self.mraidFileDownloader downloadMraidJSFromURL:ad
                                                    completion:[OCMArg checkWithBlock:^BOOL(id obj) {
                                                        capturedCompletionHandler = obj;
                                                        return YES;
                                                    }]]);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Download mraid completion handler"];

    [self.manager downloadMraidScript:ad
                    completionHandler:^(NSString *mraidDownloadUrl, OguryError *error) {
                        XCTAssertEqualObjects(mraidDownloadUrl, TestMraidDownloadUrl);
                        XCTAssertEqual(error.code, -1);
                        [expectation fulfill];
                    }];

    OCMVerifyAll((id)self.mraidFileDownloader);
    XCTAssertNotNil(capturedCompletionHandler);
    capturedCompletionHandler(TestMraidDownloadUrl, throwError);

    [self waitForExpectations:@[ expectation ] timeout:1.0];
}

- (void)testDownloadMraidScripts_waitAllMraidDownloaded {
    __block int completionHandlerCount = 0;
    NSMutableArray<MraidDownloadCompletionHandler> *completionHandlers = [NSMutableArray array];
    OGAAd *adOne = OCMClassMock([OGAAd class]);
    OCMStub(adOne.mraidDownloadUrl).andReturn(TestMraidDownloadUrl);
    OGAAd *adTwo = OCMClassMock([OGAAd class]);
    OCMStub(adTwo.mraidDownloadUrl).andReturn(TestMraidDownloadUrl2);

    OCMStub([self.manager downloadMraidScript:[OCMArg any]
                            completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
                                [completionHandlers addObject:obj];
                                return YES;
                            }]])
        .andDo(^(NSInvocation *invocation){
        });

    [self.manager downloadMraidScripts:@[ adOne, adTwo ]
                     completionHandler:^(NSError *error) {
                         completionHandlerCount++;
                         XCTAssertNil(error);
                     }];
    XCTAssertEqual(completionHandlerCount, 0);

    OCMVerify([self.manager downloadMraidScript:adOne completionHandler:[OCMArg any]]);
    OCMVerify([self.manager downloadMraidScript:adTwo completionHandler:[OCMArg any]]);

    OCMVerify([self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdPrecache adConfiguration:[OCMArg any]]);
    MraidDownloadCompletionHandler completionHandler = completionHandlers[0];
    completionHandler(TestMraidDownloadUrl, nil);
    XCTAssertEqual(completionHandlerCount, 0);

    completionHandler = completionHandlers[1];
    completionHandler(TestMraidDownloadUrl2, nil);
    XCTAssertEqual(completionHandlerCount, 1);
}

- (void)testDownloadMraidScripts_notifyMraidDownloadFailedOnce {
    __block int completionHandlerCount = 0;
    NSMutableArray<MraidDownloadCompletionHandler> *completionHandlers = [NSMutableArray array];
    OGAAd *adOne = OCMClassMock([OGAAd class]);
    OCMStub(adOne.mraidDownloadUrl).andReturn(TestMraidDownloadUrl);
    OGAAd *adTwo = OCMClassMock([OGAAd class]);
    OCMStub(adTwo.mraidDownloadUrl).andReturn(TestMraidDownloadUrl2);
    NSArray<OGAAd *> *ads = @[ adOne, adTwo ];

    OCMStub([self.manager downloadMraidScript:[OCMArg any]
                            completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
                                [completionHandlers addObject:obj];
                                return YES;
                            }]]);
    OCMStub([self.manager sendLoadedErrorEventsAfterFailingToDownload:[OCMArg any] ads:[OCMArg any]]);
    OCMReject([self.manager sendLoadedErrorEventsAfterFailingToDownload:TestMraidDownloadUrl2 ads:[OCMArg any]]);

    [self.manager downloadMraidScripts:ads
                     completionHandler:^(OguryError *error) {
                         completionHandlerCount++;
                         XCTAssertEqualObjects(error, [OguryAdsError adPrecachingFailedWithStackTrace:@"Mraid download error"]);
                     }];

    OCMVerify([self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdPrecache adConfiguration:[OCMArg any]]);
    MraidDownloadCompletionHandler completionHandler = completionHandlers[0];
    completionHandler(TestMraidDownloadUrl, [OguryAdsError noAdLoaded]);
    XCTAssertEqual(completionHandlerCount, 1);
    OCMVerify([self.manager sendLoadedErrorEventsAfterFailingToDownload:TestMraidDownloadUrl ads:[OCMArg any]]);

    completionHandler = completionHandlers[0];
    completionHandler(TestMraidDownloadUrl2, nil);
    XCTAssertEqual(completionHandlerCount, 1);
}

- (void)testPrepareAdContents_preCacheMraidDownloadUrls {
    OGAAd *adOne = OCMClassMock([OGAAd class]);
    OCMStub(adOne.html).andReturn(@"<html></html>");
    OCMStub(adOne.mraidDownloadUrl).andReturn(TestMraidDownloadUrl);
    OGAPrepareAdContentsCompletionHandler completionHandler = ^(OguryError *error) {
    };
    OCMStub([self.manager downloadMraidScripts:@[ adOne ] completionHandler:completionHandler])
        .andDo(^(NSInvocation *invocation){
        });

    [self.manager prepareAdContents:@[ adOne ] completionHandler:completionHandler];
    OCMVerify([self.manager downloadMraidScripts:@[ adOne ] completionHandler:completionHandler]);
}

- (void)testSendLoadedErrorEventsAfterFailingToDownload {
    OGAAd *adOne = OCMClassMock([OGAAd class]);
    OCMStub(adOne.mraidDownloadUrl).andReturn(TestMraidDownloadUrl);
    OGAAd *adTwo = OCMClassMock([OGAAd class]);
    OCMStub(adTwo.mraidDownloadUrl).andReturn(TestMraidDownloadUrl2);
    OGAAd *adThree = OCMClassMock([OGAAd class]);
    OCMStub(adThree.mraidDownloadUrl).andReturn(TestMraidDownloadUrl);
    OCMStub([self.manager sendLoadedErrorEventForAd:[OCMArg any]]);
    OCMReject([self.manager sendLoadedErrorEventForAd:adTwo]);

    [self.manager sendLoadedErrorEventsAfterFailingToDownload:TestMraidDownloadUrl ads:@[ adOne, adTwo, adThree ]];

    OCMVerify([self.manager sendLoadedErrorEventForAd:adOne]);
    OCMVerify([self.manager sendLoadedErrorEventForAd:adThree]);
}

- (void)testSendLoadedErrorEventForAd {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub(ad.identifier).andReturn(TestAdIdentifier);

    OguryError *error = [OguryAdsError makeError];
    [self.manager sendLoadedErrorEventForAd:ad];

    __block OGATrackEvent *trackEvent;
    OCMVerify([self.metricsService sendEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                                       if ([obj isKindOfClass:[OGATrackEvent class]]) {
                                           trackEvent = obj;
                                           return YES;
                                       }
                                       return NO;
                                   }]]);
    XCTAssertEqualObjects(trackEvent.eventName, @"loaded_error");
    XCTAssertEqualObjects(trackEvent.advertId, TestAdIdentifier);
}

- (void)testWhenAdsContainsEmptyHtmlThenProperErrorAndEventsAreDispatched {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub(ad.html).andReturn(@"");
    OGAAdConfiguration *conf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(ad.adConfiguration).andReturn(conf);
    [self.manager prepareAdContents:@[ ad ]
                  completionHandler:^(OguryError *_Nullable error) {
                      XCTAssertNotNil(error);
                      XCTAssertEqual(error.code, 2300);
                  }];
    OCMVerify([self.monitoringDispatcher sendLoadErrorEventPrecacheFail:OGAMonitoringPrecacheErrorHtmlEmpty adConfiguration:conf]);
}

- (void)testWhenAdsContainsNilHtmlThenProperErrorAndEventsAreDispatched {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub(ad.html).andReturn(nil);
    OGAAdConfiguration *conf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(ad.adConfiguration).andReturn(conf);
    [self.manager prepareAdContents:@[ ad ]
                  completionHandler:^(OguryError *_Nullable error) {
                      XCTAssertNotNil(error);
                      XCTAssertEqual(error.code, 2300);
                  }];
    OCMVerify([self.monitoringDispatcher sendLoadErrorEventPrecacheFail:OGAMonitoringPrecacheErrorHtmlEmpty adConfiguration:conf]);
}

- (void)testWhenAdsContainsOneEmptyHtmlThenProperEventsAreDispatchedButNoError {
    OGAAd *adOne = OCMClassMock([OGAAd class]);
    OCMStub(adOne.html).andReturn(nil);
    OGAAdConfiguration *conf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(adOne.adConfiguration).andReturn(conf);
    OGAAd *adTwo = OCMClassMock([OGAAd class]);
    OCMStub(adTwo.html).andReturn(@"html");
    [self.manager prepareAdContents:@[ adOne, adTwo ]
                  completionHandler:^(OguryError *_Nullable error) {
                      XCTAssertNil(error);
                  }];
    OCMVerify([self.monitoringDispatcher sendLoadErrorEventPrecacheFail:OGAMonitoringPrecacheErrorHtmlEmpty adConfiguration:conf]);
}

@end
