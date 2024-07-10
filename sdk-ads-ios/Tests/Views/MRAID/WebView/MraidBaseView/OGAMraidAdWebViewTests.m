//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAMraidAdWebView.h"

@interface OGAMraidAdWebViewTests : XCTestCase

@end

@interface OGAMraidAdWebView ()
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView;
@end

@implementation OGAMraidAdWebViewTests

- (void)testWhenWebkitProcessTerminate_ThenDisplayerMEthodIsCalled {
    id<OGAAdDisplayer> displayer = OCMProtocolMock(@protocol(OGAAdDisplayer));
    OGAMraidAdWebView *element = [[OGAMraidAdWebView alloc] init];
    element.displayer = displayer;
    [element webViewWebContentProcessDidTerminate:[WKWebView new]];
    OCMVerify([displayer webkitProcessDidTerminate]);
}

@end
