//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <MediaPlayer/MPVolumeView.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAAd+ImpressionSource.h"
#import "OGAAd.h"
#import "OGAAdDisplayerOrientationDelegate.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAAdDisplayerUpdateStateInformation.h"
#import "OGAAdDisplayerUpdateViewabilityInformation.h"
#import "OGACloseAdAction.h"
#import "OGAExpandAdAction.h"
#import "OGAForceCloseAdAction.h"
#import "OGAJavascriptCommandExecutor.h"
#import "OGALog.h"
#import "OGAMRAIDAdDisplayer+Testing.h"
#import "OGAMRAIDAdDisplayer+Volume.h"
#import "OGAMRAIDAdDisplayer.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAMraidCommand.h"
#import "OGAMraidCommandsHandlerDelegate.h"
#import "OGAMraidCreateWebViewCommand.h"
#import "OGAOMIDSession.h"
#import "OGAUnloadAdAction.h"
#import "OGAAdController.h"

@interface OGAMRAIDAdDisplayerTests : XCTestCase

@property(nonatomic, strong) OGAAdSyncManager *adSyncManager;
@property(nonatomic, strong) OGAAdLandingPagePrefetcher *prefetcher;
@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong) OGAUserDefaultsStore *userDefaultStore;
@property(nonatomic, strong) UIApplication *application;
@property(nonatomic, strong) OGAMRAIDAdDisplayer *displayer;
@property(nonatomic, assign) OGAWebViewCleanupManager *webViewCleanupManager;
@property(nonatomic, strong) OGAAdImpressionManager *impressionManager;
@property(nonatomic, strong) OGAAd *ad;
@property(nonatomic, strong) OGAAdConfiguration *configuration;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAProfigManager *profigManager;
@property(nonatomic, strong) OGAAdLoadStateManager *stateManager;
@property(nonatomic, strong) OGALog *log;

@end

@interface OGAAdLoadStateManager (test)
- (instancetype)init:(OGAAd *)ad
                 timeout:(NSNumber *)timeOut
             webDelegate:(id<OGAMRAIDWebViewDelegate>)webDelegate
           errorDelegate:(id<OGAAdLoadStateManagerErrorDelegate>)commandDelegate
    monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher;
@end

@interface OGAMRAIDAdDisplayer ()

@property(nonatomic, assign) OGAAdMraidDisplayerState state;
@property(nonatomic, strong) MPVolumeView *mpVolumeView;
@property(nonatomic, strong) UISlider *volumeSlider;
@property(nonatomic, assign) NSUInteger numberOfReloadAttempts;

- (void)dispatchNoViewabilityAndZeroExposure;

- (void)volumeDidChange:(UISlider *)sender;

- (void)setupViews;

- (void)adClicked;

- (void)adImpressionFormat;

- (void)formatDidLoadAd;

+ (OGAAdLoadStateManager *)stateManagerForTimeout:(NSNumber *)timeout
                                               ad:(OGAAd *)ad
                                      webDelegate:(id<OGAMRAIDWebViewDelegate>)webDelegate
                                    errorDelegate:(id<OGAAdLoadStateManagerErrorDelegate>)commandDelegate;

@end

@implementation OGAMRAIDAdDisplayerTests

#pragma mark - Constants

#pragma mark - Methods

- (void)setUp {
    self.log = OCMClassMock([OGALog class]);
    self.adSyncManager = OCMClassMock([OGAAdSyncManager class]);
    self.prefetcher = OCMClassMock([OGAAdLandingPagePrefetcher class]);
    self.metricsService = OCMClassMock([OGAMetricsService class]);
    self.userDefaultStore = [OGAUserDefaultsStore shared];
    self.application = UIApplication.sharedApplication;
    self.webViewCleanupManager = [OGAWebViewCleanupManager shared];
    self.impressionManager = OCMClassMock([OGAAdImpressionManager class]);
    self.ad = OCMClassMock([OGAAd class]);
    self.configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([self.configuration webviewLoadTimeout]).andReturn(@3);
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    self.profigManager = OCMClassMock([OGAProfigManager class]);
    self.stateManager = OCMClassMock([OGAAdLoadStateManager class]);
    id classMock = OCMClassMock([OGAMRAIDAdDisplayer class]);
    OCMStub([classMock stateManagerForTimeout:[OCMArg any]
                                           ad:[OCMArg any]
                                  webDelegate:[OCMArg any]
                                errorDelegate:[OCMArg any]])
        .andReturn(self.stateManager);

    self.displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:self.ad
                                             adConfiguration:self.configuration
                                               adSyncManager:self.adSyncManager
                                       landingPagePrefetcher:self.prefetcher
                                              metricsService:self.metricsService
                                           userDefaultsStore:self.userDefaultStore
                                                 application:self.application
                                         adImpressionManager:self.impressionManager
                                       webViewCleanupManager:self.webViewCleanupManager
                                        monitoringDispatcher:self.monitoringDispatcher
                                               profigManager:self.profigManager
                                                         log:self.log];
}

- (void)testShouldInstantiate {
    XCTAssertNotNil(self.displayer);
    XCTAssertNotNil(self.displayer.ad);
    XCTAssertFalse(self.displayer.isLoaded);
    XCTAssertEqual(self.displayer.webviews.count, 1);

    UIButton *closeButton = self.displayer.closeButton;

    XCTAssertNotNil(closeButton);
    XCTAssertTrue(closeButton.isHidden);

    OGAMRAIDWebView *containerWebView = self.displayer.containerWebView;

    XCTAssertNotNil(containerWebView);
    XCTAssertNotNil(containerWebView.commandExecutor);
}

- (void)testShouldReturnTrueKeepAliveIfAdHasKeepAliveEnabled {
    OGAAd *ad = OCMClassMock(OGAAd.self);
    OCMStub(ad.adKeepAlive).andReturn(YES);

    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);

    self.displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:ad adConfiguration:configuration];

    XCTAssertTrue([self.displayer hasKeepAlive]);
}

