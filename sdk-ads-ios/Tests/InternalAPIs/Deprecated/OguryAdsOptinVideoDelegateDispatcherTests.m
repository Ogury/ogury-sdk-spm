//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OguryAdsOptinVideoDelegateDispatcher.h"

@interface OguryAdsOptinVideoDelegateDispatcherTests : XCTestCase

@property(strong) id<OguryAdsOptinVideoDelegate> delegate;
@property(strong) OguryAdsOptinVideoDelegateDispatcher *delegateDispatcher;

@end

@implementation OguryAdsOptinVideoDelegateDispatcherTests

- (void)setUp {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:NO];

    self.delegate = OCMProtocolMock(@protocol(OguryAdsOptinVideoDelegate));
    self.delegateDispatcher = [[OguryAdsOptinVideoDelegateDispatcher alloc] init];
    self.delegateDispatcher.delegate = self.delegate;
}

- (void)tearDown {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:YES];
}

- (void)testOguryAdsOptinVideoAdNotAvailable {
    [self.delegateDispatcher failedWithError:[OguryError createNotAvailableError]];
    OCMVerify([self.delegate oguryAdsOptinVideoAdNotAvailable]);
}

- (void)testOguryAdsOptinVideoAdLoaded {
    [self.delegateDispatcher loaded];
    OCMVerify([self.delegate oguryAdsOptinVideoAdLoaded]);
}

- (void)testOguryAdsOptinVideoAdNotLoaded {
    [self.delegateDispatcher failedWithError:[OguryError createNotLoadedError]];
    OCMVerify([self.delegate oguryAdsOptinVideoAdNotLoaded]);
}

- (void)testOguryAdsOptinVideoAdDisplayed {
    [self.delegateDispatcher displayed];
    OCMVerify([self.delegate oguryAdsOptinVideoAdDisplayed]);
}

- (void)testOguryAdsOptinVideoAdClosed {
    [self.delegateDispatcher closed];
    OCMVerify([self.delegate oguryAdsOptinVideoAdClosed]);
}

- (void)testOguryAdsOptinVideoAdRewarded {
    OGARewardItem *rewardItem = OCMClassMock([OGARewardItem class]);

    [self.delegateDispatcher rewarded:rewardItem];
    OCMVerify([self.delegate oguryAdsOptinVideoAdRewarded:rewardItem]);
}

- (void)testOguryAdsOptinVideoAdDisableError {
    [self.delegateDispatcher failedWithError:[OguryError createAdDisabledError]];
    OCMVerify([self.delegate oguryAdsOptinVideoAdError:OguryAdsErrorAdDisable]);
}

- (void)testOguryAdsOptinVideoAdUnknownError {
    [self.delegateDispatcher failedWithError:[OguryError createUnknownError]];
    OCMVerify([self.delegate oguryAdsOptinVideoAdError:OguryAdsErrorUnknown]);
}

- (void)testOguryAdsOptinVideoAdExpiredError {
    [self.delegateDispatcher failedWithError:[OguryError createAdExpiredError]];
    OCMVerify([self.delegate oguryAdsOptinVideoAdError:OguryAdsErrorAdExpired]);
}

- (void)testOguryAdsOptinVideoAdProfigNotSyncedError {
    [self.delegateDispatcher failedWithError:[OguryError createProfigNotSyncedError]];
    OCMVerify([self.delegate oguryAdsOptinVideoAdError:OguryAdsErrorProfigNotSynced]);
}

- (void)testOguryAdsOptinVideoAdNoInternetConnectionError {
    [self.delegateDispatcher failedWithError:[OguryError noInternetConnectionError]];
    OCMVerify([self.delegate oguryAdsOptinVideoAdError:OguryAdsErrorNoInternetConnection]);
}

- (void)testOguryAdsOptinVideoAdSdkInitNotCalledError {
    [self.delegateDispatcher failedWithError:[OguryError createSdkInitNotCalledError]];
    OCMVerify([self.delegate oguryAdsOptinVideoAdError:OguryAdsErrorSdkInitNotCalled]);
}

- (void)testOguryAdsOptinVideoAdAnotherAdAlreadyDisplayedError {
    [self.delegateDispatcher failedWithError:[OguryError createAnotherAdAlreadyDisplayedError]];
    OCMVerify([self.delegate oguryAdsOptinVideoAdError:OguryAdsErrorAnotherAdAlreadyDisplayed]);
}

- (void)testOguryAdsOptinVideoAdCantShowAdsInPresentingViewControllerError {
    [self.delegateDispatcher failedWithError:[OguryError createCantShowAdsInPresentingViewControllerError]];
    OCMVerify([self.delegate oguryAdsOptinVideoAdError:OguryAdsErrorCantShowAdsInPresentingViewController]);
}

- (void)testOguryAdsOptinVideoAdClicked {
    [self.delegateDispatcher clicked];
    OCMVerify([self.delegate oguryAdsOptinVideoAdClicked]);
}

- (void)testShouldTriggerOnAdAdImpression {
    [self.delegateDispatcher adImpression];

    OCMVerify([self.delegate oguryAdsOptinVideoAdOnAdImpression]);
}

@end
