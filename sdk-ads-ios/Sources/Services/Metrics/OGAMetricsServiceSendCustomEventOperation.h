//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Represents an operation that can be used to send a custom event (a fire-and-forget call to a URL).
@interface OGAMetricsServiceSendCustomEventOperation : NSOperation

#pragma mark - Initialization

- (instancetype)initWithEventURL:(NSString *)eventURL;

@end

NS_ASSUME_NONNULL_END
