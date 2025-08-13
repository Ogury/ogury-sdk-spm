//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import "OGAInternal.h"
#import "OGAAdManager.h"
#import "OGAAssetKeyManager.h"
#import "OGAEnvironmentManager.h"
#import "OGALog.h"
#import "OGAProfigManager.h"
#import "OGAReachability.h"
#import "OGASetLogLevelNotificationManager.h"
#import "OGAWebViewUserAgentService.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAWebViewUserAgentServiceDelegate.h"

@interface OGAInternal () <OGAWebViewUserAgentServiceDelegate>

@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, strong) OGAProfigManager *profigManager;
@property(nonatomic, strong) OGAWebViewUserAgentService *webViewUserAgentService;
@property(nonatomic, strong) OGAEnvironmentManager *environmentManager;
@property(nonatomic, strong) OGAReachability *internetReachability;
@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGASetLogLevelNotificationManager *logNotificationManager;
@property(nonatomic, copy) StartCompletionBlock setupBlock;

@end

@interface OGAAssetKeyManager ()
- (void)sdkIsReady;
- (void)sdkStartFailed;
@end

@implementation OGAInternal

#pragma mark - Class methods

+ (instancetype)shared {
    static OGAInternal *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[OGAInternal alloc] init];
    });
    return instance;
}

#pragma mark - Initilization

- (instancetype)init {
    return [self initWithAssetKeyManager:[OGAAssetKeyManager shared]
                           profigManager:[OGAProfigManager shared]
                      environmentManager:[OGAEnvironmentManager shared]
                    internetReachability:[OGAReachability reachabilityForInternetConnection]
                               adManager:[OGAAdManager sharedManager]
                                     log:[OGALog shared]
                  logNotificationManager:[[OGASetLogLevelNotificationManager alloc] init]
                 webViewUserAgentService:[OGAWebViewUserAgentService shared]];
}

- (instancetype)initWithAssetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                          profigManager:(OGAProfigManager *)profigManager
                     environmentManager:(OGAEnvironmentManager *)environmentManager
                   internetReachability:(OGAReachability *)internetReachability
                              adManager:(OGAAdManager *)adManager
                                    log:(OGALog *)log
                 logNotificationManager:(OGASetLogLevelNotificationManager *)logNotificationManager
                webViewUserAgentService:(OGAWebViewUserAgentService *)webViewUserAgentService {
    if (self = [super init]) {
        _assetKeyManager = assetKeyManager;
        _profigManager = profigManager;
        _environmentManager = environmentManager;
        _internetReachability = internetReachability;
        _adManager = adManager;
        _log = log;
        _logNotificationManager = logNotificationManager;
        _webViewUserAgentService = webViewUserAgentService;
        _webViewUserAgentService.delegate = self;
        _sdkConsumer = nil;
        [_logNotificationManager registerToNotification];
    }
    return self;
}

#pragma mark - methods

- (void)startWith:(NSString *)assetKey completionHandler:(StartCompletionBlock)completionHandler {
    self.setupBlock = completionHandler;
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:nil
                                                 logType:OguryLogTypeInternal
                                                 message:@"Module started"
                                                    tags:nil]];

    if ([self.assetKeyManager configureAssetKey:assetKey] || [self.profigManager shouldSync]) {
        // Setup notifier otherwise further call to the internetReachability will return invalid statuses.
        [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                             adConfiguration:nil
                                                     logType:OguryLogTypeInternal
                                                     message:@"Invalid/No profig found, start profig sync"
                                                        tags:nil]];
        [self.internetReachability startNotifier];
        [self.webViewUserAgentService syncWebViewUserAgentAndDispatchDelegate];
    } else {
        [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelWarning
                                             adConfiguration:nil
                                                     logType:OguryLogTypeInternal
                                                     message:@"Ogury Ads only need to be started once. Additional calls are ignored."
                                                        tags:nil]];
        completionHandler(true, nil);
    }
}

- (BOOL)sdkInitialized {
    return self.assetKeyManager.sdkState != OgurySDKStateIdle && self.assetKeyManager.sdkState != OgurySDKStateError;
}

- (void)syncProfig {
    [self.profigManager syncProfigWithCompletion:^(OGAProfigFullResponse *response, NSError *error) {
        if (!response) {
            [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelWarning
                                                 adConfiguration:nil
                                                         logType:OguryLogTypeInternal
                                                         message:@"Failed to initialize Ogury Ads"
                                                            tags:nil]];
        }
        if (self.setupBlock != nil) {
            self.setupBlock(response != nil, error);
        }
        if (error) {
            [self.assetKeyManager setSdkState:OgurySDKStateError];
        } else {
            [self.assetKeyManager sdkIsReady];
        }
    }];
}

- (void)setLogLevel:(OguryLogLevel)logLevel {
    [self.log setLogLevel:logLevel];
}

- (void)addLogger:(id<OguryLogger>)logger {
    [self.log addLogger:logger];
}

- (void)removeLogger:(id<OguryLogger>)logger {
    [self.log removeLogger:logger];
}

// Hidden method allowing test app to change the URL of the server
- (void)changeServerEnvironment:(NSString *)environment {
    [self.environmentManager updateWith:environment];
}

// Hidden method allowing test app to reset the SDK
- (void)resetSDK {
    [self.assetKeyManager reset];
    [self resetAdConfiguration];
    [self.webViewUserAgentService reset];
}

- (void)resetAdConfiguration {
    [self.profigManager resetProfig];
}

- (NSString *)getVersion {
    return OGA_SDK_VERSION;
}

- (NSString *)getBuildVersion {
    return OGA_SDK_BUILD_VERSION;
}

- (void)defineSDKType:(NSUInteger)sdkType {
    [self.adManager setSdkType:sdkType];
}

- (void)defineMediationName:(NSString *)mediationName {
    [self.adManager defineMediationName:mediationName];
}

- (void)maxWebViewUserAgentRetryReached {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelWarning
                                         adConfiguration:nil
                                                 logType:OguryLogTypeInternal
                                                 message:@"Ogury Ads is unable to retreive webview User Agent."
                                                    tags:nil]];
    [self syncProfig];
}

- (void)receivedWebViewUserAgent:(NSString *)userAgent {
    [self syncProfig];
}

@end
