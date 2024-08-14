//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OguryAds/OguryAds.h>

#import <OCMock/OCMock.h>
#import "OGAInternal+Private.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

NSString *const OguryAdsTestsAssetKey = @"asset-key";
NSString *const OguryAdsTestsMediationName = @"AdinCube";

@interface OguryAdsTests : XCTestCase

@property(nonatomic, retain) OGAInternal *internal;
@property(nonatomic, retain) OguryAds *oguryAds;

@end

@interface OguryAds (Testing)

- (instancetype)initWithInternal:(OGAInternal *)internal;

- (void)resetSDK;

- (void)privateMethodchangeServerEnvironment:(NSString *)environment;

@end

@implementation OguryAdsTests

- (void)setUp {
    self.internal = OCMClassMock([OGAInternal class]);
    self.oguryAds = [[OguryAds alloc] initWithInternal:self.internal];
}

- (void)testSetupWithAssetKey {
    [self.oguryAds setupWithAssetKey:OguryAdsTestsAssetKey];

    OCMVerify([self.internal startWithAssetKey:OguryAdsTestsAssetKey]);
}

- (void)setupWithAssetKeyAndCompletionHandler {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion handler is called."];

    [self.oguryAds setupWithAssetKey:OguryAdsTestsAssetKey
                andCompletionHandler:^(NSError *error) {
                    XCTAssertNil(error);
                    [expectation fulfill];
                }];

    [self waitForExpectationsWithTimeout:0.5
                                 handler:^(NSError *error) {
                                     OCMVerify([self.internal startWithAssetKey:OguryAdsTestsAssetKey]);
                                 }];
}

- (void)testSetupWithAssetKeyAndMediationName {
    [self.oguryAds setupWithAssetKey:OguryAdsTestsAssetKey andMediationName:OguryAdsTestsMediationName];

    OCMVerify([self.internal startWithAssetKey:OguryAdsTestsAssetKey]);
}

- (void)testSetupWithAssetKeyMediationNameAndCompletionHandler {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion handler is called."];

    [self.oguryAds setupWithAssetKey:OguryAdsTestsAssetKey
                       mediationName:OguryAdsTestsMediationName
                andCompletionHandler:^(NSError *error) {
                    XCTAssertNil(error);
                    [expectation fulfill];
                }];

    [self waitForExpectationsWithTimeout:0.5
                                 handler:^(NSError *error) {
                                     OCMVerify([self.internal startWithAssetKey:OguryAdsTestsAssetKey]);
                                 }];
}

- (void)testResetSDK {
    [self.oguryAds resetSDK];

    OCMVerify([self.internal resetSDK]);
}

@end

#pragma clang diagnostic pop
