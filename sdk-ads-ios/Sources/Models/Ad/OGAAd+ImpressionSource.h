//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGAAd.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAd (ImpressionSource)

- (BOOL)isImpressionSourceFormat;

- (BOOL)isImpressionSourceSDK;

- (NSString *)getRawImpressionSource;

@end

NS_ASSUME_NONNULL_END
