//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAMraidLoadHTMLOperation.h"
#import "OGALog.h"
#import "OGAAd.h"
#import "OGAMraidLogMessage.h"
#import "OGAMraidCommandsHandler.h"

static int const delayBeforeSendingLoadCommands = 1;

@interface OGAMraidLoadHTMLOperation ()

@property(nonatomic, weak) OGAMraidBaseWebView *baseView;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, strong) NSURL *baseURL;
@property(nonatomic, copy) NSString *environmentScript;
@property(nonatomic, copy) NSString *executionScript;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAMraidLoadHTMLOperation

- (instancetype)initWithBaseView:(OGAMraidBaseWebView *)baseView
                         content:(NSString *)content
                         baseURL:(NSURL *)baseURL
               environmentScript:(NSString *)environmentScript
                 executionScript:(NSString *)executionScript
                             log:(OGALog *)log {
    if (self = [super init]) {
        _baseView = baseView;
        _content = content;
        _baseURL = baseURL;
        _environmentScript = environmentScript;
        _executionScript = executionScript;
        _log = log;
    }

    return self;
}

- (instancetype)initWithBaseView:(OGAMraidBaseWebView *)baseView
                         content:(NSString *)content
                         baseURL:(NSURL *)baseURL
               environmentScript:(NSString *)environmentScript
                 executionScript:(NSString *)executionScript {
    return [self initWithBaseView:baseView content:content baseURL:baseURL environmentScript:environmentScript executionScript:executionScript log:[OGALog shared]];
}

- (void)main {
    if (self.isCancelled) {
        return;
    }

    if (self.baseView.isCommunicatingWithMraid) {
        NSString *html = self.content;

        dispatch_sync(dispatch_get_main_queue(), ^{
            WKUserContentController *userContentController = self.baseView.wkWebView.configuration.userContentController;

            // Inject the MRAID environment variables way ahead of the HTML content and other JS resources. Required for opening external browser
            [userContentController addUserScript:[[WKUserScript alloc] initWithSource:self.environmentScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO]];

            // Inject the MRAID script after the document has been loaded, this way it has all the necessary resources to start the MRAID session
            [userContentController addUserScript:[[WKUserScript alloc] initWithSource:self.executionScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES]];

            [self.baseView.wkWebView loadHTMLString:html baseURL:self.baseURL];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayBeforeSendingLoadCommands * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                // Once everything has been loaded and the content has been given enought time to be processed, send all the MRAID commands required to start the workflow
                [self.baseView.mraidCommandsHandler sendLoadCommands];
            });
        });
    } else {
        [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelError
                                                adConfiguration:self.baseView.ad.adConfiguration
                                                      webviewId:self.baseView.webViewId
                                                        message:@"MRAID has not been initialized for webview"
                                                           tags:nil]];
    }
}

@end
