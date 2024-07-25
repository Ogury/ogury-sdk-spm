//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OguryAdsBanner.h"
#import "OguryAdsBannerDelegateDispatcher.h"

@interface OguryAdsBannerDelegateDispatcherTests : XCTestCase

#pragma mark - Properties

@property(nonatomic, strong) OguryAdsBanner *banner;
@property(nonatomic, strong) id<OguryAdsBannerDelegate> delegate;
@property(nonatomic, strong) OguryAdsBannerDelegateDispatcher *delegateDispatcher;

@end

@implementation OguryAdsBannerDelegateDispatcherTests

#pragma mark - Methods

- (void)setUp {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:NO];

    self.banner = OCMClassMock([OguryAdsBanner class]);
    self.delegate = OCMProtocolMock(@protocol(OguryAdsBannerDelegate));

    self.delegateDispatcher = [[OguryAdsBannerDelegateDispatcher alloc] init];
    self.delegateDispatcher.banner = self.banner;
    self.delegateDispatcher.delegate = self.delegate;
}

- (void)tearDown {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:YES];
}

- (void)testOguryAdsInterstitialAdNotAvailable {
    [self.delegateDispatcher failedWithError:[OguryError createNotAvailableError]];
    OCMVerify([self.delegate oguryAdsBannerAdNotAvailable:self.banner]);
}

- (void)testOguryAdsInterstitialAdLoaded {
    [self.delegateDispatcher loaded];
    OCMVerify([self.delegate oguryAdsBannerAdLoaded:self.banner]);
}

- (void)testOguryAdsInterstitialAdNotLoaded {
    [self.delegateDispatcher failedWithError:[OguryError createNotLoadedError]];
    OCMVerify([self.delegate oguryAdsBannerAdNotLoaded:self.banner]);
}

- (void)testOguryAdsInterstitialAdDisplayed {
    [self.delegateDispatcher displayed];
    OCMVerify([self.delegate oguryAdsBannerAdDisplayed:self.banner]);
}

- (void)testOguryAdsInterstitialAdClosed {
    [self.delegateDispatcher closed];
    OCMVerify([self.delegate oguryAdsBannerAdClosed:self.banner]);
}

- (void)testOguryAdsInterstitialAdDisableError {
    [self.delegateDispatcher failedWithError:[OguryError createAdDisabledError]];
    OCMVerify([self.delegate oguryAdsBannerAdError:OguryAdsErrorAdDisable forBanner:self.banner]);
}

- (void)testOguryAdsInterstitialProfigNotSyncedError {
    [self.delegateDispatcher failedWithError:[OguryError createProfigNotSyncedError]];
    OCMVerify([self.delegate oguryAdsBannerAdError:OguryAdsErrorProfigNotSynced forBanner:self.banner]);
}

- (void)testOguryAdsInterstitialSdkInitNotCalledError {
    [self.delegateDispatcher failedWithError:[OguryError createSdkInitNotCalledError]];
    OCMVerify([self.delegate oguryAdsBannerAdError:OguryAdsErrorSdkInitNotCalled forBanner:self.banner]);
}

- (void)testOguryAdsInterstitialAnotherAdAlreadyDisplayedError {
    [self.delegateDispatcher failedWithError:[OguryError createAnotherAdAlreadyDisplayedError]];
    OCMVerify([self.delegate oguryAdsBannerAdError:OguryAdsErrorAnotherAdAlreadyDisplayed forBanner:self.banner]);
}

- (void)testOguryAdsInterstitialCantShowAdsInPresentingViewControllerError {
    [self.delegateDispatcher failedWithError:[OguryError createCantShowAdsInPresentingViewControllerError]];
    OCMVerify([self.delegate oguryAdsBannerAdError:OguryAdsErrorCantShowAdsInPresentingViewController forBanner:self.banner]);
}

- (void)testOguryAdsInterstitialAdExpiredError {
    [self.delegateDispatcher failedWithError:[OguryError createAdExpiredError]];
    OCMVerify([self.delegate oguryAdsBannerAdError:OguryAdsErrorAdExpired forBanner:self.banner]);
}

- (void)testOguryAdsInterstitialUnknownError {
    [self.delegateDispatcher failedWithError:[OguryError createUnknownError]];
    OCMVerify([self.delegate oguryAdsBannerAdError:OguryAdsErrorUnknown forBanner:self.banner]);
}

- (void)testOguryAdsInterstitialAdClicked {
    [self.delegateDispatcher clicked];
    OCMVerify([self.delegate oguryAdsBannerAdClicked:self.banner]);
}

- (void)testShouldTriggerOnAdAdImpression {
    [self.delegateDispatcher adImpression];

    OCMVerify([self.delegate oguryAdsBannerAdOnAdImpression]);
}

@end
