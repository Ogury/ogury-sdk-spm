//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import "OGAMetricEvent.h"

@class OGAAd;

@interface OGAAdHistoryEvent : OGAMetricEvent

#pragma mark - Properties

@property(nonatomic, copy) NSString *campaignId;
@property(nonatomic, copy) NSString *advert;
@property(nonatomic, copy) NSString *advertiserId;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *source;
@property(nonatomic, copy) NSString<Optional> *pattern;
@property(nonatomic, copy) NSString<Optional> *interceptUrl;

#pragma mark - Initialization

- (instancetype)initWithAd:(OGAAd *)ad url:(NSString *)url source:(NSString *)source pattern:(NSString *)pattern interceptURL:(NSString *)interceptURL;

@end
