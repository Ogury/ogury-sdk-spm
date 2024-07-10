//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import "OguryAdsThumbnailAdDelegateDispatcher.h"

@interface OguryAdsThumbnailAdDelegateDispatcherTests : XCTestCase

@property(strong) id<OguryAdsThumbnailAdDelegate> delegate;
@property(strong) OguryAdsThumbnailAdDelegateDispatcher *delegateDispatcher;

@end

@implementation OguryAdsThumbnailAdDelegateDispatcherTests

- (void)setUp {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:NO];

    self.delegate = OCMProtocolMock(@protocol(OguryAdsThumbnailAdDelegate));
    self.delegateDispatcher = [[OguryAdsThumbnailAdDelegateDispatcher alloc] init];
    self.delegateDispatcher.delegate = self.delegate;
}

- (void)tearDown {
    [OGADelegateDispatcher setAlwaysDispatchInMainThread:YES];
}

- (void)testOguryAdsThumbnailAdAdNotAvailable {
    [self.delegateDispatcher failedWithError:[OguryError createNotAvailableError]];
    OCMVerify([self.delegate oguryAdsThumbnailAdAdNotAvailable]);
}

- (void)testOguryAdsThumbnailAdAdLoaded {
    [self.delegateDispatcher loaded];
    OCMVerify([self.delegate oguryAdsThumbnailAdAdLoaded]);
}

- (void)testOguryAdsThumbnailAdAdNotLoaded {
    [self.delegateDispatcher failedWithError:[OguryError createNotLoadedError]];
    OCMVerify([self.delegate oguryAdsThumbnailAdAdNotLoaded]);
}

- (void)testOguryAdsThumbnailAdAdDisplayed {
    [self.delegateDispatcher displayed];
    OCMVerify([self.delegate oguryAdsThumbnailAdAdDisplayed]);
}

- (void)testOguryAdsThumbnailAdAdClosed {
    [self.delegateDispatcher closed];
    OCMVerify([self.delegate oguryAdsThumbnailAdAdClosed]);
}

- (void)testOguryAdsThumbnailAdAdError {
    [self.delegateDispatcher failedWithError:[OguryError createAdDisabledError]];
    OCMVerify([self.delegate oguryAdsThumbnailAdAdError:OguryAdsErrorAdDisable]);
}

- (void)testOguryAdsThumbnailAdAdClicked {
    [self.delegateDispatcher clicked];
    OCMVerify([self.delegate oguryAdsThumbnailAdAdClicked]);
}

- (void)testShouldTriggerOnAdAdImpression {
    [self.delegateDispatcher adImpression];

    OCMVerify([self.delegate oguryAdsThumbnailAdOnAdImpression]);
}

@end
