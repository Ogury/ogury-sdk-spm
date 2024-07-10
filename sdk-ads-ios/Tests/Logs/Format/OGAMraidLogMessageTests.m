//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAMraidLogMessage.h"

@interface OGAMraidLogMessageTests : XCTestCase

@end

@implementation OGAMraidLogMessageTests

NSString *const OGAMraidLogMessageTestsAdUnit = @"OGAMraidLogMessageTestsAdUnit";
NSString *const OGAMraidLogMessageTestsWebViewId = @"OGAMraidLogMessageTestsWebViewId";
NSString *const OGAMraidLogMessageTestsLogMessage = @"testMessage";

- (void)testFormatString {
    id delegateDispatcher = OCMClassMock([OGADelegateDispatcher self]);

    OGAAdConfiguration *adConfiguration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial adUnitId:OGAMraidLogMessageTestsAdUnit delegateDispatcher:delegateDispatcher viewControllerProvider:nil viewProvider:nil];

    OGAMraidLogMessage *logMessage = [[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelError adConfiguration:adConfiguration webviewId:OGAMraidLogMessageTestsWebViewId message:OGAMraidLogMessageTestsLogMessage];

    NSString *expected = [NSString stringWithFormat:@"[%@][%@][%@][MRAID][%@] %@",
                                                    [adConfiguration getAdTypeString],
                                                    adConfiguration.adUnitId,
                                                    adConfiguration.campaignId ?: @"",
                                                    OGAMraidLogMessageTestsWebViewId,
                                                    OGAMraidLogMessageTestsLogMessage];
    XCTAssertTrue([logMessage.formattedString isEqualToString:expected]);
}

@end
