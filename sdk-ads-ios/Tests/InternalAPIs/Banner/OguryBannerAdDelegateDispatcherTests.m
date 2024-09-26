//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OguryBannerAdViewDelegateDispatcher.h"
#import "OguryBannerAdView.h"
#import "OguryAdError.h"
#import "OguryAdError+Internal.h"

@interface OguryBannerAdDelegateDispatcherTests : XCTestCase

#pragma mark - Properties

@property(nonatomic, strong) id<OguryBannerAdDelegate> delegate;
@property(nonatomic, strong) OguryBannerAdViewDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OguryBannerAdView *banner;

@end

@implementation OguryBannerAdDelegateDispatcherTests

#pragma mark - Methods

- (void)setUp {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:NO];

    self.delegate = OCMProtocolMock(@protocol(OguryBannerAdDelegate));
    self.banner = OCMClassMock([OguryBannerAdView class]);

    self.delegateDispatcher = [[OguryBannerAdViewDelegateDispatcher alloc] init];
    self.delegateDispatcher.delegate = self.delegate;
    self.delegateDispatcher.banner = self.banner;
}

- (void)tearDown {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:YES];
}

- (void)testOguryAdsBannerAdNotAvailable {
    OguryError *error = [OguryAdError noFillFrom:OguryAdIntegrationTypeDirect];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerAdLoaded {
    [self.delegateDispatcher loaded];

    OCMVerify([self.delegate didLoadOguryBannerAdView:self.banner]);
}

- (void)testOguryAdsBannerAdNotLoaded {
    OguryError *error = [OguryAdError noAdLoaded];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerAdClosed {
    [self.delegateDispatcher closed];

    OCMVerify([self.delegate didCloseOguryBannerAdView:self.banner]);
}

- (void)testOguryAdsBannerAdDisableError {
    OguryError *error = [OguryAdError adDisabledOtherReasonFrom:OguryAdErrorTypeLoad];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerProfigNotSyncedError {
    OguryError *error = [OguryAdError invalidConfigurationFrom:OguryAdErrorTypeLoad];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerSdkInitNotCalledError {
    OguryError *error = [OguryAdError sdkNotInitializedFrom:OguryAdErrorTypeLoad stackTrace:@""];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerAnotherAdAlreadyDisplayedError {
    OguryError *error = [OguryAdError anotherAdIsAlreadyDisplayed];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerCantShowAdsInPresentingViewControllerError {
    OguryError *error = [OguryAdError viewControllerPreventsAdFromBeingDisplayed];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerAdExpiredError {
    OguryError *error = [OguryAdError adExpired];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerUnknownError {
    OguryError *error = [OguryAdError createOguryErrorWithCode:OGAInternalUnknownError];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate didFailOguryBannerAdWithError:error forAd:self.banner]);
}

- (void)testOguryAdsBannerAdClicked {
    [self.delegateDispatcher clicked];

    OCMVerify([self.delegate didClickOguryBannerAdView:self.banner]);
}

- (void)testShouldTriggerOnAdImpression {
    [self.delegateDispatcher adImpression];

    OCMVerify([self.delegate didTriggerImpressionOguryBannerAdView:self.banner]);
}

@end
