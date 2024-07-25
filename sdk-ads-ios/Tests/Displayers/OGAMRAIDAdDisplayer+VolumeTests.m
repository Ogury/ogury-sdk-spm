//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAMRAIDAdDisplayer.h"
#import "OGAMRAIDAdDisplayer+Testing.h"
#import "OGAMRAIDAdDisplayer+Volume.h"
#import "OGAAd.h"
#import "OGAMraidCommand.h"
#import "OGAExpandAdAction.h"
#import "OGACloseAdAction.h"
#import "OGAForceCloseAdAction.h"
#import "OGAOMIDSession.h"
#import "OGAMraidCreateWebViewCommand.h"
#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAAdDisplayerUpdateViewabilityInformation.h"
#import <MediaPlayer/MPVolumeView.h>
#import "OGAJavascriptCommandExecutor.h"
#import "OGAAdImpressionManager.h"
#import "OGALog.h"
#import "OGAMonitoringDispatcher.h"

@interface OGAMRAIDAdDisplayer_VolumeTests : XCTestCase

@property(nonatomic, strong) OGAAdSyncManager *adSyncManager;
@property(nonatomic, strong) OGAAdLandingPagePrefetcher *prefetcher;
@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong) OGAUserDefaultsStore *userDefaultStore;
@property(nonatomic, strong) UIApplication *application;
@property(nonatomic, strong) OGAMRAIDAdDisplayer *displayer;
@property(nonatomic, assign) OGAWebViewCleanupManager *webViewCleanupManager;
@property(nonatomic, assign) OGAAdImpressionManager *impressionManager;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAProfigManager *profigManager;
@property(nonatomic, strong) OGALog *log;

@end

@interface OGAMRAIDAdDisplayer ()

@property(nonatomic, assign) OGAAdMraidDisplayerState state;
@property(nonatomic, strong) MPVolumeView *mpVolumeView;
@property(nonatomic, strong) UISlider *volumeSlider;

- (void)dispatchNoViewabilityAndZeroExposure;

- (void)volumeDidChange:(UISlider *)sender;

- (void)setupVolumeView;

- (void)setupViews;

@end

@implementation OGAMRAIDAdDisplayer_VolumeTests

- (void)setUp {
    self.log = OCMClassMock([OGALog class]);
    self.adSyncManager = OCMClassMock([OGAAdSyncManager class]);
    self.prefetcher = OCMClassMock([OGAAdLandingPagePrefetcher class]);
    self.metricsService = OCMClassMock([OGAMetricsService class]);
    self.userDefaultStore = [OGAUserDefaultsStore shared];
    self.application = UIApplication.sharedApplication;
    self.webViewCleanupManager = [OGAWebViewCleanupManager shared];
    self.impressionManager = [OGAAdImpressionManager shared];
    self.monitoringDispatcher = OCMClassMock([OGAMonitoringDispatcher class]);
    self.profigManager = OCMClassMock([OGAProfigManager class]);
    OGAAdConfiguration *configuration = OCMClassMock(OGAAdConfiguration.self);
    OCMStub([configuration webviewLoadTimeout]).andReturn(@3);

    self.displayer = [[OGAMRAIDAdDisplayer alloc] initWithAd:OCMClassMock(OGAAd.self)
                                             adConfiguration:configuration
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

- (void)testVolumeDidChange {
    OGAMRAIDWebView *webview = OCMClassMock(OGAMRAIDWebView.self);
    OGAJavascriptCommandExecutor *commandExecutor = OCMClassMock([OGAJavascriptCommandExecutor class]);
    self.displayer.volumeSlider = OCMClassMock([UISlider class]);
    OCMStub(webview.commandExecutor).andReturn(commandExecutor);
    OCMStub(self.displayer.volumeSlider.value).andReturn(0.34f);
    self.displayer.webviews = [NSMutableArray arrayWithCapacity:1];
    [self.displayer.webviews addObject:webview];
    [self.displayer volumeDidChange:self.displayer.volumeSlider];
    OCMVerify([commandExecutor updateAudioVolume:34]);
}

- (void)testSetupVolumeView {
    [self.displayer setupVolumeView];
    XCTAssertNotNil(self.displayer.volumeSlider);
    XCTAssertNotNil(self.displayer.mpVolumeView);
}

- (void)testRegisterForVolumeChangeForVolumeSilder {
    self.displayer.volumeSlider = OCMClassMock([UISlider class]);
    OCMStub([self.displayer volumeDidChange:self.displayer.volumeSlider]);
    [self.displayer registerForVolumeChangeFromVolumeSlider];
    OCMVerify([self.displayer volumeDidChange:self.displayer.volumeSlider]);
    OCMVerify([self.displayer.volumeSlider addTarget:[OCMArg any] action:[OCMArg anySelector] forControlEvents:UIControlEventValueChanged]);
}

@end
