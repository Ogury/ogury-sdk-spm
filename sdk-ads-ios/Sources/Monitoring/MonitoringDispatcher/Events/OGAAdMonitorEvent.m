//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGAAdMonitorEvent.h"
#import "OGAMonitoringConstants.h"
#import "OGAMonitorEventConfigurationFactory.h"
#import "NSDate+OGAFormatter.h"
#import "OguryMediation.h"

@interface OGAAdMonitorEvent ()

@property(nonatomic, retain) NSString *adUnitId;
@property(nonatomic, retain, nullable) NSString *campaignId;
@property(nonatomic, retain, nullable) NSString *creativeId;
@property(nonatomic, assign) CGSize requestedSize;
@property(nonatomic, assign) CGSize creativeSize;
@property(nonatomic, retain, nullable) NSArray *extras;
@property(nonatomic, retain, nullable) OguryMediation *mediation;

@end

@interface OGMMonitorEvent ()
- (NSNumber *)getTimestampInMilliseconds;
@end

@implementation OGAAdMonitorEvent
@synthesize adConfiguration;
- (instancetype)initWithEventConfiguration:(OGAMonitorEventConfiguration *)eventConfiguration
                           adConfiguration:(OGAAdConfiguration *)adConfiguration
                           customSessionId:(NSString *_Nullable)sessionId
                         detailsDictionary:(NSDictionary *_Nullable)detailsDictionary
                              errorContent:(NSDictionary *_Nullable)errorContent {
    if (self = [super initEventWithTimestamp:[self getTimestampInMilliseconds]
                                   sessionId:sessionId ?: adConfiguration.monitoringDetails.sessionId
                                   eventCode:eventConfiguration.eventCode
                                   eventName:eventConfiguration.eventName
                                dispatchType:OGMDispatchTypeImmediate
                           detailsDictionary:detailsDictionary
                                   errorType:eventConfiguration.errorType
                                errorContent:errorContent]) {
        _adUnitId = adConfiguration.adUnitId;
        if (adConfiguration.adType == OguryAdsTypeBanner) {
            _requestedSize = adConfiguration.requestedSize;
            _creativeSize = adConfiguration.creativeSize;
        }
        _campaignId = eventConfiguration.permissionMask & OGAAdIdMaskCampaignId ? adConfiguration.campaignId : nil;
        _creativeId = eventConfiguration.permissionMask & OGAAdIdMaskCreativeId ? adConfiguration.creativeId : nil;
        _extras = eventConfiguration.permissionMask & OGAAdIdMaskExtras ? adConfiguration.extras : nil;
        _mediation = adConfiguration.monitoringDetails.mediation;
        self.adConfiguration = adConfiguration;
    }
    return self;
}

- (instancetype)initWithTimestamp:(NSNumber *)timestamp
                        sessionId:(NSString *)sessionId
                        eventCode:(NSString *)eventCode
                        eventName:(NSString *)eventName
                     dispatchType:(OGMDispatchType)dispatchType
                         adUnitId:(NSString *)adUnitId
                        mediation:(OguryMediation *)mediation
                       campaignId:(NSString *_Nullable)campaignId
                       creativeId:(NSString *_Nullable)creativeId
                           extras:(NSArray *_Nullable)extras
                detailsDictionary:(NSDictionary *_Nullable)detailsDictionary
                        errorType:(NSString *_Nullable)errorType
                     errorContent:(NSDictionary *)errorContent {
    if (self = [super initEventWithTimestamp:timestamp
                                   sessionId:sessionId
                                   eventCode:eventCode
                                   eventName:eventName
                                dispatchType:dispatchType
                           detailsDictionary:detailsDictionary
                                   errorType:errorType
                                errorContent:errorContent]) {
        self.adUnitId = adUnitId;
        self.campaignId = campaignId;
        self.creativeId = creativeId;
        self.extras = extras;
        self.mediation = mediation;
    }
    return self;
}

