//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OGAMraidCommandsHandler.h"
#import "OGAMraidCommandsHandler+Testing.h"
#import <OCMock/OCMock.h>
#import "OGAMraidAdWebView.h"
#import "OGAMRAIDWebViewDelegate.h"
#import "OGAMraidCommand.h"
#import "OGAAd.h"
#import "OGAJavascriptCommandExecutor.h"
#import "OGAAdDisplayerUpdateStateInformation.h"
#import "OGAAdConfiguration.h"
#import "OGAAdExposure.h"
#import "OGALog.h"
#import "OGAAdLoadStateManager.h"
#import "OguryError+utility.h"

@interface OGAMraidCommandsHandlerTests : XCTestCase

@property(nonatomic, strong) OGALog *log;

@end

@interface OGAMraidCommandsHandler (test)

- (void)unloadAd:(OGAMraidCommand *)command;
- (void)handleUnsentCommands;
@property(nonatomic, strong) NSMutableArray<OGAMraidCommand *> *commandsToSend;

@end

@implementation OGAMraidCommandsHandlerTests

- (void)setUp {
    self.log = OCMClassMock([OGALog class]);
}

#pragma mark - Methods

- (void)testShouldInstantiate {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = OCMClassMock(OGAMraidAdWebView.self);

    OGAMraidCommandsHandler *handler = [[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView];

    XCTAssertNotNil(handler);
    XCTAssertNotNil(handler.delegate);
    XCTAssertNotNil(handler.mraidWebView);
    XCTAssertNotNil(handler.commandExecutor);
}

- (void)testShouldHandleMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);

    NSDictionary<NSString *, NSString *> *args = @{
        @"webViewId" : @"Identifier"
    };

    OCMStub(command.args).andReturn(args);
    OCMStub(command.callbackId).andReturn(@"Callback");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    OGAJavascriptCommandExecutor *commandExecutor = OCMClassMock(OGAJavascriptCommandExecutor.self);

    OCMStub(handler.commandExecutor).andReturn(commandExecutor);

    [handler handleMraidCommand:command];

    OCMVerify([commandExecutor callPendingMethodCallBackWithCallBackId:@"Callback" webViewId:@"Identifier"]);
    OCMVerify([commandExecutor callCommandComplete]);
}

- (void)testShouldHandleCreateWebViewMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"ogyCreateWebView");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([delegate createWebView:command]);
}

- (void)testShouldHandleCustomCloseMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"useCustomClose");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([handler useCustomClose:command]);
}

- (void)testShouldHandleUnloadMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"unload");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([handler unloadAd:command]);
}

- (void)testShouldHandleCloseMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"close");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([handler closeAd:command]);
}

- (void)testShouldHandleOpenStoreKitMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"ogyOpenStoreKit");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([delegate openStoreKit:command]);
}
- (void)testShouldHandleOgyImpressionMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"ogyOnAdImpression");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([delegate adImpressionFormat]);
}

- (void)testShouldHandleOgyOnAdLoadedMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"ogyOnAdLoaded");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([delegate formatDidLoadAd]);
}

- (void)testShouldHandleCloseMRAIDCommandOnBrowser {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = OCMClassMock(OGAMraidAdWebView.class);
    OCMStub(webView.webViewId).andReturn(@"browser");
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"close");

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([handler closeAd:command]);
    OCMVerify([delegate forceClose:command]);
}

- (void)testShouldHandleAdEventMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"ogyOnAdEvent");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);
    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);
    [handler handleMraidCommand:command];
    OCMVerify([handler adEvent:command]);
}

- (void)testShouldHandleOpenMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"open");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([handler openURL:command]);
}

- (void)testShouldHandleCloseWebViewMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"ogyCloseWebView");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([delegate closeWebView:command]);
}

- (void)testShouldHandleNavigateBackMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"ogyNavigateBack");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);

    NSDictionary<NSString *, NSString *> *args = @{
        @"webViewId" : @"Identifier"
    };

    OCMStub(command.args).andReturn(args);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([delegate executeBackActionForWebViewId:@"Identifier"]);
}

- (void)testShouldHandleNavigateForwardMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"ogyNavigateForward");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);

    NSDictionary<NSString *, NSString *> *args = @{
        @"webViewId" : @"Identifier"
    };

    OCMStub(command.args).andReturn(args);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([delegate executeForwardActionForWebViewId:@"Identifier"]);
}

- (void)testShouldHandleBunaZiuaMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    webView.webViewId = @"Main";
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"bunaZiua");
    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate
                                                                                           mraidWebView:webView]);
    OCMStub([handler mraidWebView]).andReturn(webView);
    [handler handleMraidCommand:command];
    OCMVerify([handler bunaZiua:command]);
}

- (void)testShouldHandleUpdateWebViewMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"ogyUpdateWebView");

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([delegate updateWebView:command]);
}

- (void)testShouldHandleSetResizePropertiesMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"setResizeProperties");

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([delegate resizeProps:command]);
}

- (void)testShouldHandleSetOrientationPropertiesMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"setOrientationProperties");

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([delegate setOrientationProperties:command]);
}

- (void)testShouldHandleForceCloseMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"ogyForceClose");

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([delegate forceClose:command]);
}

- (void)testShouldHandleExpandMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"expand");

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([delegate expand]);
}

- (void)testShouldHandleOnAdClickMRAIDCommand {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"ogyOnAdClicked");

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler handleMraidCommand:command];

    OCMVerify([delegate adClicked]);
}

- (void)testShouldHandleCustomClose {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);

    NSDictionary<NSString *, NSString *> *args = @{
        @"useCustomClose" : @"true"
    };

    OCMStub(command.args).andReturn(args);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    [handler useCustomClose:command];

    XCTAssertTrue(webView.usesCustomCloseButton);
    OCMVerify([delegate setUseCustomCloseButton:YES]);
}

- (void)testShouldDispatchRewardReceivedWhenReceivingRewardEvent {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    NSDictionary<NSString *, NSString *> *args = @{
        @"event" : @"rewards"
    };
    OCMStub(command.args).andReturn(args);
    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);
    [handler adEvent:command];
    OCMVerify([delegate rewardWasReceived]);
}

- (void)testWhenOnAdEventWithEulaAcceptedIsReceivedThenProperDelegateIsCalled {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    NSDictionary<NSString *, NSString *> *args = @{
        @"event" : @"eulaAccepted"
    };
    OCMStub(command.args).andReturn(args);
    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);
    [handler adEvent:command];
    OCMVerify([delegate eulaConsentStatus:YES]);
}

- (void)testWhenOnAdEventWithEulaRejectedIsReceivedThenProperDelegateIsCalled {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    NSDictionary<NSString *, NSString *> *args = @{
        @"event" : @"eulaRejected"
    };
    OCMStub(command.args).andReturn(args);
    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);
    [handler adEvent:command];
    OCMVerify([delegate eulaConsentStatus:NO]);
}

- (void)testShouldOpenURLWithCustomURL {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);

    NSDictionary<NSString *, NSString *> *args = @{
        @"url" : @"https://www.google.com"
    };

    OCMStub(command.args).andReturn(args);

    UIApplication *application = OCMClassMock(UIApplication.self);
    OCMStub([application canOpenURL:OCMOCK_ANY]).andReturn(YES);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView application:application log:self.log]);

    [handler openURL:command];

    OCMVerify([application canOpenURL:OCMOCK_ANY]);
    OCMVerify([application openURL:OCMOCK_ANY options:OCMOCK_ANY completionHandler:OCMOCK_ANY]);
}

- (void)testShouldNotOpenURLWithOtherURL {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);

    OCMStub(command.args).andReturn([[NSDictionary alloc] init]);

    UIApplication *application = OCMClassMock(UIApplication.self);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView application:application log:self.log]);

    [handler openURL:command];

    OCMReject([application canOpenURL:OCMOCK_ANY]);
    OCMReject([application openURL:OCMOCK_ANY options:OCMOCK_ANY completionHandler:OCMOCK_ANY]);
}

- (void)testShouldCloseOrUnloadAdWithDelegate {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = OCMClassMock(OGAMraidAdWebView.self);
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);

    OGAMraidCommandsHandler *handler = [[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView];

    [handler closeAd:command];

    OCMVerify([delegate closeFullAd:command]);
}

- (void)testShouldCloseOrUnloadAdWithoutDelegate {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));

    OGAMraidAdWebView *webView = OCMClassMock(OGAMraidAdWebView.self);

    OGAAd *ad = OCMClassMock(OGAAd.self);
    OCMStub(ad.localIdentifier).andReturn(@"Identifier");
    OGAAdLoadStateManager *stateManager = OCMClassMock(OGAAdLoadStateManager.self);

    OCMStub(webView.ad).andReturn(ad);

    id<OGAMRAIDWebViewDelegate> webViewDelegate = OCMProtocolMock(@protocol(OGAMRAIDWebViewDelegate));

    OCMStub(stateManager.webViewDelegate).andReturn(webViewDelegate);

    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);

    OGAMraidCommandsHandler *handler = [[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView];
    handler.delegate = nil;
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OCMStub(displayer.stateManager).andReturn(stateManager);
    OCMStub(webView.displayer).andReturn(displayer);

    [handler closeAd:command];
    OCMVerify([stateManager.webViewDelegate webViewNotReady:@"Identifier"]);
    XCTAssertFalse(webView.usesCustomCloseButton);
}

