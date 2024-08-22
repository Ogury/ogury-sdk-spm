//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OguryRewardedAdDelegateDispatcher.h"
#import "OguryRewardedAd.h"
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
    OguryError *error = [OguryError createNotAvailableError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdLoaded {
    [self.delegateDispatcher loaded];
    OCMVerify([self.delegate didLoadOguryRewardedAd:self.optin]);
}

- (void)testOguryAdsRewardedAdNotLoaded {
    OguryError *error = [OguryError createNotLoadedError];
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
    OguryError *error = [OguryError createAdDisabledError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdUnknownError {
    OguryError *error = [OguryError createUnknownError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdExpiredError {
    OguryError *error = [OguryError createAdExpiredError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdProfigNotSyncedError {
    OguryError *error = [OguryError createProfigNotSyncedError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdNoInternetConnectionError {
    OguryError *error = [OguryError noInternetConnectionError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdSdkInitNotCalledError {
    OguryError *error = [OguryError createSdkInitNotCalledError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdAnotherAdAlreadyDisplayedError {
    OguryError *error = [OguryError createAnotherAdAlreadyDisplayedError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryRewardedAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsRewardedAdCantShowAdsInPresentingViewControllerError {
    OguryError *error = [OguryError createCantShowAdsInPresentingViewControllerError];
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