- (NSDictionary *)asDisctionary {
    NSMutableDictionary *body = [[super asDisctionary] mutableCopy];

    body[OGAAdMonitorEventBodyAdUnit] = [[NSMutableDictionary alloc] init];
    if (self.adUnitId) {
        body[OGAAdMonitorEventBodyAdUnit][OGAAdMonitorEventBodyAdUnitId] = self.adUnitId;
    }
    NSMutableDictionary *adIdsDictionary = [[NSMutableDictionary alloc] init];
    if (self.campaignId) {
        adIdsDictionary[OGAAdMonitorEventBodyAdCampaignId] = self.campaignId;
    }
    if (self.creativeId) {
        adIdsDictionary[OGAAdMonitorEventBodyAdCreativeId] = self.creativeId;
    }
    if (self.requestedSize.width > 0 && self.requestedSize.height > 0) {
        adIdsDictionary[OGAAdMonitorEventBodyAdBanner] = [[NSMutableDictionary alloc] init];
        adIdsDictionary[OGAAdMonitorEventBodyAdBanner][OGAAdMonitorEventBodyAdRequestedSize] = @{
            OGAAdMonitorEventBodyAdSizeWidth : @(self.requestedSize.width),
            OGAAdMonitorEventBodyAdSizeHeight : @(self.requestedSize.height)
        };
    }
    if (self.creativeSize.width > 0 && self.creativeSize.height > 0) {
        if (adIdsDictionary[OGAAdMonitorEventBodyAdBanner] == nil) {
            adIdsDictionary[OGAAdMonitorEventBodyAdBanner] = [[NSMutableDictionary alloc] init];
        }
        adIdsDictionary[OGAAdMonitorEventBodyAdBanner][OGAAdMonitorEventBodyAdCreativeSize] = @{
            OGAAdMonitorEventBodyAdSizeWidth : @(self.creativeSize.width),
            OGAAdMonitorEventBodyAdSizeHeight : @(self.creativeSize.height)
        };
    }
    if (self.extras) {
        adIdsDictionary[OGAAdMonitorEventBodyAdExtras] = self.extras;
    }
    if (adIdsDictionary.count > 0) {
        body[OGAAdMonitorEventBodyAd] = adIdsDictionary;
    }
    if (self.mediation) {
        body[OGAAdMonitorEventBodyMediation] = @{
            OGAAdMonitorEventBodyMediationName : self.mediation.name,
            OGAAdMonitorEventBodyMediationVersion : self.mediation.version
        };
    }
    return body;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [super encodeWithCoder:coder];
    if (self.adUnitId) {
        [coder encodeObject:self.adUnitId forKey:OGAAdMonitorEventBodyAdUnitId];
    }
    if (self.campaignId) {
        [coder encodeObject:self.campaignId forKey:OGAAdMonitorEventBodyAdCampaignId];
    }
    if (self.creativeId) {
        [coder encodeObject:self.creativeId forKey:OGAAdMonitorEventBodyAdCreativeId];
    }
    if (self.extras) {
        [coder encodeObject:self.extras forKey:OGAAdMonitorEventBodyAdExtras];
    }
    if (self.mediation) {
        [coder encodeObject:self.mediation forKey:OGAAdMonitorEventBodyMediation];
    }
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    NSNumber *timestamp = [coder decodeObjectForKey:OGAMonitorEventBodyTimestamp];
    NSString *sessionId = [coder decodeObjectForKey:OGAMonitorEventBodySessionId];
    NSString *eventCode = [coder decodeObjectForKey:OGAMonitorEventBodyEventCode];
    NSString *eventName = [coder decodeObjectForKey:OGAMonitorEventBodyEventName];
    NSString *adUnitId = [coder decodeObjectForKey:OGAAdMonitorEventBodyAdUnitId];
    NSString *campaignId = [coder decodeObjectForKey:OGAAdMonitorEventBodyAdCampaignId];
    NSString *creativeId = [coder decodeObjectForKey:OGAAdMonitorEventBodyAdCreativeId];
    NSArray *extras = [coder decodeObjectForKey:OGAAdMonitorEventBodyAdExtras];
    NSDictionary *details = [coder decodeObjectForKey:OGAMonitorEventBodyDetails];
    NSString *errorType = [coder decodeObjectForKey:OGAMonitorEventBodyErrorType];
    NSDictionary *errorContent = [coder decodeObjectForKey:OGAMonitorEventBodyErrorContent];
    OguryMediation *mediation = [coder decodeObjectForKey:OGAAdMonitorEventBodyMediation];

    return [self initWithTimestamp:timestamp
                         sessionId:sessionId
                         eventCode:eventCode
                         eventName:eventName
                      dispatchType:OGMDispatchTypeDeferred  // tracks are always deferred when they are not send immediately
                          adUnitId:adUnitId
                         mediation:mediation
                        campaignId:campaignId
                        creativeId:creativeId
                            extras:extras
                 detailsDictionary:details
                         errorType:errorType
                      errorContent:errorContent];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[OGAAdMonitorEvent class]] == NO) {
        return NO;
    }
    OGAAdMonitorEvent *event = (OGAAdMonitorEvent *)object;
    BOOL isEqual = [super isEqual:event];
    return isEqual && [self.adUnitId isEqual:event.adUnitId] && ((self.campaignId != nil || event.campaignId != nil) ? [self.campaignId isEqual:event.campaignId] : YES) && ((self.creativeId != nil || event.creativeId != nil) ? [self.creativeId isEqual:event.creativeId] : YES) && ((self.extras != nil || event.extras != nil) ? [self.extras isEqualToArray:event.extras] : YES) && ((self.mediation != nil || event.mediation != nil) ? [self.mediation isEqual:event.mediation] : YES);
}

- (NSNumber *)getTimestampInMilliseconds {
    return [NSDate timestampInMilliseconds];
}

@end
