//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAMraidAdWebView.h"
#import "OGAMraidBaseView+Testing.h"
#import "OGAOMIDService.h"
#import "OGAAdDisplayer.h"
#import "OGAMraidEnviromentBuilder.h"
#import "OGAMraidCommandsHandler.h"
#import "OGALog.h"
#import "OGAMraidCreateWebViewCommand.h"
#import "OGAMRAIDUrlChangeHandler.h"
#import "OGAMetricsService.h"
#import "OGAAdHistoryEvent.h"
#import "OGAOMIDService.h"
#import "OGAWKWebView.h"
#import "OGAUserDefaultsStore.h"
#import "OGAMraidCommand.h"
#import "OGAMraidInitializationOperation.h"
#import "OGAMraidLoadHTMLOperation.h"
#import "OGAMraidVerificationOperation.h"
#import "OGAEXTScope.h"
#import "OGACallEventListenersConstants.h"
#import "OGAAdDisplayerCallEventListenersInformation.h"

#pragma mark - Constants

static NSString *const DefaultNavigationEvent = @"Event";
static NSString *const DefaultWebViewIdentifier = @"Identifier";
static NSString *const DefaultURL = @"https://www.UrlForTest.com";
static NSString *const DefaultURLHost = @"www.UrlForTest.com";
static NSString *const DefaultPageTitle = @"PageTitle";

@interface OGAMraidBaseViewTests : XCTestCase

@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) OGAOMIDService *omidService;

@end

@interface OGAMraidAdWebView () <
    OGAMRAIDWebViewUrlChangeHandlerDelegate,
    OGAMraidCommandsHandlerDelegate,
    OGAAdLoadStateManagerDelegate,
    WKUIDelegate,
    WKNavigationDelegate,
    WKScriptMessageHandler>

@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong) OGAOMIDService *omidService;

@property(nonatomic, strong) OGAMRAIDUrlChangeHandler *urlChangeHandler;

@property(nonatomic, strong) NSOperationQueue *mraidInitializationQueue;
@property(nonatomic, assign) BOOL isPerformingMRAIDInitialization;
@property(nonatomic, assign) BOOL hasFinishedMRAIDInitialization;

@end

@implementation OGAMraidBaseViewTests

#pragma mark - Methods

- (void)setUp {
    self.webView = OCMClassMock([WKWebView class]);
    self.omidService = OCMClassMock([OGAOMIDService class]);
    OCMStub(self.webView.URL).andReturn([NSURL URLWithString:DefaultURL]);
}

- (void)testShouldSendNavigationEventWithoutPageTitle {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAMraidAdWebView *baseView = [[OGAMraidAdWebView alloc] init];
    baseView.displayer = displayer;
    [baseView sendNavigationEvent:DefaultNavigationEvent webViewIdentifier:DefaultWebViewIdentifier wkWebView:self.webView];
    OCMVerify([displayer executeCommandForOguryBrowser:OCMOCK_ANY]);
}

- (void)testShouldSendNavigationEventWithPageTitle {
    WKWebView *webView = OCMClassMock([WKWebView class]);
    OCMStub(webView.URL).andReturn([NSURL URLWithString:DefaultURL]);
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAMraidAdWebView *element = [[OGAMraidAdWebView alloc] init];
    element.displayer = displayer;
    [element sendNavigationEvent:DefaultNavigationEvent webViewIdentifier:DefaultWebViewIdentifier wkWebView:webView pageTitle:DefaultPageTitle];
    OCMVerify([displayer executeCommandForOguryBrowser:OCMOCK_ANY]);
}

- (void)testStartOMIDSession {
    OGAAd *ad = OCMClassMock(OGAAd.class);
    OCMStub(ad.launchOmidSessionAtLoad).andReturn(NO);
    OCMStub(ad.omidEnabled).andReturn(YES);
    OGAMraidAdWebView *baseView = OCMPartialMock([[OGAMraidAdWebView alloc] initWithAd:ad]);
    OGAOMIDService *omidService = OCMClassMock(OGAOMIDService.class);
    OCMStub(omidService.isOMIDActive).andReturn(YES);
    OCMStub(baseView.omidService).andReturn(omidService);
    OCMStub(baseView.webViewId).andReturn(OGANameMainWebView);
    [baseView startOMIDSessionOnShow];
    OCMVerify([baseView.omidSession startOMIDSession]);
}

