//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OguryInterstitialAdDelegateDispatcher.h"
#import "OguryInterstitialAd.h"
#import "OguryAdError.h"
#import "OguryAdError+Internal.h"

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
    OguryError *error = [OguryAdError noFillFrom:OguryAdIntegrationTypeDirect];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAdLoaded {
    [self.delegateDispatcher loaded];
    OCMVerify([self.delegate didLoadOguryInterstitialAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAdNotLoaded {
    OguryError *error = [OguryAdError noAdLoaded];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAdClosed {
    [self.delegateDispatcher closed];
    OCMVerify([self.delegate didCloseOguryInterstitialAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAdDisableError {
    OguryError *error = [OguryAdError adDisabledOtherReasonFrom:OguryAdErrorTypeLoad];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialProfigNotSyncedError {
    OguryError *error = [OguryAdError invalidConfigurationFrom:OguryAdErrorTypeLoad];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialSdkInitNotCalledError {
    OguryError *error = [OguryAdError sdkNotInitializedFrom:OguryAdErrorTypeLoad stackTrace:@""];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAnotherAdAlreadyDisplayedError {
    OguryError *error = [OguryAdError anotherAdIsAlreadyDisplayed];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialCantShowAdsInPresentingViewControllerError {
    OguryError *error = [OguryAdError viewControllerPreventsAdFromBeingDisplayed];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAdExpiredError {
    OguryError *error = [OguryAdError adExpired];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAdWithError:error forAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialUnknownError {
    OguryError *error = [OguryAdError createOguryErrorWithCode:OGAInternalUnknownError];
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
