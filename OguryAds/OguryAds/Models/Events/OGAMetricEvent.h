//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAMetricEventType.h"
#import "OGAJSONModel.h"

@class OGAAdPrivacyConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface OGAMetricEvent : OGAJSONModel

#pragma mark - Properties

@property(nonatomic, copy, nullable) NSString *advertId;
@property(nonatomic, copy) NSString *adUnitId;
@property(nonatomic, copy) NSString *eventName;
@property(nonatomic, strong) OGAAdPrivacyConfiguration *privacyConfiguration;
@property(nonatomic, strong, nullable) NSURL *trackURL;
#pragma mark - Initialization

- (instancetype)initWithAdvertId:(NSString *_Nullable)advertId adUnitId:(NSString *)adUnitId privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration eventType:(OGAMetricEventType)eventType;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration eventType:(OGAMetricEventType)eventType;

@end

NS_ASSUME_NONNULL_END
