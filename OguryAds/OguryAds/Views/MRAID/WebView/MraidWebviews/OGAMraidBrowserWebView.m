//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGAMraidBrowserWebView.h"
#import "OGAMraidBaseWebView+PrivateHeader.h"
#import "OGAAd.h"
#import "OGAMraidCreateWebViewCommand.h"

static NSInteger const browserDefaultDelayForSendingLoaded = 1;

@implementation OGAMraidBrowserWebView

- (void)loadWebViewWithCommandforBrowser:(OGAMraidCreateWebViewCommand *)command {
    if (self.ad.adUnit) {
        [self startMRAIDProcessForContent:command.content];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSInteger delay = browserDefaultDelayForSendingLoaded;

    if (self.ad.delayForSendingLoaded != 0) {
        delay = self.ad.delayForSendingLoaded;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.webViewDelegate webViewReady:self.ad.localIdentifier];  // This is only for ad webview (request ad from server)

        if (self.ad.launchOmidSessionAtLoad) {
            [self startOMIDSession];
        }

        [self sendNavigationEvent:@"finished" webViewIdentifier:self.webViewId wkWebView:self.wkWebView pageTitle:self.wkWebView.title];

        [self webViewReady];
    });
}

@end