- (void)testShouldSendLoadCommands {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));

    OGAMraidAdWebView *webView = OCMClassMock(OGAMraidAdWebView.self);
    OCMStub(webView.webViewId).andReturn(@"Main");

    OGAAd *ad = OCMClassMock(OGAAd.self);
    OCMStub(webView.ad).andReturn(ad);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    OGAJavascriptCommandExecutor *commandExecutor = OCMClassMock(OGAJavascriptCommandExecutor.self);

    OCMStub(handler.commandExecutor).andReturn(commandExecutor);

    [handler sendLoadCommands];

    OCMVerify([commandExecutor evaluateJS:OCMOCK_ANY]);
    OCMVerify([commandExecutor sendLoadMraidCommandsWithFrame:CGRectZero]);
    OCMReject([commandExecutor sendShowMraidCommandsWithExposure:[OCMArg isKindOfClass:OGAAdExposure.self]]);
}

- (void)testShouldSendLoadCommandsForOtherWebView {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));

    OGAMraidAdWebView *webView = OCMClassMock(OGAMraidAdWebView.self);
    OCMStub(webView.webViewId).andReturn(@"Other");

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    OGAJavascriptCommandExecutor *commandExecutor = OCMClassMock(OGAJavascriptCommandExecutor.self);

    OCMStub(handler.commandExecutor).andReturn(commandExecutor);

    [handler sendLoadCommands];

    OCMVerify([commandExecutor evaluateJS:OCMOCK_ANY]);
    OCMVerify([commandExecutor sendLoadMraidCommandsWithFrame:CGRectZero]);
    OCMVerify([commandExecutor sendShowMraidCommandsWithExposure:[OCMArg isKindOfClass:OGAAdExposure.self]]);
}

- (void)testShouldSendLoadCommandsForThumbnail {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));

    OGAMraidAdWebView *webView = OCMClassMock(OGAMraidAdWebView.self);
    OCMStub(webView.frame).andReturn(CGRectMake(0, 0, 100, 100));
    OCMStub(webView.webViewId).andReturn(@"Main");

    OGAAd *ad = OCMClassMock(OGAAd.self);

    OGAAdConfiguration *configuration = OCMClassMock(OGAAdConfiguration.self);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeThumbnailAd);

    OCMStub(ad.adConfiguration).andReturn(configuration);

    OCMStub(webView.ad).andReturn(ad);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    OGAJavascriptCommandExecutor *commandExecutor = OCMClassMock(OGAJavascriptCommandExecutor.self);

    OCMStub(handler.commandExecutor).andReturn(commandExecutor);

    [handler sendLoadCommands];

    OCMVerify([commandExecutor evaluateJS:OCMOCK_ANY]);
    OCMVerify([commandExecutor sendLoadMraidCommandsWithFrame:CGRectMake(0, 0, 100, 100)]);
    OCMReject([commandExecutor sendShowMraidCommandsWithExposure:[OCMArg isKindOfClass:OGAAdExposure.self]]);
}

- (void)testShouldSendLoadCommandsForBanner {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));

    OGAMraidAdWebView *webView = OCMClassMock(OGAMraidAdWebView.self);
    OCMStub(webView.frame).andReturn(CGRectMake(0, 0, 100, 100));
    OCMStub(webView.webViewId).andReturn(@"Main");

    OGAAd *ad = OCMClassMock(OGAAd.self);

    OGAAdConfiguration *configuration = OCMClassMock(OGAAdConfiguration.self);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeBanner);

    OCMStub(ad.adConfiguration).andReturn(configuration);

    OCMStub(webView.ad).andReturn(ad);

    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);

    OGAJavascriptCommandExecutor *commandExecutor = OCMClassMock(OGAJavascriptCommandExecutor.self);

    OCMStub(handler.commandExecutor).andReturn(commandExecutor);

    [handler sendLoadCommands];

    OCMVerify([commandExecutor evaluateJS:OCMOCK_ANY]);
    OCMVerify([commandExecutor sendLoadMraidCommandsWithFrame:CGRectMake(0, 0, 100, 100)]);
    OCMReject([commandExecutor sendShowMraidCommandsWithExposure:[OCMArg isKindOfClass:OGAAdExposure.self]]);
}

