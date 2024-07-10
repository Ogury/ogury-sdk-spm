//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OguryAdsInterstitialDelegateDispatcher.h"

@interface OguryAdsInterstitialDelegateDispatcherTests : XCTestCase

@property(strong) id<OguryAdsInterstitialDelegate> delegate;
@property(strong) OguryAdsInterstitialDelegateDispatcher *delegateDispatcher;

@end

@implementation OguryAdsInterstitialDelegateDispatcherTests

- (void)setUp {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:NO];

    self.delegate = OCMProtocolMock(@protocol(OguryAdsInterstitialDelegate));
    self.delegateDispatcher = [[OguryAdsInterstitialDelegateDispatcher alloc] init];
    self.delegateDispatcher.delegate = self.delegate;
}

- (void)tearDown {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:YES];
}

- (void)testOguryAdsInterstitialAdNotAvailable {
    [self.delegateDispatcher failedWithError:[OguryError createNotAvailableError]];
    OCMVerify([self.delegate oguryAdsInterstitialAdNotAvailable]);
}

- (void)testOguryAdsInterstitialAdLoaded {
    [self.delegateDispatcher loaded];
    OCMVerify([self.delegate oguryAdsInterstitialAdLoaded]);
}

- (void)testOguryAdsInterstitialAdNotLoaded {
    [self.delegateDispatcher failedWithError:[OguryError createNotLoadedError]];
    OCMVerify([self.delegate oguryAdsInterstitialAdNotLoaded]);
}

- (void)testOguryAdsInterstitialAdDisplayed {
    [self.delegateDispatcher displayed];
    OCMVerify([self.delegate oguryAdsInterstitialAdDisplayed]);
}

- (void)testOguryAdsInterstitialAdClosed {
    [self.delegateDispatcher closed];
    OCMVerify([self.delegate oguryAdsInterstitialAdClosed]);
}

- (void)testOguryAdsInterstitialAdDisableError {
    [self.delegateDispatcher failedWithError:[OguryError createAdDisabledError]];
    OCMVerify([self.delegate oguryAdsInterstitialAdError:OguryAdsErrorAdDisable]);
}

- (void)testOguryAdsInterstitialProfigNotSyncedError {
    [self.delegateDispatcher failedWithError:[OguryError createProfigNotSyncedError]];
    OCMVerify([self.delegate oguryAdsInterstitialAdError:OguryAdsErrorProfigNotSynced]);
}

- (void)testOguryAdsInterstitialSdkInitNotCalledError {
    [self.delegateDispatcher failedWithError:[OguryError createSdkInitNotCalledError]];
    OCMVerify([self.delegate oguryAdsInterstitialAdError:OguryAdsErrorSdkInitNotCalled]);
}

- (void)testOguryAdsInterstitialAnotherAdAlreadyDisplayedError {
    [self.delegateDispatcher failedWithError:[OguryError createAnotherAdAlreadyDisplayedError]];
    OCMVerify([self.delegate oguryAdsInterstitialAdError:OguryAdsErrorAnotherAdAlreadyDisplayed]);
}

- (void)testOguryAdsInterstitialCantShowAdsInPresentingViewControllerError {
    [self.delegateDispatcher failedWithError:[OguryError createCantShowAdsInPresentingViewControllerError]];
    OCMVerify([self.delegate oguryAdsInterstitialAdError:OguryAdsErrorCantShowAdsInPresentingViewController]);
}

- (void)testOguryAdsInterstitialAdExpiredError {
    [self.delegateDispatcher failedWithError:[OguryError createAdExpiredError]];
    OCMVerify([self.delegate oguryAdsInterstitialAdError:OguryAdsErrorAdExpired]);
}

- (void)testOguryAdsInterstitialUnknownError {
    [self.delegateDispatcher failedWithError:[OguryError createUnknownError]];
    OCMVerify([self.delegate oguryAdsInterstitialAdError:OguryAdsErrorUnknown]);
}

- (void)testOguryAdsInterstitialAdClicked {
    [self.delegateDispatcher clicked];
    OCMVerify([self.delegate oguryAdsInterstitialAdClicked]);
}

- (void)testShouldTriggerOnAdAdImpression {
    [self.delegateDispatcher adImpression];

    OCMVerify([self.delegate oguryAdsInterstitialAdOnAdImpression]);
}

@end
