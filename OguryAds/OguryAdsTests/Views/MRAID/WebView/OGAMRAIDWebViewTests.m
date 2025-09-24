//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "OGAAd.h"
#import "OGAMRAIDWebView.h"
#import "OGAMonitoringDispatcher.h"

@interface OGAMRAIDWebView ()

@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;

- (void)setupMKWebView;
- (void)loadWithContent:(NSString *)content;
- (instancetype)initWithAd:(OGAAd *)ad
              stateManager:(OGAAdLoadStateManager *)stateManager
      monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher;

@end

@interface OGAMRAIDWebViewTests : XCTestCase

@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAMRAIDWebView *mraidWebView;
@property(nonatomic, strong) OGAAd *ad;
@property(nonatomic, strong) OGAAdConfiguration *adConfiguration;
@property(nonatomic, strong) OGAAdLoadStateManager *stateManager;

@end

@implementation OGAMRAIDWebViewTests

- (void)setUp {
    self.monitoringDispatcher = OCMClassMock(OGAMonitoringDispatcher.self);
    self.ad = OCMClassMock(OGAAd.self);
    self.adConfiguration = OCMClassMock(OGAAdConfiguration.self);
    self.stateManager = OCMClassMock(OGAAdLoadStateManager.self);
    OCMStub(self.ad.adConfiguration).andReturn(self.adConfiguration);
    self.mraidWebView = OCMPartialMock([[OGAMRAIDWebView alloc] initWithAd:self.ad
                                                              stateManager:self.stateManager
                                                      monitoringDispatcher:self.monitoringDispatcher]);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
- (void)testinitWithAd {
    XCTAssertNotNil([self.mraidWebView initWithAd:self.ad stateManager:self.stateManager]);
    OCMVerify([self.mraidWebView initWithAd:self.ad stateManager:[OCMArg any] monitoringDispatcher:[OCMArg any]]);
}
#pragma clang diagnostic pop

- (void)testinitWithAdMonitoringDispatcher {
    OGAMRAIDWebView *newMraidWebView = [self.mraidWebView initWithAd:self.ad
                                                        stateManager:self.stateManager
                                                monitoringDispatcher:self.monitoringDispatcher];
    XCTAssertNotNil(newMraidWebView);
    XCTAssertEqual(self.monitoringDispatcher, newMraidWebView.monitoringDispatcher);
    OCMVerify([self.mraidWebView setupMKWebView]);
}

- (void)testSetupMKWebViewWithFiledHtml {
    NSString *filedHtml = @"<html></html>";
    NSString *rawLoadedSource = @"sdk";
    OCMStub(self.ad.html).andReturn(filedHtml);
    OCMStub([self.ad getRawLoadedSource]).andReturn(rawLoadedSource);
    [self.mraidWebView setupMKWebView];
    OCMVerify([self.mraidWebView loadWithContent:filedHtml]);
    OCMVerify([self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdPrecaching adConfiguration:self.adConfiguration];);
}

@end
