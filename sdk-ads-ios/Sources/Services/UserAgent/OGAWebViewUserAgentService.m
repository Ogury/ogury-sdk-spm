//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAWebViewUserAgentService.h"

#import <WebKit/WebKit.h>

@interface OGAWebViewUserAgentService () <WKNavigationDelegate>

@property(nonatomic, copy, readwrite, nullable) NSString *webViewUserAgent;
@property(nonatomic, strong) WKWebView *webViewForUserAgent;
@property(nonatomic) NSInteger webviewUserAgentRetry;
@property(atomic) BOOL delegateFired;

@end

@implementation OGAWebViewUserAgentService

NSString *const OGAJavascriptGetUserAgent = @"navigator.userAgent";
NSString *const OGAEmptyURL = @"about:blank";
NSInteger const OGAMaxRetry = 10;

#pragma mark - Methods

+ (instancetype)shared {
    static OGAWebViewUserAgentService *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _webViewForUserAgent = nil;
        _webviewUserAgentRetry = 0;
        _delegateFired = NO;
    }
    return self;
}

- (void)syncWebViewUserAgentAndDispatchDelegate {
    [self syncWebViewUserAgentAndDispatchDelegate:YES];
}

- (void)syncWebViewUserAgent {
    [self syncWebViewUserAgentAndDispatchDelegate:NO];
}

- (void)syncWebViewUserAgentAndDispatchDelegate:(BOOL)alwaysSendDelegate {
    if (!self.webViewUserAgent || self.webViewUserAgent.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.webViewForUserAgent = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            self.webViewForUserAgent.navigationDelegate = self;
            [self.webViewForUserAgent loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:OGAEmptyURL]]];
        });
        // when the SDK is reseted and a new assetKey is set
    } else if (self.webViewUserAgent.length > 0 && (!self.delegateFired || alwaysSendDelegate)) {
        [self.delegate receivedWebViewUserAgent:self.webViewUserAgent];
        self.delegateFired = YES;
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    dispatch_async(dispatch_get_main_queue(), ^{
        [webView evaluateJavaScript:OGAJavascriptGetUserAgent
                  completionHandler:^(id _Nullable result, NSError *_Nullable error) {
                      if (!error && result) {
                          self.webViewUserAgent = result;
                          if (!self.delegateFired && self.delegate) {
                              [self.delegate receivedWebViewUserAgent:result];
                              self.delegateFired = YES;
                          }
                      } else {
                          self.webViewForUserAgent = nil;
                          if (self.webviewUserAgentRetry < OGAMaxRetry) {
                              self.webviewUserAgentRetry++;
                              [self syncWebViewUserAgent];
                          } else {
                              if (!self.delegateFired && self.delegate) {
                                  [self.delegate maxWebViewUserAgentRetryReached];
                                  self.delegateFired = YES;
                              }
                          }
                      }
                  }];
    });
}

- (void)reset {
    self.delegateFired = NO;
}

@end
