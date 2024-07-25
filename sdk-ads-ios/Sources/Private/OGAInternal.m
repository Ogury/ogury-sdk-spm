//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import "OGAInternal.h"
#import "OGAAdManager.h"
#import "OGAAssetKeyManager.h"
#import "OGABroadcastEventBus.h"
#import "OGAEnvironmentManager.h"
#import "OGALog.h"
#import "OGAPersistentEventBus.h"
#import "OGAProfigManager.h"
#import "OGAReachability.h"
#import "OGASetLogLevelNotificationManager.h"
#import "OGAWebViewUserAgentService.h"
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
@property(nonatomic, strong) OGABroadcastEventBus *broadcastEventBus;
@property(nonatomic, strong) OGAPersistentEventBus *persistentEventBus;

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
    return [self initWithPersistentEventBus:[[OGAPersistentEventBus alloc] init]
                          broadcastEventBus:[[OGABroadcastEventBus alloc] init]
                            assetKeyManager:[OGAAssetKeyManager shared]
                              profigManager:[OGAProfigManager shared]
                         environmentManager:[OGAEnvironmentManager shared]
                       internetReachability:[OGAReachability reachabilityForInternetConnection]
                                  adManager:[OGAAdManager sharedManager]
                                        log:[OGALog shared]
                     logNotificationManager:[[OGASetLogLevelNotificationManager alloc] init]
                    webViewUserAgentService:[OGAWebViewUserAgentService shared]];
}

- (instancetype)initWithPersistentEventBus:(OGAPersistentEventBus *)consentEventBus
                         broadcastEventBus:(OGABroadcastEventBus *)broadcastEventBus
                           assetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                             profigManager:(OGAProfigManager *)profigManager
                        environmentManager:(OGAEnvironmentManager *)environmentManager
                      internetReachability:(OGAReachability *)internetReachability
                                 adManager:(OGAAdManager *)adManager
                                       log:(OGALog *)log
                    logNotificationManager:(OGASetLogLevelNotificationManager *)logNotificationManager
                   webViewUserAgentService:(OGAWebViewUserAgentService *)webViewUserAgentService {
    if (self = [super init]) {
        _persistentEventBus = consentEventBus;
        _broadcastEventBus = broadcastEventBus;
        _assetKeyManager = assetKeyManager;
        _profigManager = profigManager;
        _profigManager.broadcastEventBus = broadcastEventBus;
        _environmentManager = environmentManager;
        _internetReachability = internetReachability;
        _adManager = adManager;
        _adManager.persistentEventBus = consentEventBus;
        _log = log;
        _logNotificationManager = logNotificationManager;
        _webViewUserAgentService = webViewUserAgentService;
        _webViewUserAgentService.delegate = self;
        [_logNotificationManager registerToNotification];
    }
    return self;
}

#pragma mark - methods

- (void)startWithAssetKey:(NSString *)assetKey
       persistentEventBus:(OguryPersistentEventBus *)persistentEventBus
        broadcastEventBus:(OguryEventBus *)broadcastEventBus {
    [self.log log:OguryLogLevelInfo message:@"Module started"];
    if (persistentEventBus) {
        self.persistentEventBus.corePersistentEventBus = persistentEventBus;
    }
    if (broadcastEventBus) {
        self.broadcastEventBus.coreBroadcastEventBus = broadcastEventBus;
    }

    [self.adManager registerToPersistentEventBus];
    [self.profigManager registerToBroadcastEventBus];

    // if ([self.assetKeyManager shouldResetSDKFor:assetKey]) {
    //    [self resetSDK];
    // }

    if ([self.assetKeyManager configureAssetKey:assetKey]) {
        // Setup notifier otherwise further call to the internetReachability will return invalid statuses.
        [self.internetReachability startNotifier];

        [self.webViewUserAgentService syncWebViewUserAgent];

    } else {
        [self.log log:OguryLogLevelWarning message:@"Ogury Ads only need to be started once. Additional calls are ignored."];
    }
}

- (BOOL)sdkInitialized {
    return self.assetKeyManager.sdkState != OgurySDKStateIdle && self.assetKeyManager.sdkState != OgurySDKStateError;
}

- (void)syncProfig {
    [self.profigManager syncProfigWithCompletion:^(OGAProfigFullResponse *response, NSError *error) {
        [self.assetKeyManager sdkIsReady];
        if (!response) {
            [self.log logError:error message:@"Failed to initialize Ogury Ads"];
        }
    }];
}

- (void)setLogLevel:(OguryLogLevel)logLevel {
    [self.log setLogLevel:logLevel];
}

// Hidden method allowing test app to change the URL of the server
- (void)changeServerEnvironment:(NSString *)environment {
    [self.environmentManager updateWith:environment];
}

// Hidden method allowing test app to reset the SDK
- (void)resetSDK {
    [self.assetKeyManager reset];
    [self.profigManager resetProfig];
    [self.webViewUserAgentService reset];
}

- (NSString *)getVersion {
    return OGA_SDK_VERSION;
}

- (NSString *)getBuildVersion {
    return OGA_SDK_BUILD_VERSION;
}

- (void)defineSDKType:(NSUInteger)sdkType {
    [self.adManager defineSDKType:sdkType];
}

- (void)defineMediationName:(NSString *)mediationName {
    [self.adManager defineMediationName:mediationName];
}

- (void)maxWebViewUserAgentRetryReached {
    [self.log log:OguryLogLevelWarning message:@"Ogury Ads is unable to retreive webview User Agent."];
    [self syncProfig];
}

- (void)receivedWebViewUserAgent:(NSString *)userAgent {
    [self syncProfig];
}

@end
