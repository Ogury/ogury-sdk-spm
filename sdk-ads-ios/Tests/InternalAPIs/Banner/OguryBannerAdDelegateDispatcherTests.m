//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OguryBannerAdDelegateDispatcher.h"
#import "OguryBannerAd.h"
#import "OguryAdsError.h"
#import "OguryError+Ads.h"

@interface OguryBannerAdDelegateDispatcherTests : XCTestCase

#pragma mark - Properties

@property(nonatomic, strong) id<OguryBannerAdDelegate> delegate;
@property(nonatomic, strong) OguryBannerAdDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OguryBannerAd *banner;

@end

@implementation OguryBannerAdDelegateDispatcherTests

#pragma mark - Methods

- (void)setUp {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:NO];

    self.delegate = OCMProtocolMock(@protocol(OguryBannerAdDelegate));
    self.banner = OCMClassMock([OguryBannerAd class]);

    self.delegateDispatcher = [[OguryBannerAdDelegateDispatcher alloc] init];
    self.delegateDispatcher.delegate = self.delegate;
    self.delegateDispatcher.banner = self.banner;
}

- (void)tearDown {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:YES];
}

- (void)testOguryAdsBannerAdNotAvailable {
    OguryError *error = [OguryAdsError noFillFrom:OguryAdsIntegrationTypeDirect];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerAdLoaded {
    [self.delegateDispatcher loaded];

    OCMVerify([self.delegate didLoadOguryBannerAd:self.banner]);
}

- (void)testOguryAdsBannerAdNotLoaded {
    OguryError *error = [OguryAdsError noAdLoaded];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerAdClosed {
    [self.delegateDispatcher closed];

    OCMVerify([self.delegate didCloseOguryBannerAd:self.banner]);
}

- (void)testOguryAdsBannerAdDisableError {
    OguryError *error = [OguryAdsError adDisabledOtherReasonFrom:OguryInternalAdsErrorOriginLoad];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerProfigNotSyncedError {
    OguryError *error = [OguryAdsError invalidConfigurationFrom:OguryInternalAdsErrorOriginLoad];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerSdkInitNotCalledError {
    OguryError *error = [OguryAdsError sdkNotInitializedFrom:OguryInternalAdsErrorOriginLoad stackTrace:@""];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerAnotherAdAlreadyDisplayedError {
    OguryError *error = [OguryAdsError anotherAdIsAlreadyDisplayed];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerCantShowAdsInPresentingViewControllerError {
    OguryError *error = [OguryAdsError viewControllerPreventsAdFromBeingDisplayed];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerAdExpiredError {
    OguryError *error = [OguryAdsError adExpired];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerUnknownError {
    OguryError *error = [OguryAdsError createOguryErrorWithCode:OGAInternalUnknownError];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerAdClicked {
    [self.delegateDispatcher clicked];

    OCMVerify([self.delegate didClickOguryBannerAd:self.banner]);
}

- (void)testShouldTriggerOnAdImpression {
    [self.delegateDispatcher adImpression];

    OCMVerify([self.delegate didTriggerImpressionOguryBannerAd:self.banner]);
}

@end