- (void)testShouldReturnTrueKeepAliveIfAnyWebViewHasKeepAliveEnabled {
    OGAAd *ad = OCMClassMock(OGAAd.self);
    OCMStub(ad.adKeepAlive).andReturn(NO);

    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);

    self.displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:ad adConfiguration:configuration]);

    OGAMRAIDWebView *firstWebView = OCMClassMock(OGAMRAIDWebView.self);

    OGAMraidCreateWebViewCommand *firstCreateCommand = OCMClassMock(OGAMraidCreateWebViewCommand.self);
    OCMStub(firstCreateCommand.keepAlive).andReturn(NO);

    OCMStub(firstWebView.createCommand).andReturn(firstCreateCommand);

    OGAMRAIDWebView *secondWebView = OCMClassMock(OGAMRAIDWebView.self);

    OGAMraidCreateWebViewCommand *secondCreateCommand = OCMClassMock(OGAMraidCreateWebViewCommand.self);
    OCMStub(secondCreateCommand.keepAlive).andReturn(YES);

    OCMStub(secondWebView.createCommand).andReturn(secondCreateCommand);

    OGAMRAIDWebView *thirdWebView = OCMClassMock(OGAMRAIDWebView.self);

    OGAMraidCreateWebViewCommand *thirdCreateCommand = OCMClassMock(OGAMraidCreateWebViewCommand.self);
    OCMStub(thirdCreateCommand.keepAlive).andReturn(NO);

    NSArray<OGAMRAIDWebView *> *webViews = @[ firstWebView, secondWebView, thirdWebView ];

    OCMStub(self.displayer.webviews).andReturn(webViews);

    XCTAssertTrue([self.displayer hasKeepAlive]);
}

- (void)testShouldReturnFalseIfKeepAliveIsNotEnabled {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);

    self.displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:OCMClassMock(OGAAd.self) adConfiguration:configuration];

    XCTAssertFalse([self.displayer hasKeepAlive]);
}

- (void)testShouldStop {
    OGAOMIDSession *mockOMIDSession = OCMClassMock(OGAOMIDSession.self);

    OGAMRAIDAdDisplayer *mockDisplayer = OCMPartialMock(self.displayer);

    self.displayer.containerWebView.omidSession = mockOMIDSession;

    [self.displayer cleanUp];

    OCMVerify([mockDisplayer dispatchInformation:[OCMArg isKindOfClass:[OGAAdDisplayerUpdateExposureInformation class]]]);
    OCMVerify([mockOMIDSession stopOMIDSession]);
}

- (void)testShouldCreateWebview {
    NSString *commandString = @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"content\":\"<html><head>"
                              @"</head><body>It works!</body></html>\",\"size\":{\"width\":414,\"height\":896},\"position\":{\"x\":0,\"y\":0}}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];

    [self.displayer createWebView:command];

    XCTAssertTrue(self.displayer.webviews.count == 2);
}

- (void)testShouldCreateWebviewAndExpandForThumbnail {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeThumbnailAd);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);

    self.displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:OCMClassMock(OGAAd.self) adConfiguration:configuration];

    NSString *commandString = @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"content\":\"<html><head>"
                              @"</head><body>It works!</body></html>\",\"size\":{\"width\":414,\"height\":896},\"position\":{\"x\":0,\"y\":0}}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];

    OGAMRAIDAdDisplayer *mockedDisplayer = OCMPartialMock(self.displayer);

    OCMExpect([mockedDisplayer expand]);

    [self.displayer createWebView:command];

    OCMVerify([mockedDisplayer expand]);
}

- (void)testShouldCreateWebviewAndExpandForBanner {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeBanner);

    self.displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:OCMClassMock(OGAAd.self) adConfiguration:configuration];

    NSString *commandString = @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"content\":\"<html><head>"
                              @"</head><body>It works!</body></html>\",\"size\":{\"width\":414,\"height\":896},\"position\":{\"x\":0,\"y\":0}}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];

    OGAMRAIDAdDisplayer *mockedDisplayer = OCMPartialMock(self.displayer);

    OCMExpect([mockedDisplayer expand]);

    [self.displayer createWebView:command];

    OCMVerify([mockedDisplayer expand]);
}

- (void)testShouldSetupFullscreenWebviewWithoutCommand {
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];

    UIView *view = [[UIView alloc] init];

    [view addSubview:webView];

    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeThumbnailAd);

    self.displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:OCMClassMock(OGAAd.self) adConfiguration:configuration];
    self.displayer.view = view;

    [self.displayer setupWebView:webView withCommand:nil];

    NSPredicate *topConstraintPredicate = [NSPredicate predicateWithFormat:@"identifier LIKE 'topAnchorConstraint*'"];
    XCTAssertEqual([self.displayer.view.constraints filteredArrayUsingPredicate:topConstraintPredicate].count, 1);

    NSPredicate *leadingConstraintPredicate = [NSPredicate predicateWithFormat:@"identifier LIKE 'leadingAnchorConstraint*'"];
    XCTAssertEqual([self.displayer.view.constraints filteredArrayUsingPredicate:leadingConstraintPredicate].count, 1);

    NSPredicate *trailingConstraintPredicate = [NSPredicate predicateWithFormat:@"identifier LIKE 'trailingAnchorConstraint*'"];
    XCTAssertEqual([self.displayer.view.constraints filteredArrayUsingPredicate:trailingConstraintPredicate].count, 1);

    NSPredicate *bottomConstraintPredicate = [NSPredicate predicateWithFormat:@"identifier LIKE 'bottomAnchorConstraint*'"];
    XCTAssertEqual([self.displayer.view.constraints filteredArrayUsingPredicate:bottomConstraintPredicate].count, 1);

    XCTAssertEqual(self.displayer.view.constraints.count, 4);
}

- (void)testShouldSetupWebviewWithCommandContainingSpecificSize {
    OGAMraidAdWebView *webView = [[OGAMraidAdWebView alloc] init];
    webView.webViewId = @"test";

    UIView *view = [[UIView alloc] init];

    [view addSubview:webView];

    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeThumbnailAd);

    self.displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:OCMClassMock(OGAAd.self) adConfiguration:configuration];
    self.displayer.view = view;

    OGAMraidCreateWebViewCommand *command = [[OGAMraidCreateWebViewCommand alloc] init];
    command.size = @{@"width" : @(500), @"height" : @(500)};

    [self.displayer setupWebView:webView withCommand:command];

    NSPredicate *topConstraintPredicate = [NSPredicate predicateWithFormat:@"identifier LIKE 'topAnchorConstraint*'"];
    XCTAssertEqual([self.displayer.view.constraints filteredArrayUsingPredicate:topConstraintPredicate].count, 1);

    NSPredicate *leadingConstraintPredicate = [NSPredicate predicateWithFormat:@"identifier LIKE 'leadingAnchorConstraint*'"];
    XCTAssertEqual([self.displayer.view.constraints filteredArrayUsingPredicate:leadingConstraintPredicate].count, 1);

    NSPredicate *widthConstraintPredicate = [NSPredicate predicateWithFormat:@"identifier LIKE 'widthConstraint*'"];
    XCTAssertEqual([self.displayer.view.constraints filteredArrayUsingPredicate:widthConstraintPredicate].count, 1);

    NSPredicate *heightConstraintPredicate = [NSPredicate predicateWithFormat:@"identifier LIKE 'heightConstraint*'"];
    XCTAssertEqual([self.displayer.view.constraints filteredArrayUsingPredicate:heightConstraintPredicate].count, 1);

    XCTAssertEqual(self.displayer.view.constraints.count, 4);
}

