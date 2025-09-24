//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "OGAWKWebView.h"
#import "OGAMRAIDWebViewDelegate.h"
#import "OGAAdDisplayer.h"

@class OGAAd;
@class OGAMraidCommandsHandler;
@class OGAMraidCreateWebViewCommand;
@class OGAMraidCommand;
@class OGAJavascriptCommandExecutor;
@class OGAOMIDSession;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Constants

extern NSString *const OGANameMainWebView;
extern NSString *const OGANameBrowserWebView;
extern NSString *const OGANameBrowserLandingPageWebView;
extern NSString *const OGANameRecommendedLinksWebView;
extern NSString *const OGAMraidBaseWebViewBaseURL;
extern NSString *const OGAScriptMessageHandlerName;
extern NSString *const OGAFinishedEvent;

@interface OGAMraidBaseWebView : UIView

#pragma mark - Properties

@property(nonatomic, strong) OGAWKWebView *wkWebView;
@property(nonatomic, strong) OGAAd *ad;
@property(nonatomic, strong) NSDate *createdAt;
@property(nonatomic, weak) id<OGAAdDisplayer> displayer;
@property(nonatomic, strong) OGAMraidCommandsHandler *mraidCommandsHandler;
@property(nonatomic, weak) id<OGAMRAIDWebViewDelegate> webViewDelegate;
@property(nonatomic, strong) NSString *webViewId;
@property(nonatomic, strong) OGAMraidCreateWebViewCommand *createCommand;
@property(nonatomic, strong) OGAMraidCommand *createdCommand;
@property(nonatomic, strong) OGAJavascriptCommandExecutor *commandExecutor;
@property(nonatomic, strong, nullable) OGAOMIDSession *omidSession;
@property(nonatomic, assign) BOOL usesCustomCloseButton;
@property(nonatomic, assign) BOOL isCommunicatingWithMraid;
@property(nonatomic, assign) BOOL isWebviewClosed;

#pragma mark - Initialization

- (instancetype)initWithCommand:(OGAMraidCreateWebViewCommand *)command ad:(OGAAd *)ad;

- (instancetype)initWithAd:(OGAAd *)ad;

#pragma mark - Methods

- (void)setupWithCommand:(OGAMraidCreateWebViewCommand *)command;

- (void)setupConstraintsForWebView;

- (void)loadWithContent:(NSString *)content;

- (void)loadWithURL:(NSString *)url;

- (void)setupMKWebView;

- (void)startOMIDSessionOnShow;

- (void)loadWebViewWithCommandforBrowser:(OGAMraidCreateWebViewCommand *)command;

- (void)removeScriptMessageHandler;

@end

NS_ASSUME_NONNULL_END
