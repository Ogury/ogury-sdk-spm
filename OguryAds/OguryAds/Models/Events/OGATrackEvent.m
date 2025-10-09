//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OGATrackEvent.h"
#import "OGAAdHistoryEvent.h"
#import "OGAPreCacheEvent.h"
#import "OGAConfigurationUtils.h"
#import "OGAAd.h"

@implementation OGATrackEvent

#pragma mark - Properties

@dynamic trackURL;

#pragma mark - Initialization

- (instancetype)initWithAd:(OGAAd *)ad event:(OGAMetricEventType)event {
    if (self = [super initWithAdvertId:ad.identifier adUnitId:ad.adUnit.identifier privacyConfiguration:ad.privacyConfiguration eventType:event]) {
        _campaignId = ad.campaignId;
        _advertiserId = ad.advertiserId;
        _advert = ad.identifier;
        _versionAppPublisher = [OGAConfigurationUtils getAppMarketingVersion];
        self.trackURL = ad.adTrackUrl.length > 0 ? [NSURL URLWithString:ad.adTrackUrl] : nil;
    }

    return self;
}

#pragma mark - Methods

+ (OGAJSONKeyMapper *)keyMapper {
    return [[OGAJSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"eventName" : @"event",
        @"campaignId" : @"campaign",
        @"advertiserId" : @"advertiser",
        @"advert" : @"advert",
        @"adUnitId" : @"ad_unit_id",
        @"versionAppPublisher" : @"version_app_publisher"
    }];
}

@end