- (void)testShouldReturnWebViewSize {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeBanner);
    OGAMraidCreateWebViewCommand *command = [[OGAMraidCreateWebViewCommand alloc] init];
    OGAMRAIDWebView *containerWebView = [[OGAMRAIDWebView alloc] init];

    UIView *view = OCMClassMock(UIView.self);

    self.displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:OCMClassMock(OGAAd.self) adConfiguration:configuration];
    self.displayer.view = view;

    CGSize size = [self.displayer sizeForWebViewWithConfiguration:configuration command:command view:view containerWebView:containerWebView];

    XCTAssertEqual(size.width, 0);
    XCTAssertEqual(size.height, 0);
}

- (void)testShouldReturnWebViewSizeWithBrowserWebView {
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);
    OCMStub(configuration.adType).andReturn(OguryAdsTypeBanner);
    OGAMraidCreateWebViewCommand *command = [[OGAMraidCreateWebViewCommand alloc] init];
    command.webViewId = OGANameBrowserWebView;
    OGAMRAIDWebView *containerWebView = [[OGAMRAIDWebView alloc] init];

    UIView *view = OCMClassMock(UIView.self);

    self.displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:OCMClassMock(OGAAd.self) adConfiguration:configuration];
    self.displayer.view = [[UIView alloc] init];

    CGSize size = [self.displayer sizeForWebViewWithConfiguration:configuration command:command view:view containerWebView:containerWebView];

    XCTAssertEqual(size.width, 0);
    XCTAssertEqual(size.height, 0);
}

- (void)testShouldReturnWebViewSizeWithContentWebView {
    id configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);
    [((OGAAdConfiguration *)[[configuration stub] andReturnValue:@(CGSizeMake(256, 256))]) size];
    [[[configuration stub] andReturnValue:@(OguryAdsTypeBanner)] adType];
    OGAMraidCreateWebViewCommand *command = [[OGAMraidCreateWebViewCommand alloc] init];
    command.webViewId = @"content";
    command.size = @{@"width" : @(128), @"height" : @(128)};
    OGAMRAIDWebView *containerWebView = [[OGAMRAIDWebView alloc] init];

    UIView *view = OCMClassMock(UIView.self);

    self.displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:OCMClassMock(OGAAd.self) adConfiguration:configuration];
    self.displayer.view = view;

    CGSize size = [self.displayer sizeForWebViewWithConfiguration:configuration command:command view:view containerWebView:containerWebView];

    XCTAssertEqual(size.width, 256);
    XCTAssertEqual(size.height, 256);
}

- (void)testShouldReturnMRAIDWebViewForID {
    NSString *commandString = @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"content\":\"<html><head>"
                              @"</head><body>It works!</body></html>\",\"size\":{\"width\":414,\"height\":896},\"position\":{\"x\":0,\"y\":0}}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];

    [self.displayer createWebView:command];

    OGAMraidAdWebView *webview = [self.displayer mraidViewForId:@"browser"];

    XCTAssertNotNil(webview);
}

- (void)testShouldSendExpandToDelegate {
    id delegate = OCMProtocolMock(@protocol(OGAAdDisplayerDelegate));

    self.displayer.delegate = delegate;

    OCMExpect([delegate performAction:[OCMArg isKindOfClass:OGAExpandAdAction.self] error:[OCMArg anyObjectRef]]);

    [self.displayer expand];

    OCMVerifyAll(delegate);
}

- (void)testShouldSendPortraitOrientationToDelegate {
    id delegate = OCMProtocolMock(@protocol(OGAAdDisplayerOrientationDelegate));
    self.displayer.orientationDelegate = delegate;
    NSString *commandString =
        @"{\"method\":\"setOrientationProperties\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"allowOrientationChange\":1,\"forceOrientation\":\"portrait\"}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];
    OCMExpect([delegate forceOrientation:UIInterfaceOrientationMaskPortrait]);
    [self.displayer setOrientationProperties:command];
    OCMVerifyAll(delegate);
}

- (void)testShouldSendLandscapeOrientationToDelegate {
    id delegate = OCMProtocolMock(@protocol(OGAAdDisplayerOrientationDelegate));
    self.displayer.orientationDelegate = delegate;
    NSString *commandString =
        @"{\"method\":\"setOrientationProperties\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"allowOrientationChange\":1,\"forceOrientation\":\"landscape\"}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];
    OCMExpect([delegate forceOrientation:UIInterfaceOrientationMaskLandscape]);
    [self.displayer setOrientationProperties:command];
    OCMVerifyAll(delegate);
}

- (void)testShouldSendMaskAllOrientationToDelegate {
    id delegate = OCMProtocolMock(@protocol(OGAAdDisplayerOrientationDelegate));
    self.displayer.orientationDelegate = delegate;
    NSString *commandString =
        @"{\"method\":\"setOrientationProperties\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"allowOrientationChange\":1,\"forceOrientation\":\"not a key\"}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];
    OCMExpect([delegate forceOrientation:UIInterfaceOrientationMaskAll]);
    [self.displayer setOrientationProperties:command];
    OCMVerifyAll(delegate);
}

- (void)testShouldSendAllowOrientationChangesTrueToDelegate {
    id delegate = OCMProtocolMock(@protocol(OGAAdDisplayerOrientationDelegate));
    self.displayer.orientationDelegate = delegate;
    NSString *commandString = @"{\"method\":\"setOrientationProperties\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"allowOrientationChange\":1}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];
    OCMExpect([delegate allowOrientationChange:true]);
    [self.displayer setOrientationProperties:command];
    OCMVerifyAll(delegate);
}

- (void)testShouldSendAllowOrientationChangesFalseToDelegate {
    id delegate = OCMProtocolMock(@protocol(OGAAdDisplayerOrientationDelegate));
    self.displayer.orientationDelegate = delegate;
    NSString *commandString = @"{\"method\":\"setOrientationProperties\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"allowOrientationChange\":0}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];
    OCMExpect([delegate allowOrientationChange:false]);
    [self.displayer setOrientationProperties:command];
    OCMVerifyAll(delegate);
}

