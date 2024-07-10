//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OGAAdLogMessage.h"

@interface OGAAdLogMessageTests : XCTestCase

@end

@implementation OGAAdLogMessageTests

NSString *const OGAAdLogMessageTestsAdUnit = @"OGAAdLogMessageTestsAdUnit";
NSString *const OGAAdLogMessageTestsLogMessage = @"testMessage";
NSString *const OGAAdLogMessageTestsCampaignId = @"testCampaignId";

- (void)testFormatString {
    id delegateDispatcher = OCMClassMock([OGADelegateDispatcher self]);

    OGAAdConfiguration *adConfiguration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial adUnitId:OGAAdLogMessageTestsAdUnit delegateDispatcher:delegateDispatcher viewControllerProvider:nil viewProvider:nil];
    adConfiguration.campaignId = OGAAdLogMessageTestsCampaignId;

    OGAAdLogMessage *logMessage = [[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError adConfiguration:adConfiguration message:OGAAdLogMessageTestsLogMessage];

    NSString *expected = [NSString stringWithFormat:@"[%@][%@][%@] %@",
                                                    [adConfiguration getAdTypeString],
                                                    adConfiguration.adUnitId,
                                                    adConfiguration.campaignId,
                                                    OGAAdLogMessageTestsLogMessage];
    XCTAssertTrue([logMessage.formattedString isEqualToString:expected]);
}

- (void)testFormatStringIfCampaignIdNil {
    id delegateDispatcher = OCMClassMock([OGADelegateDispatcher self]);

    OGAAdConfiguration *adConfiguration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeInterstitial adUnitId:OGAAdLogMessageTestsAdUnit delegateDispatcher:delegateDispatcher viewControllerProvider:nil viewProvider:nil];

    OGAAdLogMessage *logMessage = [[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelError adConfiguration:adConfiguration message:OGAAdLogMessageTestsLogMessage];

    NSString *expected = [NSString stringWithFormat:@"[%@][%@][] %@",
                                                    [adConfiguration getAdTypeString],
                                                    adConfiguration.adUnitId,
                                                    OGAAdLogMessageTestsLogMessage];
    XCTAssertTrue([logMessage.formattedString isEqualToString:expected]);
}
@end
