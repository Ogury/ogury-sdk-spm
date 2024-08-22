//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OguryInterstitialAdDelegateDispatcher.h"
#import "OguryInterstitialAd.h"
#import "OguryError+Ads.h"

@interface OguryInterstitialAdDelegateDispatcherTests : XCTestCase

@property(strong) id<OguryInterstitialAdDelegate> delegate;
@property(strong) OguryInterstitialAdDelegateDispatcher *delegateDispatcher;

@property(strong) OguryInterstitialAd *interstitial;

@end

@implementation OguryInterstitialAdDelegateDispatcherTests

- (void)setUp {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:NO];

    self.delegate = OCMProtocolMock(@protocol(OguryInterstitialAdDelegate));
    self.delegateDispatcher = [[OguryInterstitialAdDelegateDispatcher alloc] init];
    self.delegateDispatcher.delegate = self.delegate;
    self.interstitial = OCMClassMock([OguryInterstitialAd class]);
    self.delegateDispatcher.interstitial = self.interstitial;
}

- (void)tearDown {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:YES];
}

- (void)testOguryAdsInterstitialAdNotAvailable {
    OguryError *error = [OguryError createNotAvailableError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAdLoaded {
    [self.delegateDispatcher loaded];
    OCMVerify([self.delegate didLoadOguryInterstitialAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAdNotLoaded {
    OguryError *error = [OguryError createNotLoadedError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAdClosed {
    [self.delegateDispatcher closed];
    OCMVerify([self.delegate didCloseOguryInterstitialAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAdDisableError {
    OguryError *error = [OguryError createAdDisabledError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialProfigNotSyncedError {
    OguryError *error = [OguryError createProfigNotSyncedError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialSdkInitNotCalledError {
    OguryError *error = [OguryError createSdkInitNotCalledError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAnotherAdAlreadyDisplayedError {
    OguryError *error = [OguryError createAnotherAdAlreadyDisplayedError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialCantShowAdsInPresentingViewControllerError {
    OguryError *error = [OguryError createCantShowAdsInPresentingViewControllerError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAdExpiredError {
    OguryError *error = [OguryError createAdExpiredError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialUnknownError {
    OguryError *error = [OguryError createUnknownError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAdClicked {
    [self.delegateDispatcher clicked];
    OCMVerify([self.delegate didClickOguryInterstitialAd:self.interstitial]);
}

- (void)testShouldTriggerOnAdImpression {
    [self.delegateDispatcher adImpression];

    OCMVerify([self.delegate didTriggerImpressionOguryInterstitialAd:self.interstitial]);
}

@end