- (void)testShouldSendForceCloseToDelegate {
    id delegate = OCMProtocolMock(@protocol(OGAAdDisplayerDelegate));

    self.displayer.delegate = delegate;

    OCMExpect([delegate performAction:[OCMArg isKindOfClass:OGAForceCloseAdAction.self] error:[OCMArg anyObjectRef]]);

    [self.displayer forceClose:[OGAMraidCommand MraidForceCloseCommandWithNextAdFalse]];
    OCMVerify([self.monitoringDispatcher sendShowEvent:OGAShowEventAdClose adConfiguration:[OCMArg any]]);
    OCMVerifyAll(delegate);
}

- (void)testShouldSendCloseWithoutNextAdToDelegateAfterUserPressedCloseButton {
    id<OGAAdDisplayerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdDisplayerDelegate));

    self.displayer.delegate = delegate;

    [self.displayer pressedSDKCloseButton];

    __block OGACloseAdAction *closeAdAction;
    OCMVerify([delegate performAction:[OCMArg checkWithBlock:^BOOL(id obj) {
                            closeAdAction = obj;
                            return [obj isKindOfClass:[OGACloseAdAction class]];
                        }]
                                error:[OCMArg anyObjectRef]]);
    XCTAssertNotNil(closeAdAction.nextAd);
    XCTAssertNotNil(closeAdAction.nextAd.showNextAd);
    XCTAssertFalse(closeAdAction.nextAd.showNextAd.boolValue);
}

- (void)testShouldSendForceCloseToDelegateForCloseFullAd {
    id delegate = OCMProtocolMock(@protocol(OGAAdDisplayerDelegate));

    self.displayer.delegate = delegate;

    NSString *commandString = @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"content\":\"<html><head>"
                              @"</head><body>It works!</body></html>\",\"size\":{\"width\":414,\"height\":896},\"position\":{\"x\":0,\"y\":0}}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];

    OCMExpect([delegate performAction:[OCMArg isKindOfClass:OGACloseAdAction.self] error:[OCMArg anyObjectRef]]);

    [self.displayer closeFullAd:command];
    OCMVerify([self.monitoringDispatcher sendShowEvent:OGAShowEventAdClose adConfiguration:self.ad.adConfiguration]);
    OCMVerifyAll(delegate);
}

- (void)testShouldCloseWebView {
    id delegate = OCMProtocolMock(@protocol(OGAAdDisplayerDelegate));

    self.displayer.delegate = delegate;

    NSString *commandString = @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"content\":\"<html><head>"
                              @"</head><body>It works!</body></html>\",\"size\":{\"width\":414,\"height\":896},\"position\":{\"x\":0,\"y\":0}}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];
    self.displayer.mraidDisplayerState = OGAAdMraidDisplayerStateBrowserOpened;

    [self.displayer createWebView:command];

    XCTAssertEqual(self.displayer.webviews.count, 2);

    [self.displayer closeWebView:command];

    XCTAssertEqual(self.displayer.webviews.count, 1);
    XCTAssertEqual(self.displayer.mraidDisplayerState, OGAAdMraidDisplayerStateLoaded);
}

- (void)testDispatchNoViewabilityAndZeroExposure {
    OGAMRAIDAdDisplayer *mockedDisplayer = OCMPartialMock(self.displayer);
    [mockedDisplayer dispatchNoViewabilityAndZeroExposure];
    OCMVerify([mockedDisplayer dispatchInformation:[OCMArg checkWithBlock:^BOOL(id value) {
                                   if ([value isKindOfClass:[OGAAdDisplayerUpdateExposureInformation class]]) {
                                       OGAAdDisplayerUpdateExposureInformation *information = value;
                                       return information.adExposure == 0;
                                   } else if ([value isKindOfClass:[OGAAdDisplayerUpdateViewabilityInformation class]]) {
                                       OGAAdDisplayerUpdateViewabilityInformation *information = value;
                                       return information.isViewable == false;
                                   }
                                   return false;
                               }]]);
}

- (void)testShouldExecuteBackActionForWebview {
    NSString *commandString = @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"content\":\"<html><head>"
                              @"</head><body>It works!</body></html>\",\"size\":{\"width\":414,\"height\":896},\"position\":{\"x\":0,\"y\":0}}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];

    [self.displayer createWebView:command];

    OGAMRAIDAdDisplayer *mockedDisplayer = OCMPartialMock(self.displayer);

    OCMExpect([mockedDisplayer mraidViewForId:@"browser"]);

    [mockedDisplayer executeBackActionForWebViewId:@"browser"];

    OCMVerify([mockedDisplayer mraidViewForId:@"browser"]);
}

- (void)testShouldExecuteForwardActionForWebview {
    NSString *commandString = @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"content\":\"<html><head>"
                              @"</head><body>It works!</body></html>\",\"size\":{\"width\":414,\"height\":896},\"position\":{\"x\":0,\"y\":0}}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];

    [self.displayer createWebView:command];

    OGAMRAIDAdDisplayer *mockedDisplayer = OCMPartialMock(self.displayer);

    OCMExpect([mockedDisplayer mraidViewForId:@"browser"]);

    [mockedDisplayer executeForwardActionForWebViewId:@"browser"];

    OCMVerify([mockedDisplayer mraidViewForId:@"browser"]);
}

- (void)testShouldResizeProps {
    NSString *commandString = @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"content\":\"<html><head>"
                              @"</head><body>It works!</body></html>\",\"size\":{\"width\":414,\"height\":896},\"position\":{\"x\":0,\"y\":0}}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];

    [self.displayer createWebView:command];

    OGAMRAIDAdDisplayer *mockedDisplayer = OCMPartialMock(self.displayer);

    OCMExpect([mockedDisplayer handleResizeCommand:command]);

    [mockedDisplayer resizeProps:command];

    OCMVerify([mockedDisplayer handleResizeCommand:command]);
}

- (void)testShouldUpdateWebViewForResize {
    NSString *commandString =
        @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"size\":{\"width\":414,\"height\":896}}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];

    [self.displayer createWebView:command];

    OGAMRAIDAdDisplayer *mockedDisplayer = OCMPartialMock(self.displayer);

    OCMExpect([mockedDisplayer handleResizeCommand:command]);

    [mockedDisplayer updateWebView:command];

    OCMVerify([mockedDisplayer handleResizeCommand:command]);
}

- (void)testShouldUpdateWebViewForURLChange {
    NSString *commandString =
        @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"url\":\"https://www.google.com\"}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];

    [self.displayer createWebView:command];

    OGAMRAIDAdDisplayer *mockedDisplayer = OCMPartialMock(self.displayer);

    OCMExpect([mockedDisplayer mraidViewForId:@"browser"]);

    [mockedDisplayer updateWebView:command];

    OCMVerify([mockedDisplayer mraidViewForId:@"browser"]);
}

