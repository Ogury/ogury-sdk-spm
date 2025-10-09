//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OGAPreCacheEvent.h"
#import "OGAAd.h"

#pragma mark - Constants

static NSString *const OGAMetricEventAdUnitIdKey = @"adUnitId";
static NSString *const OGAMetricEventTrackURLKey = @"trackURL";

@implementation OGAPreCacheEvent

#pragma mark - Initialization

- (instancetype)initWithAdvertId:(NSString *_Nullable)advertId adUnitId:(NSString *)adUnitId privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration eventType:(OGAMetricEventType)eventType {
    if (self = [super initWithAdvertId:advertId adUnitId:adUnitId privacyConfiguration:privacyConfiguration eventType:eventType]) {
        _timestampDiff = @"0";
    }
    return self;
}

#pragma mark - Methods

+ (OGAJSONKeyMapper *)keyMapper {
    return [[OGAJSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"eventName" : @"type",
        @"timestampDiff" : @"timestamp_diff"

    }];
}

+ (BOOL)propertyIsIgnored:(NSString *)propertyName {
    return [@[ OGAMetricEventAdUnitIdKey ] containsObject:propertyName] || [super propertyIsIgnored:propertyName];
}

@end
