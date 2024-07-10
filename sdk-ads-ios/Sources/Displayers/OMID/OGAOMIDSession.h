//
//  Copyright © 2019 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAOMIDSession : NSObject

#pragma mark - Initialization

- (instancetype)initWithWebView:(WKWebView *)webView;

#pragma mark - Methods

- (void)startOMIDSession;

- (void)stopOMIDSession;

@end

NS_ASSUME_NONNULL_END
