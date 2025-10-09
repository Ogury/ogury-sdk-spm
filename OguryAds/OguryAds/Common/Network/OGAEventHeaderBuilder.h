//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OGAMetricEvent;

NS_ASSUME_NONNULL_BEGIN

@interface OGAEventHeaderBuilder : NSObject

#pragma mark - Methods

+ (NSDictionary<NSString *, NSString *> *)buildFor:(OGAMetricEvent *)event;

@end

NS_ASSUME_NONNULL_END
