//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OGAAdHistoryEvent.h"
#import "OGAAd.h"

@implementation OGAAdHistoryEvent

#pragma mark - Initialization

- (instancetype)initWithAd:(OGAAd *)ad url:(NSString *)url source:(NSString *)source pattern:(NSString *)pattern interceptURL:(NSString *)interceptURL {
    if (self = [super initWithAdvertId:ad.identifier adUnitId:ad.adUnit.identifier privacyConfiguration:ad.privacyConfiguration eventType:OGAMetricsEventHistory]) {
        _campaignId = ad.campaignId;
        _advert = ad.identifier;
        _advertiserId = ad.advertiserId;
        _url = url;
        _source = source;
        _pattern = pattern;
        _interceptUrl = interceptURL;

        self.trackURL = ad.adHistoryUrl.length > 0 ? [NSURL URLWithString:ad.adHistoryUrl] : nil;
    }

    return self;
}

#pragma mark - Methods

+ (OGAJSONKeyMapper *)keyMapper {
    return [[OGAJSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"campaignId" : @"campaign_id",
        @"advert" : @"advert_id",
        @"advertiserId" : @"advertiser_id",
        @"adUnitId" : @"ad_unit_id",
        @"url" : @"url",
        @"source" : @"source",
        @"pattern" : @"tracker_pattern",
        @"interceptUrl" : @"tracker_url"
    }];
}

@end
