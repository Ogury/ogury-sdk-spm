//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OguryRewardedAdDelegateDispatcher.h"
#import "OguryRewardedAd.h"
#import "OguryAdError.h"
#import "OguryAdError+Internal.h"

@interface OguryRewardedAdDelegateDispatcherTests : XCTestCase

@property(strong) id<OguryRewardedAdDelegate> delegate;
@property(strong) OguryRewardedAdDelegateDispatcher *delegateDispatcher;

@property(strong) OguryRewardedAd *rewardedAd;

@end

@implementation OguryRewardedAdDelegateDispatcherTests

- (void)setUp {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:NO];

    self.delegate = OCMProtocolMock(@protocol(OguryRewardedAdDelegate));
    self.delegateDispatcher = [[OguryRewardedAdDelegateDispatcher alloc] init];
    self.delegateDispatcher.delegate = self.delegate;
    self.rewardedAd = OCMClassMock([OguryRewardedAd class]);
    self.delegateDispatcher.rewardedAd = self.rewardedAd;
}

- (void)tearDown {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:YES];
}

- (void)testOguryAdsRewardedAdNotAvailable {
    OguryError *error = [OguryAdError noFillFrom:OguryAdIntegrationTypeDirect];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.rewardedAd]);
}

- (void)testOguryAdsRewardedAdLoaded {
    [self.delegateDispatcher loaded];
    OCMVerify([self.delegate didLoadOguryRewardedAd:self.rewardedAd]);
}

- (void)testOguryAdsRewardedAdNotLoaded {
    OguryError *error = [OguryAdError noAdLoaded];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.rewardedAd]);
}

- (void)testOguryAdsRewardedAdClosed {
    [self.delegateDispatcher closed];
    OCMVerify([self.delegate didCloseOguryRewardedAd:self.rewardedAd]);
}

- (void)testOguryAdsRewardedAdRewarded {
    OguryRewardItem *rewardItem = OCMClassMock([OguryRewardItem class]);

    [self.delegateDispatcher rewarded:rewardItem];
    OCMVerify([self.delegate didRewardOguryRewardedAdWithItem:rewardItem forAd:self.rewardedAd]);
}

- (void)testOguryAdsRewardedAdDisableError {
    OguryError *error = [OguryAdError adDisabledOtherReasonFrom:OguryAdErrorTypeLoad];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.rewardedAd]);
}

- (void)testOguryAdsRewardedAdUnknownError {
    OguryError *error = [OguryError createOguryErrorWithCode:OGAInternalUnknownError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.rewardedAd]);
}

- (void)testOguryAdsRewardedAdExpiredError {
    OguryError *error = [OguryAdError adExpired];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.rewardedAd]);
}

- (void)testOguryAdsRewardedAdProfigNotSyncedError {
    OguryError *error = [OguryAdError invalidConfigurationFrom:OguryAdErrorTypeLoad];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.rewardedAd]);
}

- (void)testOguryAdsRewardedAdNoInternetConnectionError {
    OguryError *error = [OguryAdError noInternetConnectionError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.rewardedAd]);
}

- (void)testOguryAdsRewardedAdSdkInitNotCalledError {
    OguryError *error = [OguryAdError sdkNotInitializedFrom:OguryAdErrorTypeLoad stackTrace:@""];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.rewardedAd]);
}

- (void)testOguryAdsRewardedAdAnotherAdAlreadyDisplayedError {
    OguryError *error = [OguryAdError anotherAdIsAlreadyDisplayed];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.rewardedAd]);
}

- (void)testOguryAdsRewardedAdCantShowAdsInPresentingViewControllerError {
    OguryError *error = [OguryAdError viewControllerPreventsAdFromBeingDisplayed];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.rewardedAd]);
}

- (void)testOguryAdsRewardedAdClicked {
    [self.delegateDispatcher clicked];
    OCMVerify([self.delegate didClickOguryRewardedAd:self.rewardedAd]);
}

- (void)testShouldTriggerOnAdImpression {
    [self.delegateDispatcher adImpression];
    OCMVerify([self.delegate didTriggerImpressionOguryRewardedAd:self.rewardedAd]);
}

@end
