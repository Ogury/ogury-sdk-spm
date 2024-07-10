//
//  Copyright © 2019 Ogury Ltd. All rights reserved.
//

#import "OGAOMIDSession.h"
#import <OMSDK_Ogury/OMIDPartner.h>
#import <OMSDK_Ogury/OMIDAdSession.h>
#import "OGALog.h"

@interface OGAOMIDSession ()

@property(nonatomic, strong) OMIDOguryAdSession *adSession;
@property(nonatomic, strong) OGALog *log;

@end

NSString *const OGAOMIDSessionPartnerName = @"Ogury";

@implementation OGAOMIDSession

#pragma mark - Initialization

- (instancetype)initWithWebView:(WKWebView *)webView {
    return [self initWithAdSession:[self createOMIDSession:webView] log:[OGALog shared]];
}

- (instancetype)initWithAdSession:(OMIDOguryAdSession *)adSession log:(OGALog *)log {
    if (self = [super init]) {
        _adSession = adSession;
        _log = log;
    }

    return self;
}

#pragma mark - Public methods

- (void)startOMIDSession {
    [self.log log:OguryLogLevelDebug message:@"[OMID] starting session."];

    [self.adSession start];
}

- (void)stopOMIDSession {
    [self.log log:OguryLogLevelDebug message:@"[OMID] session finished."];

    [self.adSession finish];
}

#pragma mark - Private methods

- (OMIDOguryPartner *)createOMIDPartner {
    return [[OMIDOguryPartner alloc] initWithName:OGAOMIDSessionPartnerName versionString:OGA_SDK_VERSION];
}

- (OMIDOguryAdSessionContext *)createOMIDSessionContext:(WKWebView *)webView {
    if (!webView) {
        return nil;
    }

    OMIDOguryPartner *partner = [self createOMIDPartner];
    if (!partner) {
        return nil;
    }

    NSError *error;
    OMIDOguryAdSessionContext *sessionContext = [[OMIDOguryAdSessionContext alloc] initWithPartner:partner
                                                                                           webView:webView
                                                                                        contentUrl:nil
                                                                         customReferenceIdentifier:@""
                                                                                             error:&error];
    if (error) {
        [self.log logError:error message:@"[OMID] Failed to create OMID session context"];
    }
    return sessionContext;
}

- (OMIDOguryAdSessionConfiguration *)createOMIDSessionConfiguration {
    NSError *error;
    OMIDOguryAdSessionConfiguration *config = [[OMIDOguryAdSessionConfiguration alloc] initWithCreativeType:OMIDCreativeTypeDefinedByJavaScript
                                                                                             impressionType:OMIDImpressionTypeDefinedByJavaScript
                                                                                            impressionOwner:OMIDJavaScriptOwner
                                                                                           mediaEventsOwner:OMIDJavaScriptOwner
                                                                                 isolateVerificationScripts:NO
                                                                                                      error:&error];

    if (error) {
        [self.log logError:error message:@"[OMID] Failed to create OMID session configuration"];
    }
    return config;
}

- (OMIDOguryAdSession *)createOMIDSession:(WKWebView *)webView {
    OMIDOguryAdSessionContext *sessionContext = [self createOMIDSessionContext:webView];
    if (!sessionContext) {
        return nil;
    }

    OMIDOguryAdSessionConfiguration *configuration = [self createOMIDSessionConfiguration];
    if (!configuration) {
        return nil;
    }

    NSError *error;
    OMIDOguryAdSession *session = [[OMIDOguryAdSession alloc] initWithConfiguration:configuration
                                                                   adSessionContext:sessionContext
                                                                              error:&error];
    if (error) {
        [self.log logError:error message:@"[OMID] Failed to create OMID session"];
    }
    session.mainAdView = webView;
    return session;
}

@end
