//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OguryRewardedAdDelegateDispatcher.h"
#import "OguryRewardedAd.h"
#import "OguryAdsError.h"
#import "OguryError+Ads.h"

@interface OguryRewardedAdDelegateDispatcherTests : XCTestCase

@property(strong) id<OguryRewardedAdDelegate> delegate;
@property(strong) OguryRewardedAdDelegateDispatcher *delegateDispatcher;

@property(strong) OguryRewardedAd *optin;

@end

@implementation OguryRewardedAdDelegateDispatcherTests

- (void)setUp {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:NO];

    self.delegate = OCMProtocolMock(@protocol(OguryRewardedAdDelegate));
    self.delegateDispatcher = [[OguryRewardedAdDelegateDispatcher alloc] init];
    self.delegateDispatcher.delegate = self.delegate;
    self.optin = OCMClassMock([OguryRewardedAd class]);
    self.delegateDispatcher.optinVideo = self.optin;
}

- (void)tearDown {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:YES];
}

- (void)testOguryAdsRewardedAdNotAvailable {
    OguryError *error = [OguryAdsError noFillFrom:OguryAdsIntegrationTypeDirect];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdLoaded {
    [self.delegateDispatcher loaded];
    OCMVerify([self.delegate didLoadOguryRewardedAd:self.optin]);
}

- (void)testOguryAdsRewardedAdNotLoaded {
    OguryError *error = [OguryAdsError noAdLoaded];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdClosed {
    [self.delegateDispatcher closed];
    OCMVerify([self.delegate didCloseOguryRewardedAd:self.optin]);
}

- (void)testOguryAdsRewardedAdRewarded {
    OGARewardItem *rewardItem = OCMClassMock([OGARewardItem class]);

    [self.delegateDispatcher rewarded:rewardItem];
    OCMVerify([self.delegate didRewardOguryRewardedAdWithItem:rewardItem forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdDisableError {
    OguryError *error = [OguryAdsError adDisabledOtherReasonFrom:OguryInternalAdsErrorOriginLoad];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdUnknownError {
    OguryError *error = [OguryError createOguryErrorWithCode:OGAInternalUnknownError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdExpiredError {
    OguryError *error = [OguryAdsError adExpired];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdProfigNotSyncedError {
    OguryError *error = [OguryAdsError invalidConfigurationFrom:OguryInternalAdsErrorOriginLoad];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdNoInternetConnectionError {
    OguryError *error = [OguryAdsError noInternetConnectionError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdSdkInitNotCalledError {
    OguryError *error = [OguryAdsError sdkNotInitializedFrom:OguryInternalAdsErrorOriginLoad stackTrace:@""];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdAnotherAdAlreadyDisplayedError {
    OguryError *error = [OguryAdsError anotherAdIsAlreadyDisplayed];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdCantShowAdsInPresentingViewControllerError {
    OguryError *error = [OguryAdsError viewControllerPreventsAdFromBeingDisplayed];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdClicked {
    [self.delegateDispatcher clicked];
    OCMVerify([self.delegate didClickOguryRewardedAd:self.optin]);
}

- (void)testShouldTriggerOnAdImpression {
    [self.delegateDispatcher adImpression];
    OCMVerify([self.delegate didTriggerImpressionOguryRewardedAd:self.optin]);
}

@end
