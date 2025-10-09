//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OMSDK_Ogury/OMIDSDK.h>
#import "OGALog.h"
#import <OCMock/OCMock.h>
#import "OGAOMIDService.h"

@interface OGAOMIDService (Testing)

- (instancetype)initWithOMIDSDK:(OMIDOgurySDK *)omidSDK log:(OGALog *)log;

@end

@interface OGAOMIDServiceTests : XCTestCase

@property(nonatomic, strong) OMIDOgurySDK *omidSDK;
@property(nonatomic, retain) OGALog *log;
@property(nonatomic, retain) OGAOMIDService *service;

@end

@implementation OGAOMIDServiceTests

- (void)setUp {
    self.omidSDK = OCMClassMock([OMIDOgurySDK class]);
    self.log = OCMClassMock([OGALog class]);
    OGAOMIDService *service = [[OGAOMIDService alloc] initWithOMIDSDK:self.omidSDK log:self.log];
    self.service = OCMPartialMock(service);
}

#pragma mark - Properties

- (void)testIsOMIDActive_omidIsActive {
    OCMStub(self.omidSDK.isActive).andReturn(YES);
    XCTAssertTrue(self.service.isOMIDActive);
}

- (void)testIsOMIDActive_omidIsNotActive {
    OCMStub(self.omidSDK.isActive).andReturn(NO);
    XCTAssertFalse(self.service.isOMIDActive);
}

- (void)testIsOMIDFrameworkPresent {
    XCTAssertTrue(self.service.isOMIDFrameworkPresent);
}

#pragma mark - Methods

- (void)testActivateOMID {
    [self.service activateOMID];

    OCMVerify([self.omidSDK activate]);
}

- (void)testCreateSessionForAd {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OGAMraidBaseWebView *webView = OCMClassMock([OGAMraidBaseWebView class]);
    OCMStub(ad.omidEnabled).andReturn(YES);
    OCMStub(self.service.isOMIDActive).andReturn(YES);
    OCMStub(webView.webViewId).andReturn(OGANameMainWebView);

    XCTAssertNotNil([self.service createSessionForAd:ad webView:webView]);
}

- (void)testCreateSessionForAd_omidIsNotActivated {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OGAMraidBaseWebView *webView = OCMClassMock([OGAMraidBaseWebView class]);
    OCMStub(self.service.isOMIDActive).andReturn(NO);

    XCTAssertNil([self.service createSessionForAd:ad webView:webView]);
}

- (void)testCreateSessionForAd_omidIsNotEnabledForAd {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OGAMraidBaseWebView *webView = OCMClassMock([OGAMraidBaseWebView class]);
    OCMStub(self.service.isOMIDActive).andReturn(YES);
    OCMStub(ad.omidEnabled).andReturn(NO);

    XCTAssertNil([self.service createSessionForAd:ad webView:webView]);
}

- (void)testCreateSessionForAd_webViewIsNotMain {
    OGAAd *ad = OCMClassMock([OGAAd class]);
    OGAMraidBaseWebView *webView = OCMClassMock([OGAMraidBaseWebView class]);
    OCMStub(self.service.isOMIDActive).andReturn(YES);
    OCMStub(ad.omidEnabled).andReturn(YES);
    OCMStub(webView.webViewId).andReturn(OGANameBrowserWebView);

    XCTAssertNil([self.service createSessionForAd:ad webView:webView]);
}

@end
