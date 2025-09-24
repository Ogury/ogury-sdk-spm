//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAAdLoadStateManager.h"
#import "OGAAd.h"
#import "OGAMRAIDWebViewDelegate.h"
#import <OCMock/OCMock.h>
#import "OGAMraidAdWebView.h"

@interface OGAAdLoadStateManagerTests : XCTestCase
@property(nonatomic, retain) OGAAdLoadStateManager *sut;
@property(nonatomic, retain) OGAAd *ad;
@property(nonatomic, weak) id<OGAMRAIDWebViewDelegate> webDelegate;
@property(nonatomic, weak) id<OGAAdLoadStateManagerErrorDelegate> errorDelegate;
@end

@interface OGAAdLoadStateManager ()
@property(nonatomic, retain) OGAAd *ad;
@property(nonatomic) AdLoadingState adLoadingState;
- (BOOL)adLoaded;
- (void)webViewIsReadyForSDKBehavior:(NSString *)webViewId;
- (void)triggerStateDelegateIfPossible;
- (void)triggerFormatLoadedTimeoutError:(NSNumber *)timeout;
@end

@implementation OGAAdLoadStateManagerTests

- (void)setUp {
    self.ad = OCMPartialMock([OGAAd new]);
    self.webDelegate = OCMProtocolMock(@protocol(OGAMRAIDWebViewDelegate));
    self.errorDelegate = OCMProtocolMock(@protocol(OGAAdLoadStateManagerErrorDelegate));
    self.sut = [[OGAAdLoadStateManager alloc] initWithAd:self.ad
                                                 timeout:@3
                                             webDelegate:self.webDelegate
                                           errorDelegate:self.errorDelegate];
}

- (void)testWhenStarting_ThenLoadStateIsIdle {
    XCTAssertEqual(self.sut.adLoadingState, AdLoadingStateIdle);
}

- (void)testWhenCommunicationIsRunning_ThenOnlyLoadStateIsSet {
    [self.sut setMraidEnvironmentIsUp:YES];
    XCTAssertTrue(self.sut.mraidEnvironmentIsUp);
    XCTAssertFalse(self.sut.webViewLoaded);
    XCTAssertFalse(self.sut.formatLoaded);
}

- (void)testWhenCommunicationIsStopped_ThenOnlyLoadStateIsSet {
    [self.sut setMraidEnvironmentIsUp:YES];
    [self.sut setMraidEnvironmentIsUp:NO];
    XCTAssertEqual(self.sut.adLoadingState, AdLoadingStateIdle);
    XCTAssertFalse(self.sut.mraidEnvironmentIsUp);
    XCTAssertFalse(self.sut.webViewLoaded);
    XCTAssertFalse(self.sut.formatLoaded);
}

- (void)testWhenWebViewIsReady_ThenOnlyLoadStateIsSet {
    [self.sut setWebViewLoaded:YES];
    XCTAssertFalse(self.sut.mraidEnvironmentIsUp);
    XCTAssertTrue(self.sut.webViewLoaded);
    XCTAssertFalse(self.sut.formatLoaded);
}

- (void)testWhenWebViewStopped_ThenOnlyLoadStateIsSet {
    [self.sut setWebViewLoaded:YES];
    [self.sut setWebViewLoaded:NO];
    XCTAssertEqual(self.sut.adLoadingState, AdLoadingStateIdle);
    XCTAssertFalse(self.sut.mraidEnvironmentIsUp);
    XCTAssertFalse(self.sut.webViewLoaded);
    XCTAssertFalse(self.sut.formatLoaded);
}

- (void)testWhenFormatIsReady_ThenOnlyLoadStateIsSet {
    [self.sut setFormatLoaded:YES];
    XCTAssertFalse(self.sut.mraidEnvironmentIsUp);
    XCTAssertFalse(self.sut.webViewLoaded);
    XCTAssertTrue(self.sut.formatLoaded);
}

- (void)testWhenFormatStopped_ThenOnlyLoadStateIsSet {
    [self.sut setFormatLoaded:YES];
    [self.sut setFormatLoaded:NO];
    XCTAssertEqual(self.sut.adLoadingState, AdLoadingStateIdle);
    XCTAssertFalse(self.sut.mraidEnvironmentIsUp);
    XCTAssertFalse(self.sut.webViewLoaded);
    XCTAssertFalse(self.sut.formatLoaded);
}

- (void)testGivenAdWithSdkBehavior_WhenCommunicationIsRunningAndWebViewIsReady_ThenAllLoadingConditionsAreFulfilled {
    OCMStub(self.sut.ad.loadedSource).andReturn(LoadedSourceSDK);
    self.sut.webViewLoaded = YES;
    [self.sut setMraidEnvironmentIsUp:YES];
    [self.sut setWebviewReadyToLoad:YES];
    XCTAssertTrue(self.sut.adLoaded);
}

