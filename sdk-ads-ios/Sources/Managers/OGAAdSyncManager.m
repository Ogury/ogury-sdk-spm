//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdSyncManager.h"
#import "OGAProfigManager.h"
#import "OGAAdSyncService.h"
#import "OGAAdConfiguration.h"
#import "OGAAd.h"
#import "OGAEXTScope.h"
#import "OGAWebViewUserAgentService.h"
#import "OGALog.h"

@interface OGAAdSyncManager ()

@property(nonatomic, strong) OGAProfigManager *profigManager;
@property(nonatomic, strong) OGAAdSyncService *adSyncService;
@property(nonatomic, strong) OGAWebViewUserAgentService *webViewUserAgentService;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAAdSyncManager

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithProfigManager:[OGAProfigManager shared]
                         adSyncService:[[OGAAdSyncService alloc] init]
               webViewUserAgentService:[OGAWebViewUserAgentService shared]
                                   log:[OGALog shared]];
}

- (instancetype)initWithProfigManager:(OGAProfigManager *)profigManager
                        adSyncService:(OGAAdSyncService *)adSyncService
              webViewUserAgentService:(OGAWebViewUserAgentService *)webViewUserAgentService
                                  log:(OGALog *)log {
    if (self = [super init]) {
        _profigManager = profigManager;
        _adSyncService = adSyncService;
        _webViewUserAgentService = webViewUserAgentService;
        _log = log;
    }

    return self;
}

#pragma mark - Class methods

+ (instancetype)shared {
    static OGAAdSyncManager *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

#pragma mark - Methods

- (void)postAdSyncForAdConfiguration:(OGAAdConfiguration *)adConfiguration
                privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration
                   completionHandler:(OGAAdSyncCompletionHandler)completionHandler {
    if ([self.profigManager shouldSync]) {
        completionHandler(nil, [OguryAdsError invalidConfigurationFrom:OguryInternalAdsErrorOriginLoad]);
        return;
    }

    [self.adSyncService postAdSyncForAdConfiguration:adConfiguration
                                privacyConfiguration:privacyConfiguration
                                   completionHandler:^(NSArray<OGAAd *> *ads, NSError *error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           completionHandler(ads, error);
                                       });
                                   }];
}

- (void)fetchCustomCloseWithURL:(NSURL *)url {
    [self.adSyncService fetchCustomCloseWithURL:url];
}

@end
