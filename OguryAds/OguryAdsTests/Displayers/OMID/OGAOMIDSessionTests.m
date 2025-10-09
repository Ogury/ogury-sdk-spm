//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OMSDK_Ogury/OMIDSDK.h>
#import <OMSDK_Ogury/OMIDPartner.h>
#import <OMSDK_Ogury/OMIDAdSession.h>
#import "OGALog.h"
#import <OCMock/OCMock.h>
#import "OGAOMIDSession.h"

@interface OGAOMIDSession (Testing)

- (instancetype)initWithAdSession:(OMIDOguryAdSession *)adSession log:(OGALog *)log;

- (OMIDOguryPartner *)createOMIDPartner;

- (OMIDOguryAdSessionContext *)createOMIDSessionContext:(WKWebView *)webView;

- (OMIDOguryAdSessionConfiguration *)createOMIDSessionConfiguration;

- (OMIDOguryAdSession *)createOMIDSession:(WKWebView *)webView;

@end

@interface OGAOMIDSessionTests : XCTestCase

@property(nonatomic, strong) OMIDOguryAdSession *adSession;
@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAOMIDSession *omidSession;

@end

@implementation OGAOMIDSessionTests

- (void)setUp {
    self.webView = [[WKWebView alloc] init];
    self.adSession = OCMClassMock([OMIDOguryAdSession class]);
    self.log = OCMClassMock([OGALog class]);

    OGAOMIDSession *omidSession = [[OGAOMIDSession alloc] initWithAdSession:self.adSession log:self.log];
    self.omidSession = OCMPartialMock(omidSession);

    [[OMIDOgurySDK sharedInstance] activate];
}

#pragma mark - Methods

- (void)testStartOMIDSession {
    [self.omidSession startOMIDSession];

    OCMVerify([self.adSession start]);
}

- (void)testStopOMIDSession {
    [self.omidSession stopOMIDSession];

    OCMVerify([self.adSession finish]);
}

- (void)testCreateOMIDPartner {
    OMIDOguryPartner *partner = [self.omidSession createOMIDPartner];

    XCTAssertEqualObjects(partner.name, @"Ogury");
    XCTAssertEqualObjects(partner.versionString, OGA_SDK_VERSION);
}

- (void)testCreateOMIDSessionContext_failedToCreatePartner {
    OCMStub([self.omidSession createOMIDPartner]).andReturn(nil);

    XCTAssertNil([self.omidSession createOMIDSessionContext:self.webView]);
}

- (void)testCreateOMIDSessionContext_webViewHasBeenDeallocated {
    XCTAssertNil([self.omidSession createOMIDSessionContext:nil]);
}

- (void)testCreateOMIDSessionConfiguration {
    XCTAssertNotNil([self.omidSession createOMIDSessionConfiguration]);
}

- (void)testCreateOMIDSession_failedToCreateContext {
    OCMStub([self.omidSession createOMIDSessionContext:[OCMArg any]]).andReturn(nil);

    XCTAssertNil([self.omidSession createOMIDSession:self.webView]);
}

- (void)testCreateOMIDSession_failedToCreateConfiguration {
    OCMStub([self.omidSession createOMIDSessionConfiguration]).andReturn(nil);

    XCTAssertNil([self.omidSession createOMIDSession:self.webView]);
}

@end