- (void)testShouldHandleResizeCommand {
    OGAMRAIDAdDisplayer *mockDisplayer = OCMPartialMock(self.displayer);

    id delegate = OCMProtocolMock(@protocol(OGAAdDisplayerDelegate));

    mockDisplayer.delegate = delegate;

    NSString *commandString =
        @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"size\":{\"width\":414,\"height\":896}}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];

    [self.displayer createWebView:command];

    OCMExpect([mockDisplayer setupWebView:OCMOCK_ANY withCommand:OCMOCK_ANY]);

    [self.displayer handleResizeCommand:command];

    OCMVerifyAll(delegate);
}

- (void)testShouldCallDidLoadOnDelegateWhenWebviewIsReady {
    id delegate = OCMProtocolMock(@protocol(OGAAdDisplayerDelegate));

    self.displayer.delegate = delegate;

    OCMExpect([delegate didLoad]);

    [self.displayer webViewReady:@""];

    OCMVerifyAll(delegate);
}

- (void)testUnloadAd {
    id delegate = OCMProtocolMock(@protocol(OGAAdDisplayerDelegate));

    self.displayer.delegate = delegate;

    NSString *commandString = @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"content\":\"<html><head>"
                              @"</head><body>It works!</body></html>\",\"size\":{\"width\":414,\"height\":896},\"position\":{\"x\":0,\"y\":0}}}";

    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];

    OCMExpect([delegate performAction:[OCMArg isKindOfClass:OGAUnloadAdAction.self] error:[OCMArg anyObjectRef]]);

    [self.displayer unloadAd:command origin:UnloadOriginFormat];

    OCMVerifyAll(delegate);
}

- (void)testWhenFormatUnloadAdInForegroundThenProperEventIsDispatched {
    id delegate = OCMClassMock([OGAAdController class]);
    self.displayer.delegate = delegate;
    NSString *commandString = @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"content\":\"<html><head>"
                              @"</head><body>It works!</body></html>\",\"size\":{\"width\":414,\"height\":896},\"position\":{\"x\":0,\"y\":0}}}";
    OCMStub([delegate adIsDisplayed]).andReturn(YES);
    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];
    [self.displayer unloadAd:command origin:UnloadOriginFormat];
    OCMVerify([self.monitoringDispatcher sendShowEvent:OGAShowEventForegroundUnload adConfiguration:[OCMArg any]]);
}

- (void)testWhenFormatUnloadAdInBackgroundThenProperEventIsDispatched {
    id delegate = OCMClassMock([OGAAdController class]);
    self.displayer.delegate = delegate;
    NSString *commandString = @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"content\":\"<html><head>"
                              @"</head><body>It works!</body></html>\",\"size\":{\"width\":414,\"height\":896},\"position\":{\"x\":0,\"y\":0}}}";
    OCMStub([delegate adIsDisplayed]).andReturn(NO);
    OCMStub([delegate isLoaded]).andReturn(YES);
    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];
    [self.displayer unloadAd:command origin:UnloadOriginFormat];
    OCMVerify([self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdBackgroundUnloaded adConfiguration:[OCMArg any]]);
}

- (void)testWhenFormatUnloadUnloadedAdThenProperEventIsDispatched {
    id delegate = OCMClassMock([OGAAdController class]);
    self.displayer.delegate = delegate;
    NSString *commandString = @"{\"method\":\"ogyCreateWebView\",\"callbackId\":\"ogyCreateWebView:c2f9c588-9a25-4a47-9bf6-1b099fe24b2a\",\"args\":{\"webViewId\":\"browser\",\"content\":\"<html><head>"
                              @"</head><body>It works!</body></html>\",\"size\":{\"width\":414,\"height\":896},\"position\":{\"x\":0,\"y\":0}}}";
    OCMStub([delegate isLoaded]).andReturn(NO);
    OGAMraidCommand *command = [[OGAMraidCommand alloc] initWithString:commandString error:nil];
    [self.displayer unloadAd:command origin:UnloadOriginFormat];

    OCMVerify([self.monitoringDispatcher sendLoadErrorEventPrecacheFail:OGAMonitoringPrecacheErrorUnload adConfiguration:[OCMArg any]]);
}

- (void)testShouldCallDidLoadOnDelegateWhenWebviewUnload {
    id delegate = OCMProtocolMock(@protocol(OGAAdDisplayerDelegate));

    self.displayer.delegate = delegate;
    self.displayer.mraidDisplayerState = OGAAdMraidDisplayerStateEnded;
    OCMStub([self.configuration webviewLoadTimeout]).andReturn(@3);
    OCMExpect([delegate didUnLoadFrom:UnloadOriginFormat]);

    [self.displayer webViewReady:@""];

    OCMVerifyAll(delegate);
}

- (void)testStartOMIDSessionOnShowOnlyMainView {
    OGAAd *ad = OCMClassMock(OGAAd.self);
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);

    self.displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:ad adConfiguration:configuration]);

    OGAMRAIDWebView *mainWebView = OCMClassMock(OGAMRAIDWebView.self);
    OCMStub(mainWebView.webViewId).andReturn(OGANameMainWebView);

    NSArray<OGAMRAIDWebView *> *webViews = @[ mainWebView ];

    OCMStub(self.displayer.webviews).andReturn(webViews);

    [self.displayer startOMIDSessionOnShow];

    OCMVerify([mainWebView startOMIDSessionOnShow]);
}

- (void)testStartOMIDSessionOnShowSeveralView {
    OGAAd *ad = OCMClassMock(OGAAd.self);
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);

    self.displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:ad adConfiguration:configuration]);

    OGAMRAIDWebView *mainWebView = OCMClassMock(OGAMRAIDWebView.self);
    OCMStub(mainWebView.webViewId).andReturn(OGANameMainWebView);

    OGAMRAIDWebView *browserWebView = OCMClassMock(OGAMRAIDWebView.self);
    OCMStub(browserWebView.webViewId).andReturn(OGANameBrowserWebView);

    NSArray<OGAMRAIDWebView *> *webViews = @[ browserWebView, mainWebView ];

    OCMStub(self.displayer.webviews).andReturn(webViews);

    [self.displayer startOMIDSessionOnShow];

    OCMVerify([mainWebView startOMIDSessionOnShow]);
}

