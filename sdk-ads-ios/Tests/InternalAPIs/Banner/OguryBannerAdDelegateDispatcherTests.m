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
    OguryAdError *error = [OguryAdError noFillFrom:OguryAdIntegrationTypeDirect];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate oguryBannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerAdLoaded {
    [self.delegateDispatcher loaded];

    OCMVerify([self.delegate oguryBannerAdViewDidLoad:self.banner]);
}

- (void)testOguryAdsBannerAdNotLoaded {
    OguryAdError *error = [OguryAdError noAdLoaded];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate oguryBannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerAdClosed {
    [self.delegateDispatcher closed];

    OCMVerify([self.delegate oguryBannerAdViewDidClose:self.banner]);
}

- (void)testOguryAdsBannerAdDisableError {
    OguryAdError *error = [OguryAdError adDisabledOtherReasonFrom:OguryAdErrorTypeLoad];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate oguryBannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerProfigNotSyncedError {
    OguryAdError *error = [OguryAdError invalidConfigurationFrom:OguryAdErrorTypeLoad];
    [self.delegateDispatcher failedWithError:error];
    OCMVerify([self.delegate oguryBannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerSdkInitNotCalledError {
    OguryAdError *error = [OguryAdError sdkNotInitializedFrom:OguryAdErrorTypeLoad stackTrace:@""];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate oguryBannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerAnotherAdAlreadyDisplayedError {
    OguryAdError *error = [OguryAdError anotherAdIsAlreadyDisplayed];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate oguryBannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerCantShowAdsInPresentingViewControllerError {
    OguryAdError *error = [OguryAdError viewControllerPreventsAdFromBeingDisplayed];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate oguryBannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerAdExpiredError {
    OguryAdError *error = [OguryAdError adExpired];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate oguryBannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerUnknownError {
    OguryAdError *error = [OguryAdError createOguryErrorWithCode:OGAInternalUnknownError];

    [self.delegateDispatcher failedWithError:error];

    OCMVerify([self.delegate oguryBannerAdView:self.banner didFailWithError:error]);
}

- (void)testOguryAdsBannerAdClicked {
    [self.delegateDispatcher clicked];

    OCMVerify([self.delegate oguryBannerAdViewDidClick:self.banner]);
}

- (void)testShouldTriggerOnAdImpression {
    [self.delegateDispatcher adImpression];

    OCMVerify([self.delegate oguryBannerAdViewDidTriggerImpression:self.banner]);
}

@end
