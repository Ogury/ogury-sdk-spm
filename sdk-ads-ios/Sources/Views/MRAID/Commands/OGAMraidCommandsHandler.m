//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGAMraidCommand.h"
#import "OGAAd.h"
#import "OGALog.h"
#import "OGAAdConfiguration.h"
#import "OGAMraidCommandsHandler.h"
#import "OGAMraidCreateWebViewCommand.h"
#import "OGAJavascriptCommandExecutor.h"
#import "OGAMRAIDWebView.h"
#import "OGAAdExposure.h"
#import "OGAMraidLogMessage.h"
#import "OGAAdDisplayerUpdateStateInformation.h"

#pragma mark - Constants

static NSString *const OGACreateWebViewMRAIDCommand = @"ogyCreateWebView";
static NSString *const OGAUseCustomCloseMRAIDCommand = @"useCustomClose";
static NSString *const OGAAdEventMRAIDCommand = @"ogyOnAdEvent";
static NSString *const OGACloseMRAIDCommand = @"close";
static NSString *const OGAUnloadMRAIDCommand = @"unload";
static NSString *const OGAOpenMRAIDCommand = @"open";
static NSString *const OGACloseWebViewMRAIDCommand = @"ogyCloseWebView";
static NSString *const OGANavigateBackMRAIDCommand = @"ogyNavigateBack";
static NSString *const OGANavigateForwardMRAIDCommand = @"ogyNavigateForward";
static NSString *const OGAUpdateWebViewMRAIDCommand = @"ogyUpdateWebView";
static NSString *const OGABunaZiuaMRAIDCommand = @"bunaZiua";
static NSString *const OGASetResizePropsMRAIDCommand = @"setResizeProperties";
static NSString *const OGASetOrientationPropertiesMRAIDCommand = @"setOrientationProperties";
static NSString *const OGAForceCloseMRAIDCommand = @"ogyForceClose";
static NSString *const OGAOnAdClickedMRAIDCommand = @"ogyOnAdClicked";
static NSString *const OGAExpandMRAIDCommand = @"expand";
static NSString *const OGAWebViewIdentifier = @"webViewId";
static NSString *const OGAAdEventKey = @"event";
static NSString *const OGAAdEventRewardValue = @"rewards";
static NSString *const OGAOpenURLKey = @"url";
static NSString *const OGAOgyOnAdImpression = @"ogyOnAdImpression";
static NSString *const OGAOgyOnAdLoaded = @"ogyOnAdLoaded";
static NSString *const OGAOpenStoreKit = @"ogyOpenStoreKit";
static NSString *const OGAEulaAccepted = @"eulaAccepted";
static NSString *const OGAEulaRejected = @"eulaRejected";
static NSString *const OGAOpenSKOverlay = @"ogyOpenSKOverlay";
static NSString *const OGACloseSKOverlay = @"ogyCloseSKOverlay";
static NSString *const OGATimeout = @"timeout";

static NSArray<NSString *> *commandsToHandleImmedialtely;

@interface OGAMraidCommandsHandler ()

@property(nonatomic, strong) UIApplication *application;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) NSMutableArray<OGAMraidCommand *> *commandsToSend;

@end

@implementation OGAMraidCommandsHandler

#pragma mark - Initialization

- (instancetype)initWithDelegate:(id<OGAMraidCommandsHandlerDelegate>)delegate mraidWebView:(OGAMraidBaseWebView *)mraidWebView {
    return [self initWithDelegate:delegate mraidWebView:mraidWebView application:UIApplication.sharedApplication log:[OGALog shared]];
}

- (instancetype)initWithDelegate:(id<OGAMraidCommandsHandlerDelegate>)delegate
                    mraidWebView:(OGAMraidBaseWebView *)mraidWebView
                     application:(UIApplication *)application
                             log:(OGALog *)log {
    if (self = [super init]) {
        _delegate = delegate;
        _mraidWebView = mraidWebView;
        _commandExecutor = [[OGAJavascriptCommandExecutor alloc] initWithWebView:self.mraidWebView];
        _application = application;
        _log = log;
        _commandsToSend = [@[] mutableCopy];
        commandsToHandleImmedialtely = @[ OGABunaZiuaMRAIDCommand, OGAUnloadMRAIDCommand, OGAForceCloseMRAIDCommand, OGACloseMRAIDCommand ];
    }

    return self;
}

#pragma mark - Methods