- (void)testWhenCallingBunaZiua_ThenStateManagerIsUpdated {
    OGAAd *ad = OCMPartialMock([OGAAd new]);
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);
    self.displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:ad adConfiguration:configuration];
    id<OGAMRAIDWebViewDelegate> webDelegate = OCMProtocolMock(@protocol(OGAMRAIDWebViewDelegate));
    id<OGAAdLoadStateManagerErrorDelegate> errorDelegate = OCMProtocolMock(@protocol(OGAAdLoadStateManagerErrorDelegate));
    OGAMonitoringDispatcher *dispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    OGAAdLoadStateManager *stateManager = [[OGAAdLoadStateManager alloc] init:self.ad timeout:@80 webDelegate:webDelegate errorDelegate:errorDelegate monitoringDispatcher:dispatcher];
    //    OGAAdConfiguration* adConf = OCMClassMock([OGAAdConfiguration class]);
    //    OCMStub([ad adConfiguration]).andReturn(adConf);
    //    OCMStub([adConf sessionId]).andReturn(@"LKUHIOHN");
    //    OCMStub([ad rawLoadedSource]).andReturn(@"JUYGFUFGYT");

    self.displayer.stateManager = stateManager;
    // now bunaZiua must be called twice in order for the state manager to be informed (format specifications)
    [self.displayer bunaZiua];
    [self.displayer bunaZiua];
    XCTAssertTrue(self.displayer.stateManager.webviewReadyToLoad);
}

- (void)testWhenCallingBunaZiuaTwice_ThenStateManagerIsUpdated {
    OGAAd *ad = OCMClassMock(OGAAd.self);
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);
    self.displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:ad adConfiguration:configuration];
    id<OGAMRAIDWebViewDelegate> webDelegate = OCMProtocolMock(@protocol(OGAMRAIDWebViewDelegate));
    id<OGAAdLoadStateManagerErrorDelegate> errorDelegate = OCMProtocolMock(@protocol(OGAAdLoadStateManagerErrorDelegate));
    OGAMonitoringDispatcher *dispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    OGAAdLoadStateManager *stateManager = [[OGAAdLoadStateManager alloc] init:self.ad timeout:@80 webDelegate:webDelegate errorDelegate:errorDelegate monitoringDispatcher:dispatcher];
    OGAAdConfiguration *adConf = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([ad adConfiguration]).andReturn(adConf);
    OCMStub([adConf webviewLoadTimeout]).andReturn(@3);
    OCMStub(adConf.monitoringDetails.sessionId).andReturn(@"LKUHIOHN");
    self.displayer.stateManager = stateManager;
    [self.displayer bunaZiua];
    XCTAssertTrue(self.displayer.stateManager.webviewReadyToLoad);
    XCTAssertFalse(self.displayer.stateManager.mraidEnvironmentIsUp);
    [self.displayer bunaZiua];
    [self.displayer bunaZiua];
    XCTAssertTrue(self.displayer.stateManager.mraidEnvironmentIsUp);
}

- (void)testWhenWebviewIsLoaded_ThenStateManagerIsUpdated {
    OGAAd *ad = OCMClassMock(OGAAd.self);
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);
    self.displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:ad adConfiguration:configuration]);
    id<OGAMRAIDWebViewDelegate> webDelegate = OCMProtocolMock(@protocol(OGAMRAIDWebViewDelegate));
    id<OGAAdLoadStateManagerErrorDelegate> errorDelegate = OCMProtocolMock(@protocol(OGAAdLoadStateManagerErrorDelegate));
    OGAAdLoadStateManager *stateManager = [[OGAAdLoadStateManager alloc] initWithAd:self.ad timeout:@80 webDelegate:webDelegate errorDelegate:errorDelegate];
    OCMStub(self.displayer.stateManager).andReturn(stateManager);
    [self.displayer webViewLoaded:@"identifier"];
    OCMVerify([stateManager webViewLoaded:@"identifier"]);
}

- (void)testFormatDidLoadAd_ThenStateManagerIsUpdated {
    OGAAd *ad = OCMClassMock(OGAAd.self);
    OGAAdConfiguration *configuration = OCMClassMock([OGAAdConfiguration class]);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);
    self.displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:ad adConfiguration:configuration];
    id<OGAMRAIDWebViewDelegate> webDelegate = OCMProtocolMock(@protocol(OGAMRAIDWebViewDelegate));
    id<OGAAdLoadStateManagerErrorDelegate> errorDelegate = OCMProtocolMock(@protocol(OGAAdLoadStateManagerErrorDelegate));
    OGAMonitoringDispatcher *dispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    OGAAdLoadStateManager *stateManager = [[OGAAdLoadStateManager alloc] init:self.ad timeout:@80 webDelegate:webDelegate errorDelegate:errorDelegate monitoringDispatcher:dispatcher];
    self.displayer.stateManager = stateManager;
    [self.displayer formatDidLoadAd];
    XCTAssertTrue(self.displayer.stateManager.formatLoaded);
}

- (void)testWhenSUTReceivesLoadingTimeOut_ThenItShouldCallTheDelegate {
    id<OGAAdDisplayerDelegate> delegate = OCMProtocolMock(@protocol(OGAAdDisplayerDelegate));
    self.displayer.delegate = delegate;
    [self.displayer loadTimedOut];
    OCMVerify([delegate didUnLoadFrom:UnloadOriginTimeout]);
}

- (void)testWhenWebkitProcessIsTerminated_ThenScriptIsRemovedFromContainerWebview {
    OGAMRAIDWebView *containerWebView = OCMClassMock([OGAMRAIDWebView class]);
    self.displayer.containerWebView = containerWebView;
    OCMStub(self.displayer.ad.maxNumberOfReloadWebView).andReturn(@1);
    [self.displayer webkitProcessDidTerminate];
    OCMVerify([containerWebView removeScriptMessageHandler]);
}

- (void)testWhenWebkitProcessIsTerminated_ThenStateManagerIsReseted {
    OGAAdLoadStateManager *stateManager = OCMClassMock([OGAAdLoadStateManager class]);
    self.displayer.stateManager = stateManager;
    OCMStub(self.displayer.ad.maxNumberOfReloadWebView).andReturn(@1);
    [self.displayer webkitProcessDidTerminate];
    OCMVerify([stateManager reset]);
}

- (void)testWhenWebkitProcessIsTerminated_ThenMraidStateIsSetToLoaded {
    OCMStub(self.displayer.ad.maxNumberOfReloadWebView).andReturn(@1);
    [self.displayer webkitProcessDidTerminate];
    XCTAssertEqual(self.displayer.mraidDisplayerState, OGAAdMraidDisplayerStateLoaded);
}

