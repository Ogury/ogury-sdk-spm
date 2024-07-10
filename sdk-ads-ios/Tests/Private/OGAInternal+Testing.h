//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import "OGAInternal.h"

#import "OGAAdManager.h"
#import "OGAAssetKeyManager.h"
#import "OGABroadcastEventBus.h"
#import "OGAEnvironmentManager.h"
#import "OGAPersistentEventBus.h"
#import "OGAProfigManager.h"
#import "OGAReachability.h"
#import "OGASetLogLevelNotificationManager.h"
#import "OGAWebViewUserAgentService.h"

@interface OGAInternal (Testing)

- (instancetype)initWithPersistentEventBus:(OGAPersistentEventBus *)consentEventBus
                         broadcastEventBus:(OGABroadcastEventBus *)broadcastEventBus
                           assetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                             profigManager:(OGAProfigManager *)profigManager
                        environmentManager:(OGAEnvironmentManager *)environmentManager
                      internetReachability:(OGAReachability *)internetReachability
                                 adManager:(OGAAdManager *)adManager
                                       log:(OGALog *)log
                    logNotificationManager:(OGASetLogLevelNotificationManager *)logNotificationManager
                   webViewUserAgentService:(OGAWebViewUserAgentService *)webViewUserAgentService;

- (void)changeServerEnvironment:(NSString *)environment;

- (void)resetSDK;

@end
