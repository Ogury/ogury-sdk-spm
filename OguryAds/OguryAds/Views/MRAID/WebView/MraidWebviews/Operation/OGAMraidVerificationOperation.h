//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAMraidBaseWebView.h"

NS_ASSUME_NONNULL_BEGIN

/// This operation is responsible for checking that the evaluation of the MRAID JavaScript within the WKWebView contained in an OGAMraidBaseView has succeeded or not.
@interface OGAMraidVerificationOperation : NSOperation

- (instancetype)initWithBaseView:(OGAMraidBaseWebView *)baseView completionHandler:(void (^)(BOOL))completionHandler;

@end

NS_ASSUME_NONNULL_END