- (void)testWhenWebkitProcessIsTerminated_ThenViewsAreRemoved {
    OGAMRAIDAdDisplayer *displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:self.ad
                                                                            adConfiguration:self.configuration
                                                                              adSyncManager:self.adSyncManager
                                                                      landingPagePrefetcher:self.prefetcher
                                                                             metricsService:self.metricsService
                                                                          userDefaultsStore:self.userDefaultStore
                                                                                application:self.application
                                                                        adImpressionManager:self.impressionManager
                                                                      webViewCleanupManager:self.webViewCleanupManager
                                                                       monitoringDispatcher:self.monitoringDispatcher
                                                                              profigManager:self.profigManager
                                                                                        log:self.log]);
    XCTAssertNotNil(displayer.containerWebView);
    OCMStub([displayer setupViews])
        .andDo(^(NSInvocation *invocation){

        });
    OCMStub([displayer setupWebView:[OCMArg any] withCommand:[OCMArg any]])
        .andDo(^(NSInvocation *invocation){

        });
    OCMStub(self.displayer.ad.maxNumberOfReloadWebView).andReturn(@1);
    [displayer webkitProcessDidTerminate];
    XCTAssertNil(displayer.containerWebView);
    XCTAssertEqual(displayer.webviews.count, 0);
}

- (void)testWhenWebkitProcessIsTerminated_ThenViewsAreCreated {
    [self.displayer webkitProcessDidTerminate];
    XCTAssertNotNil(self.displayer.containerWebView);
    XCTAssertEqual(self.displayer.webviews.count, 1);
}

- (void)testWhenChangeStateInformationIsReceived_ThenStateIsSetAccordingly {
    OGAAdDisplayerUpdateStateInformation *information = [[OGAAdDisplayerUpdateStateInformation alloc] initWithMraidState:OGAMRAIDStateDefault];
    XCTAssertEqual(information.rawMraidState, OGAMRAIDStateDefault);
    [self.displayer dispatchInformation:information];
    XCTAssertEqual(self.displayer.mraidDisplayerState, OGAAdMraidDisplayerStateDefault);
}

- (void)testWebkitProcessIsTerminatedMaxAttend {
    OGAMRAIDAdDisplayer *displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:self.ad
                                                                            adConfiguration:self.configuration
                                                                              adSyncManager:self.adSyncManager
                                                                      landingPagePrefetcher:self.prefetcher
                                                                             metricsService:self.metricsService
                                                                          userDefaultsStore:self.userDefaultStore
                                                                                application:self.application
                                                                        adImpressionManager:self.impressionManager
                                                                      webViewCleanupManager:self.webViewCleanupManager
                                                                       monitoringDispatcher:self.monitoringDispatcher
                                                                              profigManager:self.profigManager
                                                                                        log:self.log]);

    OCMReject([displayer unloadAd:[OCMArg any] origin:UnloadOriginFormat]);
    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
    XCTAssertNotNil(displayer.containerWebView);
    XCTAssertEqual(displayer.webviews.count, 1);
}

- (void)testWebkitProcessIsTerminatedMaxAttendZero {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub([ad maxNumberOfReloadWebView]).andReturn(@0);

    OGAMRAIDAdDisplayer *displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:ad
                                                                            adConfiguration:self.configuration
                                                                              adSyncManager:self.adSyncManager
                                                                      landingPagePrefetcher:self.prefetcher
                                                                             metricsService:self.metricsService
                                                                          userDefaultsStore:self.userDefaultStore
                                                                                application:self.application
                                                                        adImpressionManager:self.impressionManager
                                                                      webViewCleanupManager:self.webViewCleanupManager
                                                                       monitoringDispatcher:self.monitoringDispatcher
                                                                              profigManager:self.profigManager
                                                                                        log:self.log]);
    OGAMRAIDWebView *containerWebView = OCMClassMock([OGAMRAIDWebView class]);
    displayer.containerWebView = containerWebView;

    [displayer webkitProcessDidTerminate];
    OCMReject([containerWebView removeScriptMessageHandler]);
}

- (void)testWebkitProcessIsTerminatedMaxAttendPlusOne {
    OGAMRAIDAdDisplayer *displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:self.ad
                                                                            adConfiguration:self.configuration
                                                                              adSyncManager:self.adSyncManager
                                                                      landingPagePrefetcher:self.prefetcher
                                                                             metricsService:self.metricsService
                                                                          userDefaultsStore:self.userDefaultStore
                                                                                application:self.application
                                                                        adImpressionManager:self.impressionManager
                                                                      webViewCleanupManager:self.webViewCleanupManager
                                                                       monitoringDispatcher:self.monitoringDispatcher
                                                                              profigManager:self.profigManager
                                                                                        log:self.log]);
    OGAMRAIDWebView *containerWebView = OCMClassMock([OGAMRAIDWebView class]);
    displayer.containerWebView = containerWebView;

    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
    OCMReject([containerWebView removeScriptMessageHandler]);
}

- (void)testWebkitProcessIsTerminatedMaxAttendFromAdConfig {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub([ad maxNumberOfReloadWebView]).andReturn(@5);

    OGAMRAIDAdDisplayer *displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:ad
                                                                            adConfiguration:self.configuration
                                                                              adSyncManager:self.adSyncManager
                                                                      landingPagePrefetcher:self.prefetcher
                                                                             metricsService:self.metricsService
                                                                          userDefaultsStore:self.userDefaultStore
                                                                                application:self.application
                                                                        adImpressionManager:self.impressionManager
                                                                      webViewCleanupManager:self.webViewCleanupManager
                                                                       monitoringDispatcher:self.monitoringDispatcher
                                                                              profigManager:self.profigManager
                                                                                        log:self.log]);

    OCMReject([displayer closeFullAd:[OCMArg any]]);
    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
}

- (void)testWebkitProcessIsTerminatedMaxAttendFromAdConfigPlusOne {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub([ad maxNumberOfReloadWebView]).andReturn(@5);

    OGAMRAIDAdDisplayer *displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:ad
                                                                            adConfiguration:self.configuration
                                                                              adSyncManager:self.adSyncManager
                                                                      landingPagePrefetcher:self.prefetcher
                                                                             metricsService:self.metricsService
                                                                          userDefaultsStore:self.userDefaultStore
                                                                                application:self.application
                                                                        adImpressionManager:self.impressionManager
                                                                      webViewCleanupManager:self.webViewCleanupManager
                                                                       monitoringDispatcher:self.monitoringDispatcher
                                                                              profigManager:self.profigManager
                                                                                        log:self.log]);
    OGAMRAIDWebView *containerWebView = OCMClassMock([OGAMRAIDWebView class]);
    displayer.containerWebView = containerWebView;

    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
    OCMReject([containerWebView removeScriptMessageHandler]);
}

