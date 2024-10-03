//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "OGAProfigManager.h"
#import "OGAProfigDao.h"
#import "OGALog.h"
#import "OGAAdIdentifierService.h"
#import "OGAConfigurationUtils+Profig.h"
#import "OGAEXTScope.h"
#import "OGAOMIDService.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAMetricsService.h"
#import "OGAUserDefaultsStore.h"
#import <OguryCore/OguryCore.h>
#import <OguryCore/OGCInternal.h>

static NSString *const OGAHashConsentKey = @"OGY-HashConsentKeys";

@interface OGAProfigManager ()

@property(nonatomic, strong) OGAProfigDao *profigDao;
@property(nonatomic, strong) OGAProfigService *profigService;
@property(nonatomic, strong) OGAOMIDService *omidService;
@property(nonatomic, strong) NSMutableArray<ProfigCompletionBlock> *waitingCompletionBlocks;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGCInternal *internalCore;
@property(nonatomic, strong) OGAUserDefaultsStore *userDefaultStore;

@end

@implementation OGAProfigManager

#pragma mark - Class methods

+ (instancetype)shared {
    static OGAProfigManager *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[OGAProfigManager alloc] init];
    });
    return instance;
}

#pragma mark - initialization

- (instancetype)init {
    return [self initWithProfigDao:[OGAProfigDao shared]
                     profigService:[[OGAProfigService alloc] init]
                       omidService:[OGAOMIDService shared]
              monitoringDispatcher:[OGAMonitoringDispatcher shared]
                    metricsService:[OGAMetricsService shared]
                               log:[OGALog shared]
                      internalCore:[OGCInternal shared]
                  userDefaultStore:[OGAUserDefaultsStore shared]];
}

- (instancetype)initWithProfigDao:(OGAProfigDao *)profigDao
                    profigService:(OGAProfigService *)profigService
                      omidService:(OGAOMIDService *)omidService
             monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                   metricsService:(OGAMetricsService *)metricsService
                              log:(OGALog *)log
                     internalCore:(OGCInternal *)internalCore
                 userDefaultStore:(OGAUserDefaultsStore *)userDefaultStore {
    if (self = [super init]) {
        _profigDao = profigDao;
        _profigService = profigService;
        _omidService = omidService;
        _monitoringDispatcher = monitoringDispatcher;
        _waitingCompletionBlocks = [[NSMutableArray alloc] init];
        _metricsService = metricsService;
        _log = log;
        _internalCore = internalCore;
        _userDefaultStore = userDefaultStore;
    }
    return self;
}

#pragma mark - methods
- (void)syncProfigWithCompletion:(ProfigCompletionBlock)completion {
    @synchronized(self.waitingCompletionBlocks) {
        if (self.waitingCompletionBlocks.count > 0) {
            [self.waitingCompletionBlocks addObject:completion];
        } else if ([self shouldSync]) {
            [self.waitingCompletionBlocks addObject:completion];
            [self.userDefaultStore setObject:[self retreiveConsentData] forKey:OGAHashConsentKey];
            [self fetchProfig];
        } else {
            if (self.profigDao.profigFullResponse.isOmidEnabled) {
                [self.omidService activateOMID];
            }
            [self updateMonitoringTrackingAndBlacklistedTracks:self.profigDao.profigFullResponse];
            completion(self.profigDao.profigFullResponse, nil);
        }
    }
}

- (void)resetProfig {
    [self.log log:OguryLogLevelInfo message:@"[Setup] resetProfig called"];

    [self dispatchToCompletionBlocks:self.waitingCompletionBlocks response:nil error:[OGAConfigurationUtils errorForOGAProfigError:OGAProfigExternalErrorSetupFailed]];
    // Get rid of the previous array that have been captured by the running profig requests.
    self.waitingCompletionBlocks = [[NSMutableArray alloc] init];
    [self.profigDao reset];
}

- (void)fetchProfig {
    [self.log log:OguryLogLevelInfo message:@"[Setup] fetchProfig called"];

    // __block is used to force the block to capture the reference to array.
    // This allow us to replace the array in case of reset.
    __block NSMutableArray<ProfigCompletionBlock> *completionBlocks = self.waitingCompletionBlocks;

    @weakify(self)
        [self.profigService loadWithCompletion:^(OGAProfigFullResponse *response, NSError *error) {
            @strongify(self)
                [self onProfigResponse:response
                                 error:error
                      completionBlocks:completionBlocks];
        }];
}

