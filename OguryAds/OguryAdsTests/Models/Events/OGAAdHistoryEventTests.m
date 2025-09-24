//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OGAAdHistoryEvent.h"
#import <OCMock/OCMock.h>
#import "OGAAd.h"

NSString *const OGAAdHistoryEventTestsCampaignId = @"campaign-id";
NSString *const OGAAdHistoryEventTestsAdvertId = @"advert-id";
NSString *const OGAAdHistoryEventTestsAdvertiserId = @"advertiser-id";
NSString *const OGAAdHistoryEventTestsAdUnitId = @"ad-unit-id";
NSString *const OGAAdHistoryEventTestsUrl = @"url";
NSString *const OGAAdHistoryEventTestsSource = @"source";
NSString *const OGAAdHistoryEventTestsPattern = @"pattern";
NSString *const OGAAdHistoryEventTestsInterceptUrl = @"intercept-url";

@interface OGAAdHistoryEventTests : XCTestCase

@property(nonatomic, strong) OGAAd *ad;

@end

@implementation OGAAdHistoryEventTests

- (void)setUp {
    self.ad = OCMClassMock([OGAAd class]);
}

- (void)testInitWithAd {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.campaignId = OGAAdHistoryEventTestsCampaignId;
    ad.identifier = OGAAdHistoryEventTestsAdvertId;
    ad.advertiserId = OGAAdHistoryEventTestsAdvertiserId;
    ad.adUnit = [[OGAAdUnit alloc] init];
    ad.adUnit.identifier = OGAAdHistoryEventTestsAdUnitId;
    ad.adHistoryUrl = @"www.ogury.co";
    OGAAdHistoryEvent *adHistoryEvent = [[OGAAdHistoryEvent alloc] initWithAd:ad
                                                                          url:OGAAdHistoryEventTestsUrl
                                                                       source:OGAAdHistoryEventTestsSource
                                                                      pattern:OGAAdHistoryEventTestsPattern
                                                                 interceptURL:OGAAdHistoryEventTestsInterceptUrl];
    XCTAssertEqualObjects(adHistoryEvent.trackURL.absoluteString, @"www.ogury.co");
}

- (void)testToDictionary {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.campaignId = OGAAdHistoryEventTestsCampaignId;
    ad.identifier = OGAAdHistoryEventTestsAdvertId;
    ad.advertiserId = OGAAdHistoryEventTestsAdvertiserId;
    ad.adUnit = [[OGAAdUnit alloc] init];
    ad.adUnit.identifier = OGAAdHistoryEventTestsAdUnitId;

    OGAAdHistoryEvent *adHistoryEvent = [[OGAAdHistoryEvent alloc] initWithAd:ad
                                                                          url:OGAAdHistoryEventTestsUrl
                                                                       source:OGAAdHistoryEventTestsSource
                                                                      pattern:OGAAdHistoryEventTestsPattern
                                                                 interceptURL:OGAAdHistoryEventTestsInterceptUrl];

    NSDictionary *dict = [adHistoryEvent toDictionary];

    XCTAssertEqualObjects(dict[@"campaign_id"], OGAAdHistoryEventTestsCampaignId);
    XCTAssertEqualObjects(dict[@"advert_id"], OGAAdHistoryEventTestsAdvertId);
    XCTAssertEqualObjects(dict[@"advertiser_id"], OGAAdHistoryEventTestsAdvertiserId);
    XCTAssertEqualObjects(dict[@"ad_unit_id"], OGAAdHistoryEventTestsAdUnitId);
    XCTAssertEqualObjects(dict[@"url"], OGAAdHistoryEventTestsUrl);
    XCTAssertEqualObjects(dict[@"source"], OGAAdHistoryEventTestsSource);
    XCTAssertEqualObjects(dict[@"tracker_pattern"], OGAAdHistoryEventTestsPattern);
    XCTAssertEqualObjects(dict[@"tracker_url"], OGAAdHistoryEventTestsInterceptUrl);
}

- (void)testWhenTrackingURLIsEmptyThenNSURLShouldNotBeCreated {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.campaignId = OGAAdHistoryEventTestsCampaignId;
    ad.identifier = OGAAdHistoryEventTestsAdvertId;
    ad.advertiserId = OGAAdHistoryEventTestsAdvertiserId;
    ad.adUnit = [[OGAAdUnit alloc] init];
    ad.adUnit.identifier = OGAAdHistoryEventTestsAdUnitId;
    ad.adHistoryUrl = @"";

    OGAAdHistoryEvent *adHistoryEvent = [[OGAAdHistoryEvent alloc] initWithAd:ad
                                                                          url:OGAAdHistoryEventTestsUrl
                                                                       source:OGAAdHistoryEventTestsSource
                                                                      pattern:OGAAdHistoryEventTestsPattern
                                                                 interceptURL:OGAAdHistoryEventTestsInterceptUrl];
    XCTAssertNil(adHistoryEvent.trackURL);
}

@end
