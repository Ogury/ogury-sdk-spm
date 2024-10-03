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
    OguryAdError *error = [OguryAdError noFillFrom:OguryAdIntegrationTypeDirect];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAd:self.rewardedAd error:error]);
}

- (void)testOguryAdsRewardedAdLoaded {
    [self.delegateDispatcher loaded];
    OCMVerify([self.delegate didLoadOguryRewardedAd:self.rewardedAd]);
}

- (void)testOguryAdsRewardedAdNotLoaded {
    OguryAdError *error = [OguryAdError noAdLoaded];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAd:self.rewardedAd error:error]);
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
    OguryAdError *error = [OguryAdError adDisabledOtherReasonFrom:OguryAdErrorTypeLoad];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAd:self.rewardedAd error:error]);
}

- (void)testOguryAdsRewardedAdUnknownError {
    OguryAdError *error = [OguryAdError createOguryErrorWithCode:OGAInternalUnknownError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAd:self.rewardedAd error:error]);
}

- (void)testOguryAdsRewardedAdExpiredError {
    OguryAdError *error = [OguryAdError adExpired];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAd:self.rewardedAd error:error]);
}

- (void)testOguryAdsRewardedAdProfigNotSyncedError {
    OguryAdError *error = [OguryAdError invalidConfigurationFrom:OguryAdErrorTypeLoad];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAd:self.rewardedAd error:error]);
}

- (void)testOguryAdsRewardedAdNoInternetConnectionError {
    OguryAdError *error = [OguryAdError noInternetConnectionError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAd:self.rewardedAd error:error]);
}

- (void)testOguryAdsRewardedAdSdkInitNotCalledError {
    OguryAdError *error = [OguryAdError sdkNotInitializedFrom:OguryAdErrorTypeLoad stackTrace:@""];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAd:self.rewardedAd error:error]);
}

- (void)testOguryAdsRewardedAdAnotherAdAlreadyDisplayedError {
    OguryAdError *error = [OguryAdError anotherAdIsAlreadyDisplayed];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAd:self.rewardedAd error:error]);
}

- (void)testOguryAdsRewardedAdCantShowAdsInPresentingViewControllerError {
    OguryAdError *error = [OguryAdError viewControllerPreventsAdFromBeingDisplayed];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAd:self.rewardedAd error:error]);
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