- (void)testWhenWebkitProcessIsTerminatedWithOpenedWebViewThenCloseAdIsCalled {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub([ad maxNumberOfReloadWebView]).andReturn(@5);
    OGAMRAIDAdDisplayer *displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:ad
                                                                            adConfiguration:self.configuration
                                                                              adSyncManager:self.adSyncManager
                                                                      landingPagePrefetcher:self.prefetcher
                                                                             metricsService:self.metricsService
                                                                          userDefaultsStore:self.userDefaultStore
                                                                                application:self.application
                                                                        adImpressionManager:self.impressionManager
                                                                      webViewCleanupManager:self.webViewCleanupManager
                                                                       monitoringDispatcher:self.monitoringDispatcher
                                                                              profigManager:self.profigManager
                                                                                        log:self.log]);
    OCMStub(displayer.mraidDisplayerState).andReturn(OGAAdMraidDisplayerStateBrowserOpened);
    [displayer webkitProcessDidTerminate];
    OCMVerify([displayer closeFullAd:[OCMArg any]]);
}

- (void)testWhenWebKitProcessIsTerminatedAndMaxAttendIsReachedThenStateIsSetToProperValue {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub([ad maxNumberOfReloadWebView]).andReturn(@0);

    OGAMRAIDAdDisplayer *displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:ad
                                                                            adConfiguration:self.configuration
                                                                              adSyncManager:self.adSyncManager
                                                                      landingPagePrefetcher:self.prefetcher
                                                                             metricsService:self.metricsService
                                                                          userDefaultsStore:self.userDefaultStore
                                                                                application:self.application
                                                                        adImpressionManager:self.impressionManager
                                                                      webViewCleanupManager:self.webViewCleanupManager
                                                                       monitoringDispatcher:self.monitoringDispatcher
                                                                              profigManager:self.profigManager
                                                                                        log:self.log]);
    [displayer webkitProcessDidTerminate];
    XCTAssertEqual(displayer.mraidDisplayerState, OGAAdMraidDisplayerStateKilled);
}

- (void)testWhenWebKitProcessIsTerminatedThenLoadInformationIsDispatched {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub(ad.html).andReturn(@"<html></html>");
    OCMStub([ad maxNumberOfReloadWebView]).andReturn(@0);

    OGAMRAIDAdDisplayer *displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:ad
                                                                            adConfiguration:self.configuration
                                                                              adSyncManager:self.adSyncManager
                                                                      landingPagePrefetcher:self.prefetcher
                                                                             metricsService:self.metricsService
                                                                          userDefaultsStore:self.userDefaultStore
                                                                                application:self.application
                                                                        adImpressionManager:self.impressionManager
                                                                      webViewCleanupManager:self.webViewCleanupManager
                                                                       monitoringDispatcher:self.monitoringDispatcher
                                                                              profigManager:self.profigManager
                                                                                        log:self.log]);
    OGAOrderedDictionary *details = [[OGAOrderedDictionary alloc] initWithDictionary:@{
        @"max_reload_attempts_reached" : @YES,
        @"webview_termination" : @(1)
    }];
    [displayer webkitProcessDidTerminate];
    OCMVerify([self.monitoringDispatcher sendLoadEvent:OGALoadEventWebviewTerminatedByOS
                                       adConfiguration:[OCMArg any]
                                               details:details]);
}

- (void)testWhenWebKitProcessIsTerminatedThenLoadInformationIsDispatchedWithProperDetails {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub(ad.html).andReturn(@"<html></html>");
    OCMStub([ad maxNumberOfReloadWebView]).andReturn(@1);

    OGAMRAIDAdDisplayer *displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:ad
                                                                            adConfiguration:self.configuration
                                                                              adSyncManager:self.adSyncManager
                                                                      landingPagePrefetcher:self.prefetcher
                                                                             metricsService:self.metricsService
                                                                          userDefaultsStore:self.userDefaultStore
                                                                                application:self.application
                                                                        adImpressionManager:self.impressionManager
                                                                      webViewCleanupManager:self.webViewCleanupManager
                                                                       monitoringDispatcher:self.monitoringDispatcher
                                                                              profigManager:self.profigManager
                                                                                        log:self.log]);
    OGAOrderedDictionary *details = [[OGAOrderedDictionary alloc] initWithDictionary:@{
        @"max_reload_attempts_reached" : @NO,
        @"webview_termination" : @(1)
    }];
    [displayer webkitProcessDidTerminate];
    OCMVerify([self.monitoringDispatcher sendLoadEvent:OGALoadEventWebviewTerminatedByOS
                                       adConfiguration:[OCMArg any]
                                               details:details]);
}

- (void)testWhenEulaAcceptedIsReceivedThenProfigIsReset {
    [(id<OGAMraidCommandsHandlerDelegate>)self.displayer eulaConsentStatus:YES];
    OCMVerify([self.profigManager resetProfig]);
}

- (void)testWhenEulaRejectedIsReceivedThenProfigIsReset {
    [(id<OGAMraidCommandsHandlerDelegate>)self.displayer eulaConsentStatus:NO];
    OCMVerify([self.profigManager resetProfig]);
}

- (void)testWhenWebKitProcessIsTerminatedTwiceThenCounterIsIncremented {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OCMStub([ad maxNumberOfReloadWebView]).andReturn(@2);
    OGAAdConfiguration *conf = OCMPartialMock([OGAAdConfiguration new]);
    OCMStub(ad.adConfiguration).andReturn(conf);

    OGAMRAIDAdDisplayer *displayer = OCMPartialMock([[OGAMRAIDAdDisplayer alloc] initWithAd:ad
                                                                            adConfiguration:conf
                                                                              adSyncManager:self.adSyncManager
                                                                      landingPagePrefetcher:self.prefetcher
                                                                             metricsService:self.metricsService
                                                                          userDefaultsStore:self.userDefaultStore
                                                                                application:self.application
                                                                        adImpressionManager:self.impressionManager
                                                                      webViewCleanupManager:self.webViewCleanupManager
                                                                       monitoringDispatcher:self.monitoringDispatcher
                                                                              profigManager:self.profigManager
                                                                                        log:self.log]);
    [displayer webkitProcessDidTerminate];
    [displayer webkitProcessDidTerminate];
    XCTAssertEqual(displayer.numberOfReloadAttempts, 2);
}

@end
