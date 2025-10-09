//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAMraidBaseWebView.h"

NS_ASSUME_NONNULL_BEGIN

/// This operation is responsible for starting the evaluation of the MRAID JavaScript within the WKWebView contained in an OGAMraidBaseView.
@interface OGAMraidInitializationOperation : NSOperation

- (instancetype)initWithBaseView:(OGAMraidBaseWebView *)baseView initializationScript:(NSString *)initializationScript;

@end

NS_ASSUME_NONNULL_END
