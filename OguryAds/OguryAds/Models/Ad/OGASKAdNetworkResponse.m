//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGASKAdNetworkResponse.h"

@implementation OGASKAdNetworkResponse

+ (OGAJSONKeyMapper *)keyMapper {
    return [[OGAJSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"campaignId" : @"campaign_id",
        @"sourceIdentifier" : @"source_identifier",
        @"itunesItemId" : @"itunes_item_id",
        @"nonce" : @"ad_impression_identifier",
        @"sourceAppId" : @"source_app_id",
        @"timestamps" : @"timestamp",
        @"version" : @"version",
        @"signature" : @"signature",
        @"fidelity" : @"fidelity_type",
        @"isStoreKitDisplay" : @"store_kit_display",
        @"networkIdentifier" : @"network_identifier"
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"sourceIdentifier"] || [propertyName isEqualToString:@"campaignId"]) {
        return true;
    }
    return false;
}

@end
