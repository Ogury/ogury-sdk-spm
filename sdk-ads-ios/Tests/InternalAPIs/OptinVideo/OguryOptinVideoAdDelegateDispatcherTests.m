//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OguryOptinVideoAdDelegateDispatcher.h"
#import "OguryOptinVideoAd.h"
#import "OguryError+Ads.h"

@interface OguryOptinVideoAdDelegateDispatcherTests : XCTestCase

@property(strong) id<OguryOptinVideoAdDelegate> delegate;
@property(strong) OguryOptinVideoAdDelegateDispatcher *delegateDispatcher;

@property(strong) OguryOptinVideoAd *optin;

@end

@implementation OguryOptinVideoAdDelegateDispatcherTests

- (void)setUp {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:NO];

    self.delegate = OCMProtocolMock(@protocol(OguryOptinVideoAdDelegate));
    self.delegateDispatcher = [[OguryOptinVideoAdDelegateDispatcher alloc] init];
    self.delegateDispatcher.delegate = self.delegate;
    self.optin = OCMClassMock([OguryOptinVideoAd class]);
    self.delegateDispatcher.optinVideo = self.optin;
}

- (void)tearDown {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:YES];
}

- (void)testOguryAdsOptinVideoAdNotAvailable {
    OguryError *error = [OguryError createNotAvailableError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryOptinVideoAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsOptinVideoAdLoaded {
    [self.delegateDispatcher loaded];
    OCMVerify([self.delegate didLoadOguryOptinVideoAd:self.optin]);
}

- (void)testOguryAdsOptinVideoAdNotLoaded {
    OguryError *error = [OguryError createNotLoadedError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryOptinVideoAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsOptinVideoAdDisplayed {
    [self.delegateDispatcher displayed];
    OCMVerify([self.delegate didDisplayOguryOptinVideoAd:self.optin]);
}

- (void)testOguryAdsOptinVideoAdClosed {
    [self.delegateDispatcher closed];
    OCMVerify([self.delegate didCloseOguryOptinVideoAd:self.optin]);
}

- (void)testOguryAdsOptinVideoAdRewarded {
    OGARewardItem *rewardItem = OCMClassMock([OGARewardItem class]);

    [self.delegateDispatcher rewarded:rewardItem];
    OCMVerify([self.delegate didRewardOguryOptinVideoAdWithItem:rewardItem forAd:self.optin]);
}

- (void)testOguryAdsOptinVideoAdDisableError {
    OguryError *error = [OguryError createAdDisabledError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryOptinVideoAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsOptinVideoAdUnknownError {
    OguryError *error = [OguryError createUnknownError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryOptinVideoAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsOptinVideoAdExpiredError {
    OguryError *error = [OguryError createAdExpiredError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryOptinVideoAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsOptinVideoAdProfigNotSyncedError {
    OguryError *error = [OguryError createProfigNotSyncedError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryOptinVideoAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsOptinVideoAdNoInternetConnectionError {
    OguryError *error = [OguryError noInternetConnectionError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryOptinVideoAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsOptinVideoAdSdkInitNotCalledError {
    OguryError *error = [OguryError createSdkInitNotCalledError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryOptinVideoAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsOptinVideoAdAnotherAdAlreadyDisplayedError {
    OguryError *error = [OguryError createAnotherAdAlreadyDisplayedError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryOptinVideoAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsOptinVideoAdCantShowAdsInPresentingViewControllerError {
    OguryError *error = [OguryError createCantShowAdsInPresentingViewControllerError];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryOptinVideoAdWithError:error forAd:self.optin]);
}

- (void)testOguryAdsOptinVideoAdClicked {
    [self.delegateDispatcher clicked];
    OCMVerify([self.delegate didClickOguryOptinVideoAd:self.optin]);
}

- (void)testShouldTriggerOnAdImpression {
    [self.delegateDispatcher adImpression];
    OCMVerify([self.delegate didTriggerImpressionOguryOptinVideoAd:self.optin]);
}

@end