- (void)testWhenBunaZiuaCommandIsReceived_ThenItIsAlwaysHandled {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"bunaZiua");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(NO);
    webView.webViewId = @"Main";
    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate
                                                                                           mraidWebView:webView]);
    OCMStub([handler mraidWebView]).andReturn(webView);
    [handler handleMraidCommand:command];
    OCMVerify([delegate bunaZiua]);
}

- (void)testWhenUnloadCommandIsReceived_ThenItIsAlwaysHandled {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"unload");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(NO);
    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate
                                                                                           mraidWebView:webView]);
    [handler handleMraidCommand:command];
    OCMVerify([handler unloadAd:command]);
}

- (void)testWhenCloseCommandIsReceived_ThenItIsAlwaysHandled {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"close");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(NO);
    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate
                                                                                           mraidWebView:webView]);
    [handler handleMraidCommand:command];
    OCMVerify([handler closeAd:[OCMArg any]]);
}

- (void)testWhenForceCloseCommandIsReceived_ThenItIsAlwaysHandled {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"ogyForceClose");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(NO);
    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate
                                                                                           mraidWebView:webView]);
    [handler handleMraidCommand:command];
    OCMVerify([delegate forceClose:[OCMArg any]]);
}

- (void)testWhenACommandIsReceivedBeforeBunaZiua_ThenItIsNotHandledAndSaved {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"expand");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(NO);
    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate
                                                                                           mraidWebView:webView]);
    [handler handleMraidCommand:command];
    OCMReject([delegate expand]);
    XCTAssertEqual(handler.commandsToSend.count, 1);
    XCTAssertTrue([handler.commandsToSend[0].method isEqualToString:@"expand"]);
}

- (void)testWhenTwoCommandAreReceivedBeforeBunaZiua_ThenTheyAreNotHandledAndSaved {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"expand");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(NO);
    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate
                                                                                           mraidWebView:webView]);
    [handler handleMraidCommand:command];
    OGAMraidCommand *secondCommand = OCMClassMock(OGAMraidCommand.self);
    OCMStub(secondCommand.method).andReturn(@"ogyOnAdImpression");
    [handler handleMraidCommand:secondCommand];
    OCMReject([delegate expand]);
    OCMReject([delegate adImpressionFormat]);
    XCTAssertEqual(handler.commandsToSend.count, 2);
    XCTAssertTrue([handler.commandsToSend[0].method isEqualToString:@"expand"]);
    XCTAssertTrue([handler.commandsToSend[1].method isEqualToString:@"ogyOnAdImpression"]);
}

- (void)testWhenACommandIsReceivedBeforeBunaZiua_ThenItIsHandledAfterBunaZiuaIsReceived {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    OCMStub(command.method).andReturn(@"ogyOnAdImpression");
    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate
                                                                                           mraidWebView:webView]);
    [handler handleMraidCommand:command];
    OCMReject([delegate expand]);
    XCTAssertEqual(handler.commandsToSend.count, 1);
    XCTAssertTrue([handler.commandsToSend[0].method isEqualToString:@"ogyOnAdImpression"]);
    // send BunaZiua
    OGAMraidCommand *bunaZiuacommand = OCMClassMock(OGAMraidCommand.self);
    OCMStub(bunaZiuacommand.method).andReturn(@"bunaZiua");
    OCMStub([delegate mraidCommunicationIsUp]).andReturn(YES);
    webView.webViewId = @"Main";
    [handler handleMraidCommand:bunaZiuacommand];
    OCMVerify([delegate bunaZiua]);
    OCMVerify([handler handleUnsentCommands]);
    OCMVerify([handler handleMraidCommand:command]);
}

- (void)testWhenEulaAcceptedIsReceivedThenDelegateIsCalled {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    NSDictionary<NSString *, NSString *> *args = @{
        @"event" : @"eulaAccepted"
    };

    OCMStub(command.args).andReturn(args);
    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);
    [handler adEvent:command];
    OCMVerify([delegate eulaConsentStatus:YES]);
}

- (void)testWhenEulaRejectedIsReceivedThenDelegateIsCalled {
    id<OGAMraidCommandsHandlerDelegate> delegate = OCMProtocolMock(@protocol(OGAMraidCommandsHandlerDelegate));
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    OGAMraidCommand *command = OCMClassMock(OGAMraidCommand.self);
    NSDictionary<NSString *, NSString *> *args = @{
        @"event" : @"eulaRejected"
    };

    OCMStub(command.args).andReturn(args);
    OGAMraidCommandsHandler *handler = OCMPartialMock([[OGAMraidCommandsHandler alloc] initWithDelegate:delegate mraidWebView:webView]);
    [handler adEvent:command];
    OCMVerify([delegate eulaConsentStatus:NO]);
}

@end
