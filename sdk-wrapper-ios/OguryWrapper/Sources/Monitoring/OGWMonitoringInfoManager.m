//
// Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGWMonitoringInfoManager.h"

#import "OGWLog.h"
#import "OGWMonitoringInfoFetcher.h"
#import "OGWMonitoringInfoSender.h"
#import "OGWMonitoringInfoStore.h"
#import "OguryConfigurationPrivate.h"

@interface OGWMonitoringInfoManager ()

@property(nonatomic, strong) OGWMonitoringInfoFetcher *monitoringInfoFetcher;
@property(nonatomic, strong) OGWMonitoringInfoSender *monitoringInfoSender;
@property(nonatomic, strong) OGWMonitoringInfoStore *monitoringInfoStore;

@end

@implementation OGWMonitoringInfoManager

#pragma mark - Initialization

- (instancetype)init {
   return [self initWithMonitoringInfoFetcher:[[OGWMonitoringInfoFetcher alloc] init]
                         monitoringInfoSender:[[OGWMonitoringInfoSender alloc] init]
                          monitoringInfoStore:[[OGWMonitoringInfoStore alloc] init]];
}

- (instancetype)initWithMonitoringInfoFetcher:(OGWMonitoringInfoFetcher *)monitoringInfoFetcher
                         monitoringInfoSender:(OGWMonitoringInfoSender *)monitoringInfoSender
                          monitoringInfoStore:(OGWMonitoringInfoStore *)monitoringInfoStore {
   if (self = [super init]) {
      _monitoringInfoFetcher = monitoringInfoFetcher;
      _monitoringInfoSender = monitoringInfoSender;
      _monitoringInfoStore = monitoringInfoStore;
   }
   return self;
}

#pragma mark - Methods

- (void)appendMonitoringInfoAndSendIfNecessary:(OguryConfiguration *)configuration {
   OGWMonitoringInfo *monitoringInfo = [self.monitoringInfoFetcher populate:configuration];

   __block OGWMonitoringInfo *storedMonitoringInfo = [self createOrLoadMonitoringInfo];
   if (![storedMonitoringInfo containsAll:monitoringInfo]) {
      [storedMonitoringInfo putAll:monitoringInfo];
      [[OGWLog shared] logAssetKeyFormat:OguryLogLevelDebug assetKey:configuration.assetKey format:@"Sending monitoring info to server: %@", storedMonitoringInfo.debugDescription];
      [self sendAndStoreMonitoringInfo:storedMonitoringInfo];
   }
}

- (OGWMonitoringInfo *)createOrLoadMonitoringInfo {
   OGWMonitoringInfo *storedMonitoringInfo = [self.monitoringInfoStore load];
   if (!storedMonitoringInfo) {
      storedMonitoringInfo = [[OGWMonitoringInfo alloc] init];
   }
   return storedMonitoringInfo;
}

- (void)sendAndStoreMonitoringInfo:(OGWMonitoringInfo *)monitoringInfo {
   __weak OGWMonitoringInfoManager *weakSelf = self;
   [self.monitoringInfoSender send:monitoringInfo
                 completionHandler:^(NSError *error) {
                   __strong OGWMonitoringInfoManager *strongSelf = weakSelf;
                   if (!strongSelf) {
                      return;
                   }
                   if (error) {
                      [[OGWLog shared] logError:error message:@"Failed to send monitoring info to server."];
                      return;
                   }
                   NSError *saveError;
                   if (![strongSelf.monitoringInfoStore save:monitoringInfo error:&saveError]) {
                      [[OGWLog shared] logError:saveError message:@"Failed to store monitoring info to server."];
                   }
                 }];
}

@end
