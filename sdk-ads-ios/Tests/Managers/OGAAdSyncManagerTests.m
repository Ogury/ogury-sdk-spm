//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAAdConfiguration.h"
#import "OGAAdSyncManager.h"
#import "OGAAdSyncService.h"
#import "OGALog.h"
#import "OGAProfigDao.h"
#import "OGAProfigManager.h"
#import "OGAWebViewUserAgentService.h"

@interface OGAAdSyncManager ()

- (instancetype)initWithProfigManager:(OGAProfigManager *)profigManager
                        adSyncService:(OGAAdSyncService *)adSyncService
              webViewUserAgentService:(OGAWebViewUserAgentService *)webViewUserAgentService
                                  log:(OGALog *)log;

@end

@interface OGAProfigDao ()

- (OGAProfigDao *)load;

@end

@interface OGAAdSyncStoreTests : XCTestCase

@property(nonatomic, strong) OGAProfigManager *profigManager;
@property(nonatomic, strong) OGAAdSyncService *adSyncService;
@property(nonatomic, strong) OGAWebViewUserAgentService *webViewUserAgentService;
@property(nonatomic, strong) OGALog *log;

@property(nonatomic, strong) OGAAdConfiguration *configuration;

@property(nonatomic, strong) OGAAdSyncManager *adSyncManager;

@end

@implementation OGAAdSyncStoreTests

#pragma mark - Constants

static NSString *const DefaultURL = @"https://www.github.com";
static NSString *const DefaultCampaignID = @"Campaign";
static NSString *const DefaultAdUnitID = @"Default";

#pragma mark - Methods

- (void)setUp {
    self.log = OCMClassMock([OGALog class]);
    self.adSyncService = OCMClassMock([OGAAdSyncService class]);
    self.webViewUserAgentService = OCMClassMock([OGAWebViewUserAgentService class]);
    self.profigManager = OCMClassMock([OGAProfigManager class]);

    self.configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(self.configuration.adType).andReturn(OguryAdsTypeInterstitial);
    OCMStub(self.configuration.adUnitId).andReturn(DefaultAdUnitID);
    OCMStub(self.configuration.campaignId).andReturn(DefaultCampaignID);

    self.adSyncManager = [[OGAAdSyncManager alloc] initWithProfigManager:self.profigManager
                                                           adSyncService:self.adSyncService
                                                 webViewUserAgentService:self.webViewUserAgentService
                                                                     log:self.log];
}

- (void)testShouldPostAdSyncWithValidProfigAndValidUserConsent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Ad sync completion handler called."];
    __block OGAAdSyncCompletionHandler capturedCompletionHandler = nil;
    OCMStub([self.profigManager shouldSync]).andReturn(NO);
    OCMStub([self.adSyncService postAdSyncForAdConfiguration:[OCMArg any]
                                        privacyConfiguration:[OCMArg any]
                                           completionHandler:[OCMArg checkWithBlock:^BOOL(id obj) {
                                               capturedCompletionHandler = obj;
                                               return YES;
                                           }]]);

    // Dispatch the test to wait for the event bus to dispatch the message.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.adSyncManager postAdSyncForAdConfiguration:self.configuration
                                    privacyConfiguration:[OCMArg any]
                                       completionHandler:^(NSArray<OGAAd *> *_Nonnull ads, NSError *_Nullable error) {
                                           XCTAssertTrue([NSThread isMainThread]);

                                           [expectation fulfill];
                                       }];

        // Post adsync request.
        XCTAssertNotNil(capturedCompletionHandler);
        capturedCompletionHandler(@[], nil);
    });

    [self waitForExpectationsWithTimeout:1.0
                                 handler:^(NSError *error) {
                                     OCMVerify([self.adSyncService postAdSyncForAdConfiguration:self.configuration privacyConfiguration:[OCMArg any] completionHandler:[OCMArg any]]);
                                 }];
}

- (void)testShouldNotPostAdSyncWithInvalidProfig {
    OCMStub([self.profigManager shouldSync]).andReturn(YES);
    OCMReject([self.adSyncService postAdSyncForAdConfiguration:[OCMArg any] privacyConfiguration:[OCMArg any] completionHandler:[OCMArg any]]);

    [self.adSyncManager postAdSyncForAdConfiguration:self.configuration
                                privacyConfiguration:[OCMArg any]
                                   completionHandler:^(NSArray<OGAAd *> *_Nonnull ads, NSError *_Nullable error){
                                       // Not required
                                   }];
}

- (void)testShouldFetchCustomCloseURL {
    NSURL *url = [NSURL URLWithString:DefaultURL];
    [self.adSyncManager fetchCustomCloseWithURL:url];
    OCMVerify([self.adSyncService fetchCustomCloseWithURL:url]);
}

@end