- (void)testStartOMIDSessionExist {
    OGAAd *ad = OCMClassMock(OGAAd.class);
    OCMStub(ad.launchOmidSessionAtLoad).andReturn(NO);
    OCMStub(ad.omidEnabled).andReturn(YES);
    OGAMraidAdWebView *baseView = OCMPartialMock([[OGAMraidAdWebView alloc] initWithAd:ad]);
    OGAOMIDSession *omidSession = OCMClassMock(OGAOMIDSession.class);
    OCMStub(baseView.omidSession).andReturn(omidSession);
    OGAOMIDService *omidService = OCMClassMock(OGAOMIDService.class);
    OCMStub(omidService.isOMIDActive).andReturn(YES);
    OCMStub(baseView.omidService).andReturn(omidService);
    OCMStub(baseView.webViewId).andReturn(OGANameMainWebView);
    OCMReject([baseView.omidSession startOMIDSession]);
    [baseView startOMIDSessionOnShow];
}

- (void)testStartOMIDSessionOnLoad {
    OGAAd *ad = OCMClassMock(OGAAd.class);
    OCMStub(ad.launchOmidSessionAtLoad).andReturn(YES);
    OCMStub(ad.omidEnabled).andReturn(YES);
    OGAMraidAdWebView *baseView = OCMPartialMock([[OGAMraidAdWebView alloc] initWithAd:ad]);
    OGAOMIDService *omidService = OCMClassMock(OGAOMIDService.class);
    OCMStub(omidService.isOMIDActive).andReturn(YES);
    OCMStub(baseView.omidService).andReturn(omidService);
    OCMStub(baseView.webViewId).andReturn(OGANameMainWebView);
    OCMReject([baseView.omidSession startOMIDSession]);
    [baseView startOMIDSessionOnShow];
}

- (void)test_ShouldRemoveScriptMessageHandler {
    OGAAd *ad = OCMClassMock(OGAAd.class);

    WKWebViewConfiguration *mockWebViewConfiguration = OCMClassMock(WKWebViewConfiguration.class);

    WKUserContentController *mockContentController = OCMClassMock(WKUserContentController.class);
    OCMStub(mockWebViewConfiguration.userContentController).andReturn(mockContentController);

    OGAWKWebView *mockWKWebView = OCMClassMock(OGAWKWebView.class);
    OCMStub(mockWKWebView.configuration).andReturn(mockWebViewConfiguration);

    OGAMraidAdWebView *baseView = OCMPartialMock([[OGAMraidAdWebView alloc] initWithAd:ad]);
    OCMStub(baseView.wkWebView).andReturn(mockWKWebView);

    [baseView removeScriptMessageHandler];

    OCMVerify([mockContentController removeScriptMessageHandlerForName:@"handler"]);
}

- (void)testWhenAdIsFullyReady_ThenIfSetShouldStartOMIDSession {
    OGAAd *ad = OCMClassMock(OGAAd.class);
    OCMStub(ad.launchOmidSessionAtLoad).andReturn(YES);
    OGAMraidAdWebView *baseView = OCMPartialMock([[OGAMraidAdWebView alloc] initWithAd:ad]);
    [baseView adIsFullyLoaded];
    OCMVerify([baseView startOMIDSession]);
}

- (void)testWhenAdIsFullyReady_ThenShouldSendFinishNavigationEvent {
    OGAAd *ad = OCMClassMock(OGAAd.class);
    OGAMraidAdWebView *baseView = OCMPartialMock([[OGAMraidAdWebView alloc] initWithAd:ad]);
    OCMStub(baseView.webViewId).andReturn(@"666");
    OGAWKWebView *webView = OCMPartialMock([[OGAWKWebView alloc] init]);
    OCMStub(webView.title).andReturn(@"title");
    [baseView adIsFullyLoaded];
    OCMVerify([baseView sendNavigationEvent:@"finished"
                          webViewIdentifier:[OCMArg any]
                                  wkWebView:[OCMArg any]
                                  pageTitle:[OCMArg any]]);
}

- (void)testWhenAdIsFullyReady_ThenShouldCallWebviewReady {
    OGAAd *ad = OCMClassMock(OGAAd.class);
    OGAMraidAdWebView *baseView = OCMPartialMock([[OGAMraidAdWebView alloc] initWithAd:ad]);
    [baseView adIsFullyLoaded];
    OCMVerify([baseView webViewReady]);
}

@end