- (void)handleMraidCommand:(OGAMraidCommand *)command {
    if ([self.delegate mraidCommunicationIsUp] == NO && [commandsToHandleImmedialtely containsObject:command.method] == NO) {
        [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                adConfiguration:self.mraidWebView.ad.adConfiguration
                                                      webviewId:self.mraidWebView.webViewId
                                                        message:@"Storing mraid command"
                                                           tags:@[ [OguryLogTag tagWithKey:@"Command" value:command.method] ]]];

        [self.commandsToSend addObject:command];
        return;
    }

    [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                            adConfiguration:self.mraidWebView.ad.adConfiguration
                                                  webviewId:self.mraidWebView.webViewId
                                                    message:@"Handling mraid command"
                                                       tags:@[ [OguryLogTag tagWithKey:@"Command" value:command.method] ]]];

    OGAMraidCreateWebViewCommand *browserCommand = [[OGAMraidCreateWebViewCommand alloc] initWithDictionary:command.args error:nil];

    if (command.callbackId) {
        [self.commandExecutor callPendingMethodCallBackWithCallBackId:command.callbackId webViewId:browserCommand.webViewId];
    }

    [self.commandExecutor callCommandComplete];

    if ([command.method isEqualToString:OGACreateWebViewMRAIDCommand]) {
        [self.delegate createWebView:command];
    } else if ([command.method isEqualToString:OGAUseCustomCloseMRAIDCommand]) {
        [self useCustomClose:command];
    } else if ([command.method isEqualToString:OGAUnloadMRAIDCommand]) {
        [self unloadAd:command];
    } else if ([command.method isEqualToString:OGACloseMRAIDCommand]) {
        [self closeAd:command];
    } else if ([command.method isEqualToString:OGAAdEventMRAIDCommand]) {
        [self adEvent:command];
    } else if ([command.method isEqualToString:OGAOpenMRAIDCommand]) {
        [self openURL:command];
    } else if ([command.method isEqualToString:OGACloseWebViewMRAIDCommand]) {
        [self.delegate closeWebView:command];
    } else if ([command.method isEqualToString:OGANavigateBackMRAIDCommand]) {
        [self.delegate executeBackActionForWebViewId:command.args[OGAWebViewIdentifier]];
    } else if ([command.method isEqualToString:OGANavigateForwardMRAIDCommand]) {
        [self.delegate executeForwardActionForWebViewId:command.args[OGAWebViewIdentifier]];
    } else if ([command.method isEqualToString:OGABunaZiuaMRAIDCommand]) {
        [self bunaZiua:command];
    } else if ([command.method isEqualToString:OGAUpdateWebViewMRAIDCommand]) {
        [self.delegate updateWebView:command];
    } else if ([command.method isEqualToString:OGASetResizePropsMRAIDCommand]) {
        [self.delegate resizeProps:command];
    } else if ([command.method isEqualToString:OGAForceCloseMRAIDCommand]) {
        [self.delegate forceClose:command];
    } else if ([command.method isEqualToString:OGAExpandMRAIDCommand]) {
        [self.delegate expand];
    } else if ([command.method isEqualToString:OGAOnAdClickedMRAIDCommand]) {
        [self.delegate adClicked];
    } else if ([command.method isEqualToString:OGAOgyOnAdImpression]) {
        [self.delegate adImpressionFormat];
    } else if ([command.method isEqualToString:OGAOgyOnAdLoaded]) {
        [self.delegate formatDidLoadAd];
    } else if ([command.method isEqualToString:OGASetOrientationPropertiesMRAIDCommand]) {
        [self.delegate setOrientationProperties:command];
    } else if ([command.method isEqualToString:OGAOpenStoreKit]) {
        [self.delegate openStoreKit:command];
    } else if ([command.method isEqualToString:OGAOpenSKOverlay]) {
        [self.delegate openSKOverlay:command];
    } else if ([command.method isEqualToString:OGACloseSKOverlay]) {
        [self.delegate closeSKOverlay:command];
    }
}

- (void)bunaZiua:(OGAMraidCommand *)command {
    if (![self.mraidWebView.webViewId isEqualToString:@"Main"]) {
        self.mraidWebView.isCommunicatingWithMraid = YES;
    } else {
        [self.delegate bunaZiua];
    }
    [self handleUnsentCommands];
}

- (void)handleUnsentCommands {
    if ([self.delegate mraidCommunicationIsUp] && self.commandsToSend.count > 0) {
        // use of a dispatch group to clean the commandToSend Array after all commands are handled
        dispatch_group_t cleanGroup = dispatch_group_create();
        for (int index = 0; index < self.commandsToSend.count; index++) {
            dispatch_group_enter(cleanGroup);
            OGAMraidCommand *command = [self.commandsToSend objectAtIndex:index];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(index * 0.005 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self handleMraidCommand:command];
                dispatch_group_leave(cleanGroup);
            });
        }
        dispatch_group_notify(cleanGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self.commandsToSend removeAllObjects];
        });
    }
}

