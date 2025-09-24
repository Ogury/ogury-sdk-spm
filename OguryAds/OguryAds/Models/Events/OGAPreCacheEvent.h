//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OGAMetricEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAPreCacheEvent : OGAMetricEvent

#pragma mark - Properties

@property(nonatomic, strong) NSString *timestampDiff;

#pragma mark - Initialization

- (instancetype)initWithAdvertId:(NSString *_Nullable)advertId adUnitId:(NSString *)adUnitId privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration eventType:(OGAMetricEventType)eventType;

@end

NS_ASSUME_NONNULL_END