- (void)onProfigResponse:(OGAProfigFullResponse *)response error:(NSError *)error completionBlocks:(NSMutableArray<ProfigCompletionBlock> *)completionBlocks {
    [self.log log:OguryLogLevelDebug message:@"[Setup] onProfigResponse:error:completionBlocks called"];

    if (!response) {
        [self.log logError:error message:@"[Setup] Failed to synchronize configuration"];
    } else {
        if (error) {
            [self.log log:OguryLogLevelError message:[NSString stringWithFormat:@"[Setup] Failed to retrieved configuration (%@)", error.localizedDescription]];
            [self.profigDao updateWithFullProfig:response];
        } else {
            [self.log log:OguryLogLevelInfo message:@"[Setup] Configuration synchronized"];
            [self updateMonitoringTrackingAndBlacklistedTracks:response];
            [self.profigDao updateWithFullProfig:response];
            if (response.isOmidEnabled) {
                [self.omidService activateOMID];
            }
        }
    }

    [self dispatchToCompletionBlocks:completionBlocks response:response error:error];
}

- (void)updateMonitoringTrackingAndBlacklistedTracks:(OGAProfigFullResponse *)profigResponse {
    OGATrackingMask trackingMask = [self trackingMaskFromProfig:profigResponse];
    [self.monitoringDispatcher setBlackListedTracks:profigResponse.blacklistedTracks];
    [self.monitoringDispatcher setTrackingMask:trackingMask];
    [self.metricsService setTrackingMask:trackingMask];
}

- (OGATrackingMask)trackingMaskFromProfig:(OGAProfigFullResponse *)profigResponse {
    OGATrackingMask trackingMask = OGATrackingMaskNone;
    // activate monitoring only if the blacklistedTracks is set. Otherwise, we consider it's a server default and we don't enable monitoring
    if (profigResponse.adLifeCycleLogsEnabled && profigResponse.blacklistedTracks != nil) {
        trackingMask |= OGATrackingMaskAdsLifeCycle;
    }
    if (profigResponse.precachingLogsEnabled) {
        trackingMask |= OGATrackingMaskPreCache;
    }
    if (profigResponse.cacheLogsEnabled) {
        trackingMask |= OGATrackingMaskCache;
    }
    return trackingMask;
}

- (void)dispatchToCompletionBlocks:(NSMutableArray<ProfigCompletionBlock> *)completionBlocks response:(OGAProfigFullResponse *)response error:(NSError *)error {
    [self.log log:OguryLogLevelDebug message:@"[Setup] dispatchToCompletionBlocks:response:error called"];

    @synchronized(self.waitingCompletionBlocks) {
        for (ProfigCompletionBlock completionBlock in completionBlocks) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(response, error);
            });
        }

        [self.waitingCompletionBlocks removeAllObjects];
    }
}

- (NSData *)retreiveConsentData {
    NSData *gppData = [[self.internalCore gppConsentString] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *sidData = [[self.internalCore gppSID] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *tcfData = [[self.internalCore tcfConsentString] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *privacy = [self.internalCore retrieveDataPrivacy];
    NSData *privacyData = [NSKeyedArchiver archivedDataWithRootObject:privacy];
    NSMutableData *consentData = [[NSMutableData alloc] init];
    [consentData appendData:gppData];
    [consentData appendData:sidData];
    [consentData appendData:tcfData];
    if (privacy.allKeys.count > 0) {
        [consentData appendData:privacyData];
    }
    return consentData;
}

- (BOOL)shouldSync {
    NSData *previousConsent = [self.userDefaultStore dataForKey:OGAHashConsentKey];
    NSData *consentData = [self retreiveConsentData];
    if ([previousConsent isEqual:consentData] || (consentData.length == 0 && previousConsent.length == 0)) {
        return [self isProfigExpired] || [self profigParametersWereUpdated];
    }
    return YES;
}

- (BOOL)profigParametersWereUpdated {
    return ![[OGAAdIdentifierService getInstanceToken] isEqualToString:self.profigDao.profigInstanceToken];
}

- (BOOL)isProfigExpired {
    OGAProfigFullResponse *profig = self.profigDao.profigFullResponse;
    NSDate *lastSyncDate = self.profigDao.lastProfigSyncDate;
    NSDate *nextSyncDate = [lastSyncDate dateByAddingTimeInterval:profig.retryInterval.integerValue];
    NSDate *todayNow = [NSDate date];

    if (!nextSyncDate) {
        return YES;
    }

    if ([nextSyncDate compare:todayNow] == NSOrderedAscending) {
        return YES;
    }

    if ([nextSyncDate compare:todayNow] == NSOrderedDescending) {
        return NO;
    }

    if ([nextSyncDate compare:todayNow] == NSOrderedSame) {
        return YES;
    }

    return NO;
}

- (OGAAdPrivacyConfiguration *_Nonnull)currentPrivacyConfiguration {
    return [self.profigDao.profigFullResponse getPrivacyConfiguration] ?: [[OGAAdPrivacyConfiguration alloc] initWithAdSyncPermissionMask:0 monitoringMask:0];
}

@end
