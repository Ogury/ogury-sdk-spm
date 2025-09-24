//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OGAMetricEvent.h"
#import "OGAMetricEventType.h"

@class OGAAd;

@interface OGATrackEvent : OGAMetricEvent

#pragma mark - Properties

@property(nonatomic, copy) NSString *campaignId;
@property(nonatomic, copy) NSString *advert;
@property(nonatomic, copy) NSString *advertiserId;
@property(nonatomic, copy) NSString *versionAppPublisher;

#pragma mark - Initialization

- (instancetype)initWithAd:(OGAAd *)ad event:(OGAMetricEventType)event;

@end
