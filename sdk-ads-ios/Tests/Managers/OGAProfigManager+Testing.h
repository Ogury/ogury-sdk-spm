//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAProfigManager.h"

#import <WebKit/WebKit.h>

#import "OGAProfigDao.h"
#import "OGAProfigService.h"
#import "OGAOMIDService.h"
#import "OGALog.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAMetricsService.h"
#import "OGAUserDefaultsStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAProfigManager (Testing)

@property(nonatomic, strong) OGAProfigDao *profigDao;
@property(nonatomic, strong) OGAProfigService *profigService;
@property(nonatomic, strong) NSMutableArray<ProfigCompletionBlock> *waitingCompletionBlocks;
@property(nonatomic, retain) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAMetricsService *metricsService;

- (instancetype)initWithProfigDao:(OGAProfigDao *)profigDao
                    profigService:(OGAProfigService *)profigService
                      omidService:(OGAOMIDService *)omidService
             monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                   metricsService:(OGAMetricsService *)metricsService
                              log:(OGALog *)log
                     internalCore:(OGCInternal *)internalCore
                 userDefaultStore:(OGAUserDefaultsStore *)userDefaultStore;

- (BOOL)shouldSync;

- (BOOL)profigParametersWereUpdated;

- (BOOL)isProfigExpired;

- (void)fetchProfig;

- (void)onProfigResponse:(OGAProfigFullResponse *_Nullable)response error:(NSError *_Nullable)error completionBlocks:(NSMutableArray<ProfigCompletionBlock> *)completionBlocks;

- (void)dispatchToCompletionBlocks:(NSMutableArray<ProfigCompletionBlock> *)completionBlocks response:(OGAProfigFullResponse *_Nullable)response error:(NSError *_Nullable)error;

- (void)updateMonitoringTrackingAndBlacklistedTracks:(OGAProfigFullResponse *)profigResponse;

- (OGATrackingMask)trackingMaskFromProfig:(OGAProfigFullResponse *)profigResponse;

- (NSData *)retrieveConsentData;

@end

NS_ASSUME_NONNULL_END
