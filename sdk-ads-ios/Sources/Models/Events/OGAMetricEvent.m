//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OGAMetricEvent.h"

#pragma mark - Constants

static NSString *const OGAMetricEventTrackURLKey = @"trackURL";
static NSString *const OGAMetricEventPrivacyConfigurationProperty = @"privacyConfiguration";
static NSString *const OGAMetricEventPrivacyAdvertId = @"advertId";

@implementation OGAMetricEvent

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *)adUnitId privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration eventType:(OGAMetricEventType)eventType {
    return [self initWithAdvertId:nil adUnitId:adUnitId privacyConfiguration:privacyConfiguration eventType:eventType];
}

- (instancetype)initWithAdvertId:(NSString *_Nullable)advertId adUnitId:(NSString *)adUnitId privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration eventType:(OGAMetricEventType)eventType {
    if (self = [super init]) {
        _advertId = advertId;
        _adUnitId = adUnitId;
        _eventName = [OGAMetricEvent nameForEventType:eventType];
        _privacyConfiguration = privacyConfiguration;
    }
    return self;
}

#pragma mark - Methods

+ (NSString *)nameForEventType:(OGAMetricEventType)eventType {
    NSString *name = @"";

    switch (eventType) {
        case OGAMetricsEventLoad:
            name = @"LOAD";
            break;
        case OGAMetricsEventShow:
            name = @"SHOW";
            break;
        case OGAMetricsEventLoaded:
            name = @"loaded";
            break;
        case OGAMetricsEventShown:
            name = @"shown";
            break;
        case OGAMetricsEventExpired:
            name = @"expired";
            break;
        case OGAMetricsEventLoadedError:
            name = @"loaded_error";
            break;
        case OGAMetricsEventHistory:
            name = @"history";
            break;
    }

    return name;
}

+ (BOOL)propertyIsIgnored:(NSString *)propertyName {
    return [@[ OGAMetricEventTrackURLKey, OGAMetricEventPrivacyConfigurationProperty, OGAMetricEventPrivacyAdvertId ] containsObject:propertyName];
}

@end
