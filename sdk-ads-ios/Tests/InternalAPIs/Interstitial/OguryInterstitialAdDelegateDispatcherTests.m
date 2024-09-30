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
    OguryAdError *error = [OguryAdError noFillFrom:OguryAdIntegrationTypeDirect];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAd:self.interstitial error:error]);
}

- (void)testOguryAdsInterstitialAdLoaded {
    [self.delegateDispatcher loaded];
    OCMVerify([self.delegate didLoadOguryInterstitialAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAdNotLoaded {
    OguryAdError *error = [OguryAdError noAdLoaded];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAd:self.interstitial error:error]);
}

- (void)testOguryAdsInterstitialAdClosed {
    [self.delegateDispatcher closed];
    OCMVerify([self.delegate didCloseOguryInterstitialAd:self.interstitial]);
}

- (void)testOguryAdsInterstitialAdDisableError {
    OguryAdError *error = [OguryAdError adDisabledOtherReasonFrom:OguryAdErrorTypeLoad];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAd:self.interstitial error:error]);
}

- (void)testOguryAdsInterstitialProfigNotSyncedError {
    OguryAdError *error = [OguryAdError invalidConfigurationFrom:OguryAdErrorTypeLoad];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAd:self.interstitial error:error]);
}

- (void)testOguryAdsInterstitialSdkInitNotCalledError {
    OguryAdError *error = [OguryAdError sdkNotInitializedFrom:OguryAdErrorTypeLoad stackTrace:@""];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAd:self.interstitial error:error]);
}

- (void)testOguryAdsInterstitialAnotherAdAlreadyDisplayedError {
    OguryAdError *error = [OguryAdError anotherAdIsAlreadyDisplayed];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAd:self.interstitial error:error]);
}

- (void)testOguryAdsInterstitialCantShowAdsInPresentingViewControllerError {
    OguryAdError *error = [OguryAdError viewControllerPreventsAdFromBeingDisplayed];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAd:self.interstitial error:error]);
}

- (void)testOguryAdsInterstitialAdExpiredError {
    OguryAdError *error = [OguryAdError adExpired];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAd:self.interstitial error:error]);
}

- (void)testOguryAdsInterstitialUnknownError {
    OguryAdError *error = [OguryAdError createOguryErrorWithCode:OGAInternalUnknownError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryInterstitialAd:self.interstitial error:error]);
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
