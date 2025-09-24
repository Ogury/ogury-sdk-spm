//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OGATrackEvent.h"
#import "OGAAd.h"
#import <OCMock/OCMock.h>

NSString *const OGATrackEventTestsCampaignId = @"campaign-id";
NSString *const OGATrackEventTestsAdvertId = @"advert-id";
NSString *const OGATrackEventTestsAdvertiserId = @"advertiser-id";
NSString *const OGATrackEventTestsAdUnitId = @"ad-unit-id";

@interface OGATrackEventTests : XCTestCase

@property(nonatomic, strong) OGAAd *ad;

@end

@implementation OGATrackEventTests

- (void)setUp {
    self.ad = OCMClassMock([OGAAd class]);
}

- (void)testInitWithAd {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.campaignId = OGATrackEventTestsCampaignId;
    ad.identifier = OGATrackEventTestsAdvertId;
    ad.advertiserId = OGATrackEventTestsAdvertiserId;
    ad.adUnit = [[OGAAdUnit alloc] init];
    ad.adUnit.identifier = OGATrackEventTestsAdUnitId;
    ad.adTrackUrl = @"www.ogury.co";
    OGATrackEvent *trackEvent = [[OGATrackEvent alloc] initWithAd:ad event:OGAMetricsEventShow];
    XCTAssertEqualObjects(trackEvent.trackURL.absoluteString, @"www.ogury.co");
}

- (void)testToDictionary {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.campaignId = OGATrackEventTestsCampaignId;
    ad.identifier = OGATrackEventTestsAdvertId;
    ad.advertiserId = OGATrackEventTestsAdvertiserId;
    ad.adUnit = [[OGAAdUnit alloc] init];
    ad.adUnit.identifier = OGATrackEventTestsAdUnitId;

    OGATrackEvent *trackEvent = [[OGATrackEvent alloc] initWithAd:ad event:OGAMetricsEventShow];

    NSDictionary *dict = [trackEvent toDictionary];

    XCTAssertEqualObjects(dict[@"event"], @"SHOW");
    XCTAssertEqualObjects(dict[@"campaign"], OGATrackEventTestsCampaignId);
    XCTAssertEqualObjects(dict[@"advert"], OGATrackEventTestsAdvertId);
    XCTAssertEqualObjects(dict[@"advertiser"], OGATrackEventTestsAdvertiserId);
    XCTAssertEqualObjects(dict[@"ad_unit_id"], OGATrackEventTestsAdUnitId);
}

- (void)testWhenTrackingURLIsEmptyThenNSURLShouldNotBeCreated {
    OGAAd *ad = [[OGAAd alloc] init];
    ad.campaignId = OGATrackEventTestsCampaignId;
    ad.identifier = OGATrackEventTestsAdvertId;
    ad.advertiserId = OGATrackEventTestsAdvertiserId;
    ad.adUnit = [[OGAAdUnit alloc] init];
    ad.adUnit.identifier = OGATrackEventTestsAdUnitId;
    ad.adTrackUrl = @"";
    OGATrackEvent *trackEvent = [[OGATrackEvent alloc] initWithAd:ad event:OGAMetricsEventShow];
    XCTAssertNil(trackEvent.trackURL);
}

@end