#pragma mark - Private methods
- (void)useCustomClose:(OGAMraidCommand *)command {
    BOOL useCustomButton = [command.args[OGAUseCustomCloseMRAIDCommand] boolValue];

    self.mraidWebView.usesCustomCloseButton = useCustomButton;

    [self.delegate setUseCustomCloseButton:useCustomButton];
}

- (void)closeAd:(OGAMraidCommand *)command {
    // If you are in the Ogury Browser you must force close to avoid collapse collapsible format
    if ([self.mraidWebView.webViewId isEqualToString:@"browser"] || [self.mraidWebView.webViewId isEqualToString:@"browser-recommended-links"]) {
        [self.delegate forceClose:command];
        return;
    }
    if (self.delegate) {
        [self.delegate closeFullAd:command];
    } else {
        [self sendWebviewIsNotReady];
    }
}

- (void)unloadAd:(OGAMraidCommand *)command {
    // If you are in the Ogury Browser you must force close to avoid collapse collapsible format
    if ([self.mraidWebView.webViewId isEqualToString:@"browser"] || [self.mraidWebView.webViewId isEqualToString:@"browser-recommended-links"]) {
        [self.delegate forceClose:command];
        return;
    }
    UnloadOrigin unloadOrigin = command.args[OGATimeout] ? UnloadOriginTimeout : UnloadOriginFormat;
    if (self.delegate) {
        [self.delegate unloadAd:command origin:unloadOrigin];
    } else {
        [self sendWebviewIsNotReady];
    }
}

- (void)sendWebviewIsNotReady {
    if ([self.mraidWebView.displayer.stateManager.webViewDelegate respondsToSelector:@selector(webViewNotReady:)]) {
        [self.mraidWebView.displayer.stateManager.webViewDelegate webViewNotReady:self.mraidWebView.ad.localIdentifier];
    }

    self.mraidWebView.usesCustomCloseButton = NO;
}

- (void)adEvent:(OGAMraidCommand *)command {
    if ([command.args[OGAAdEventKey] isEqualToString:OGAAdEventRewardValue]) {
        [self.delegate rewardWasReceived];
    } else if ([command.args[OGAAdEventKey] isEqualToString:OGAEulaAccepted]) {
        [self.delegate eulaConsentStatus:YES];
    } else if ([command.args[OGAAdEventKey] isEqualToString:OGAEulaRejected]) {
        [self.delegate eulaConsentStatus:NO];
    }
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (void)openURL:(OGAMraidCommand *)command {
    NSString *customURL = command.args[OGAOpenURLKey];

    if (!customURL) {
        return;
    }

    NSURL *url = [NSURL URLWithString:customURL];

    if (url && [self.application canOpenURL:url]) {
        [self.delegate openUrl:url];
        [self.application openURL:url
                          options:@{}
                completionHandler:^(BOOL success) {
                    [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                            adConfiguration:self.mraidWebView.ad.adConfiguration
                                                                  webviewId:self.mraidWebView.webViewId
                                                                    message:@"openURL"
                                                                       tags:@[
                                                                           [OguryLogTag tagWithKey:@"URL" value:customURL],
                                                                           [OguryLogTag tagWithKey:@"Success" value:@(success)]
                                                                       ]]];
                }];
    } else {
        [self.log log:[[OGAMraidLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                                adConfiguration:self.mraidWebView.ad.adConfiguration
                                                      webviewId:self.mraidWebView.webViewId
                                                        message:@"openURL failed"
                                                           tags:@[
                                                               [OguryLogTag tagWithKey:@"URL" value:customURL]
                                                           ]]];
    }
}

#pragma GCC diagnostic pop

#pragma mark - Utils

- (void)sendLoadCommands {
    [self.commandExecutor evaluateJS:[[[OGAAdDisplayerUpdateStateInformation alloc]
                                         initWithMraidState:OGAMRAIDStateLoading]
                                         toJavascriptCommand]];

    if (self.mraidWebView.ad.adConfiguration.adType == OguryAdsTypeThumbnailAd ||
        self.mraidWebView.ad.adConfiguration.adType == OguryAdsTypeBanner) {
        [self.commandExecutor sendLoadMraidCommandsWithFrame:self.mraidWebView.frame];
    } else {
        [self.commandExecutor sendLoadMraidCommandsWithFrame:CGRectZero];
    }

    if (![self.mraidWebView.webViewId isEqualToString:OGANameMainWebView]) {
        [self.commandExecutor sendShowMraidCommandsWithExposure:[OGAAdExposure fullExposure]];
    }
}

@end
