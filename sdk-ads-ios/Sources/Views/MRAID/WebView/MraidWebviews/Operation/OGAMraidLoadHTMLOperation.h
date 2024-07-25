//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAMraidBaseWebView.h"

NS_ASSUME_NONNULL_BEGIN

/// This operation will add the WKUserScript and perform the HTML load for the WKWebView contained in the OGAMraidBaseView.
@interface OGAMraidLoadHTMLOperation : NSOperation

- (instancetype)initWithBaseView:(OGAMraidBaseWebView *)baseView
                         content:(NSString *)content
                         baseURL:(NSURL *)baseURL
               environmentScript:(NSString *)environmentScript
                 executionScript:(NSString *)executionScript;

@end

NS_ASSUME_NONNULL_END
