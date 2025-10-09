//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAMraidAdWebView.h"
#import "OGAOMIDService.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAMraidAdWebView (Testing)

@property(nonatomic, strong) OGAOMIDService *omidService;

#pragma mark - Methods

- (void)sendNavigationEvent:(NSString *)event webViewIdentifier:(NSString *)webViewIdentifier wkWebView:(WKWebView *)wkWebView;

- (void)sendNavigationEvent:(NSString *)event webViewIdentifier:(NSString *)webViewIdentifier wkWebView:(WKWebView *)wkWebView pageTitle:(NSString *_Nullable)pageTitle;

+ (NSString *)jsonParametersForNavigationEvent:(NSString *)event webViewIdentifier:(NSString *)webViewIdentifier webView:(WKWebView *)webView pageTitle:(NSString *_Nullable)pageTitle;
- (void)startOMIDSession;
- (void)webViewReady;
@end

NS_ASSUME_NONNULL_END