- (void)testGivenAdWithSdkBehavior_WhenCommunicationIsRunningAndWebViewIsReady_ThenDelegateIsCalled {
    id<OGAAdLoadStateManagerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdLoadStateManagerDelegate));
    OCMStub(self.sut.ad.loadedSource).andReturn(LoadedSourceSDK);
    self.sut.webViewLoaded = YES;
    self.sut.stateDelegate = delegate;
    [self.sut setMraidEnvironmentIsUp:YES];
    [self.sut setWebviewReadyToLoad:YES];
    OCMVerify([delegate adIsFullyLoaded]);
}

- (void)testGivenAdWithFormatBehavior_WhenCommunicationIsRunningAndWebViewIsReady_ThenAllLoadingConditionsAreNotFulfilled {
    OCMStub(self.sut.ad.loadedSource).andReturn(LoadedSourceFormat);
    [self.sut setMraidEnvironmentIsUp:YES];
    [self.sut setWebViewLoaded:YES];
    XCTAssertFalse(self.sut.adLoaded);
}

- (void)testGivenAdWithFormatBehavior_WhenCommunicationIsRunningAndWebViewAndFormatAreReady_ThenAllLoadingConditionsAreFulfilled {
    OCMStub(self.sut.ad.loadedSource).andReturn(LoadedSourceSDK);
    [self.sut setMraidEnvironmentIsUp:YES];
    [self.sut setWebViewLoaded:YES];
    [self.sut setWebviewReadyToLoad:YES];
    XCTAssertTrue(self.sut.adLoaded);
}

- (void)testGivenAdWithFormatBehavior_WhenCommunicationIsRunningAndWebViewAndFormatAreReady_ThenDelegateIsCalled {
    id<OGAAdLoadStateManagerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdLoadStateManagerDelegate));
    OCMStub(self.sut.ad.loadedSource).andReturn(LoadedSourceFormat);
    self.sut.stateDelegate = delegate;
    [self.sut setMraidEnvironmentIsUp:YES];
    [self.sut setWebviewReadyToLoad:YES];
    [self.sut setFormatLoaded:YES];
    OCMVerify([delegate adIsFullyLoaded]);
}

- (void)testGivenSUT_WhenWebviewIsLoadedButCommunicationIsDown_ThenWebDelegateIsCalled {
    OCMStub(self.sut.ad.localIdentifier).andReturn(@"identifier");
    [self.sut setMraidEnvironmentIsUp:NO];
    BOOL success = [self.sut webViewLoaded:OGANameMainWebView];
    XCTAssertFalse(success);
    OCMVerify([self.webDelegate webViewNotReady:@"identifier"]);
}

- (void)testGivenAdWithSDKBehavior_WhenWebviewIsLoadedAndCommunicationIsUp_ThenDelegatesAreCalled {
    id<OGAAdLoadStateManagerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdLoadStateManagerDelegate));
    OCMStub(self.sut.ad.localIdentifier).andReturn(@"identifier");
    OCMStub(self.sut.ad.loadedSource).andReturn(LoadedSourceSDK);
    self.sut.webViewLoaded = YES;
    OCMStub(self.sut.ad.delayForSendingLoaded).andReturn(5);
    self.sut.stateDelegate = delegate;
    [self.sut setMraidEnvironmentIsUp:YES];
    [self.sut setWebviewReadyToLoad:YES];
    BOOL success = [self.sut webViewLoaded:OGANameMainWebView];
    XCTAssertTrue(success);
    XCTAssertTrue(self.sut.webViewLoaded);
    OCMVerify([self.webDelegate webViewReady:@"identifier"]);
}

- (void)testWhenLoadIsFailing_ThenErrorDelegateShouldBeCalled {
    [self.sut triggerFormatLoadedTimeoutError:@2];
    OCMVerify([self.errorDelegate loadTimedOut]);
}

- (void)testWhenNoCallbackIsTriggered_ThenTimeoutDelegateShouldBeTriggered {
    [self.sut setMraidEnvironmentIsUp:YES];
    [self.sut setWebViewLoaded:YES];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"The timeout delegate should be called"];
    XCTWaiter *waiter = [[XCTWaiter alloc] init];
    OCMStub([self.errorDelegate loadTimedOut]).andDo(^(NSInvocation *invocation) {
        [expectation fulfill];
    });
    [waiter waitForExpectations:@[ expectation ] timeout:10];
}

- (void)testWhenFormatIsLoaded_ThenTimeoutDelegateShouldNotBeTriggered {
    [self.sut setMraidEnvironmentIsUp:YES];
    [self.sut setWebViewLoaded:YES];
    [self.sut setWebviewReadyToLoad:YES];
    [self.sut setFormatLoaded:YES];
    [self.sut setWebviewReadyToLoad:YES];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"The timeout delegate should NOT be called"];
    [expectation setInverted:YES];
    XCTWaiter *waiter = [[XCTWaiter alloc] init];
    OCMStub([self.errorDelegate loadTimedOut]).andDo(^(NSInvocation *invocation) {
        [expectation fulfill];
    });
    [waiter waitForExpectations:@[ expectation ] timeout:4];
}

@end
