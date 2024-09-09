//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OguryInterstitialAdDelegate.h"
#import "OGADelegateDispatcher.h"
#import "OGALog.h"

@interface OGADelegateDispatcherTests : XCTestCase

@property(nonatomic, strong) OGALog *log;

@end

@interface OGADelegateDispatcher ()

- (id)initWithAlwaysDispatchInMainThread:(BOOL)alwaysDispatchInMainThread log:(OGALog *)log;

@end

@implementation OGADelegateDispatcherTests

- (void)setUp {
    self.log = OCMClassMock([OGALog class]);
}

- (void)testDispatch_notCalledWhenDelegateIsNil {
    id delegate = OCMProtocolMock(@protocol(OguryInterstitialAdDelegate));
    OCMReject([delegate didLoadOguryInterstitialAd:[OCMArg any]]);

    OGADelegateDispatcher *dispatcher = [[OGADelegateDispatcher alloc] initWithAlwaysDispatchInMainThread:NO log:self.log];
    dispatcher.delegate = nil;

    [dispatcher dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
        [delegate didLoadOguryInterstitialAd:[OCMArg any]];
    }];

    OCMVerifyAll(delegate);
}

- (void)testDispatch_inCallingThread {
    id delegate = OCMProtocolMock(@protocol(OguryInterstitialAdDelegate));

    OGADelegateDispatcher *dispatcher = [[OGADelegateDispatcher alloc] initWithAlwaysDispatchInMainThread:NO log:self.log];
    dispatcher.delegate = delegate;

    [dispatcher dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
        [delegate didLoadOguryInterstitialAd:[OCMArg any]];
    }];

    OCMVerify([delegate didLoadOguryInterstitialAd:[OCMArg any]]);
}

- (void)testDispatch_dispatchedInMainThread {
    id delegate = OCMProtocolMock(@protocol(OguryInterstitialAdDelegate));
    OCMExpect([delegate didLoadOguryInterstitialAd:[OCMArg any]]);

    OGADelegateDispatcher *dispatcher = [[OGADelegateDispatcher alloc] initWithAlwaysDispatchInMainThread:YES log:self.log];
    dispatcher.delegate = delegate;

    [dispatcher dispatch:^(id<OguryInterstitialAdDelegate> _Nonnull delegate) {
        [delegate didLoadOguryInterstitialAd:[OCMArg any]];
    }];

    // Verify with delay because it was pushed on the main queue.
    OCMVerifyAllWithDelay(delegate, 500);
}

@end
