//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OguryBannerAdViewDelegateDispatcher.h"
#import "OguryBannerAdView.h"
#import "OguryAdError.h"
#import "OguryAdError+Internal.h"

@interface OguryBannerAdViewDelegateDispatcherTests : XCTestCase

#pragma mark - Properties

@property(nonatomic, strong) id<OguryBannerAdViewDelegate> delegate;
@property(nonatomic, strong) OguryBannerAdViewDelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OguryBannerAdView *banner;

@end

@implementation OguryBannerAdViewDelegateDispatcherTests

#pragma mark - Methods

- (void)setUp {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:NO];

    self.delegate = OCMProtocolMock(@protocol(OguryBannerAdViewDelegate));
    self.banner = OCMClassMock([OguryBannerAdView class]);

    self.delegateDispatcher = [[OguryBannerAdViewDelegateDispatcher alloc] init];
    self.delegateDispatcher.delegate = self.delegate;
    self.delegateDispatcher.banner = self.banner;
}

- (void)tearDown {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:YES];
}

- (void)testOguryAdsBannerAdNotAvailable {
    OguryAdError *error = [OguryAdError noFillFrom:OguryAdIntegrationTypeDirect];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate bannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerAdLoaded {
    [self.delegateDispatcher loaded];

    OCMVerify([self.delegate bannerAdViewDidLoad:self.banner]);
}

- (void)testOguryAdsBannerAdNotLoaded {
    OguryAdError *error = [OguryAdError noAdLoaded];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate bannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerAdClosed {
    [self.delegateDispatcher closed];

    OCMVerify([self.delegate bannerAdViewDidClose:self.banner]);
}

- (void)testOguryAdsBannerAdDisableError {
    OguryAdError *error = [OguryAdError adDisabledOtherReasonFrom:OguryAdErrorTypeLoad];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate bannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerProfigNotSyncedError {
    OguryAdError *error = [OguryAdError invalidConfigurationFrom:OguryAdErrorTypeLoad];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate bannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerSdkInitNotCalledError {
    OguryAdError *error = [OguryAdError sdkNotInitializedFrom:OguryAdErrorTypeLoad];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate bannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerAnotherAdAlreadyDisplayedError {
    OguryAdError *error = [OguryAdError anotherAdIsAlreadyDisplayed];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate bannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerCantShowAdsInPresentingViewControllerError {
    OguryAdError *error = [OguryAdError viewControllerPreventsAdFromBeingDisplayed];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate bannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerAdExpiredError {
    OguryAdError *error = [OguryAdError adExpired];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate bannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerUnknownError {
    OguryAdError *error = [OguryAdError createOguryErrorWithCode:OGAInternalUnknownError];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate bannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerAdClicked {
    [self.delegateDispatcher clicked];

    OCMVerify([self.delegate bannerAdViewDidClick:self.banner]);
}

- (void)testShouldTriggerOnAdImpression {
    [self.delegateDispatcher adImpression];

    OCMVerify([self.delegate bannerAdViewDidTriggerImpression:self.banner]);
}

@end
