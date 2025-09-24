//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAMraidAdWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAWebViewCleanupManager : NSObject
+ (instancetype)shared;

- (void)cleanUpObject:(OGAMraidAdWebView *)object;
@end

NS_ASSUME_NONNULL_END
