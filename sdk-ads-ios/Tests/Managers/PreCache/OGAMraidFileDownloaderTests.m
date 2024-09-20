//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAMraidFileDownloader.h"
#import "OguryAdsError.h"
#import "OGAAd.h"
#import "OGAMonitoringDispatcher.h"
#import "OGALog.h"
#import "OguryAdsError+Internal.h"

@interface OGAMraidFileDownloader ()

@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGALog *log;

- (instancetype)initWith:(OGAMonitoringDispatcher *)monitoringDispatcher log:(OGALog *)log;

@end

@interface OGAMraidFileDownloaderTests : XCTestCase

@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAAd *ad;
@property(nonatomic, strong) OGAMraidFileDownloader *mraidFileDownloader;

@end

@implementation OGAMraidFileDownloaderTests

- (void)setUp {
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    self.log = OCMClassMock([OGALog class]);
    self.ad = OCMClassMock([OGAAd class]);
    self.mraidFileDownloader = OCMPartialMock([[OGAMraidFileDownloader alloc] initWith:self.monitoringDispatcher
                                                                                   log:self.log]);
}

#pragma mark - Methods

- (void)setInitWithMonitoringDispatcherAndLog {
    XCTAssertNotNil(self.mraidFileDownloader);
    XCTAssertEqual(self.mraidFileDownloader.log, self.log);
    XCTAssertEqual(self.mraidFileDownloader.monitoringDispatcher, self.monitoringDispatcher);
}

- (void)testDownloadMraidFileData {
    __block NSString *responseBlock;
    // XCTestExpectation *expect = [self expectationWithDescription:@"mraidFileDownloader"];

    NSString *downloadURL = @"https://mraid.presage.io/ec9d014/mraid.js";

    OCMStub(self.ad.mraidDownloadUrl).andReturn(downloadURL);
    //    OCMStub([self.monitoringDispatcher sendLoadEvent:OGALoadEventMraidRequest adConfiguration:[OCMArg any] details:[OCMArg any]]);
    //    OCMStub([self.log logAd:OguryLogLevelDebug forAdConfiguration:[OCMArg any] message:[OCMArg any]]);

    [self.mraidFileDownloader downloadMraidJSFromURL:self.ad
                                          completion:^(NSString *response, NSError *error) {
                                              XCTAssertTrue([NSThread isMainThread]);
                                              responseBlock = response;
                                              //[expect fulfill];
                                          }];

    OCMVerify([self.monitoringDispatcher sendLoadEvent:OGALoadEventMraidRequest adConfiguration:[OCMArg any] details:[OCMArg any]]);
    OCMVerify([self.log log:[OCMArg any]]);
    /*
     [self waitForExpectationsWithTimeout:50.0f handler:^(NSError * _Nullable error) {
     XCTAssertNotNil(responseBlock,"Should not be nil");
     }];
     */
}

- (void)testDownloadMraidInvalidUrl {
    XCTestExpectation *expect = [self expectationWithDescription:@"mraidFileDownloader"];
    OCMReject([self.monitoringDispatcher sendLoadEvent:OGALoadEventMraidRequest adConfiguration:[OCMArg any] details:[OCMArg any]]);
    OCMReject([self.log log:[OCMArg any]]);
    NSString *downloadURL = nil;
    OCMStub(self.ad.mraidDownloadUrl).andReturn(downloadURL);
    [self.mraidFileDownloader downloadMraidJSFromURL:self.ad
                                          completion:^(NSString *response, NSError *error) {
                                              XCTAssertEqualObjects(error, [OguryAdsError adPrecachingFailedWithStackTrace:@"No mraidDownloadUrl found on ad"]);
                                              [expect fulfill];
                                          }];
    [self waitForExpectations:@[ expect ] timeout:1.0];
}

@end
