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
    id instanceMock = OCMPartialMock([OGAMRAIDWebView alloc]); // juste l’alloc
    id classMock = OCMClassMock([OGAMRAIDWebView class]);
    
    OCMStub([classMock alloc]).andReturn(instanceMock);
    OCMExpect([instanceMock initWithAd:[OCMArg any]
                          stateManager:[OCMArg any]
                  monitoringDispatcher:[OCMArg any]]).andForwardToRealObject();
    
    [[OGAMRAIDWebView alloc] initWithAd:self.ad stateManager:self.stateManager monitoringDispatcher:self.monitoringDispatcher];
    
    OCMVerifyAll(instanceMock);
    
    [classMock stopMocking];
    [instanceMock stopMocking];
}
#pragma clang diagnostic pop

- (void)testinitWithAdMonitoringDispatcher {
    // 1) allouer sans init
    OGAMRAIDWebView *alloced = [OGAMRAIDWebView alloc];
    
    // 2) créer le partial mock sur l'objet alloué
    id partialMock = OCMPartialMock(alloced);
    
    // 3) définir l'attente AVANT d'appeler init (la méthode appelée dans init sera interceptée)
    OCMExpect([partialMock setupMKWebView]);
    
    // 4) appeler init (l'appel à setupMKWebView dans init sera capturé par le mock)
    OGAMRAIDWebView *newMraidWebView = [partialMock initWithAd:self.ad
                                                  stateManager:self.stateManager
                                          monitoringDispatcher:self.monitoringDispatcher];
    
    // vérifs habituelles
    XCTAssertNotNil(newMraidWebView);
    XCTAssertEqual(self.monitoringDispatcher, newMraidWebView.monitoringDispatcher);
    
    // 5) vérifier les attentes
    OCMVerifyAll(partialMock);
    
    // 6) cleanup du mock
    [partialMock stopMocking];
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
