//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAdExpirationManager.h"
#import "OGAAd.h"
#import "OGAMetricsService.h"
#import "OGATrackEvent.h"
#import "OGALog.h"

@interface OGAAdExpirationManager ()

@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(atomic, strong) NSMutableDictionary<NSString *, NSNumber *> *expirationTrackersSentByAdLocalIdentifiers;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAAdExpirationManager

#pragma mark - Constants

+ (instancetype)shared {
    static OGAAdExpirationManager *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithMetricsService:[OGAMetricsService shared] log:[OGALog shared]];
}

- (instancetype)initWithMetricsService:(OGAMetricsService *)metricsService log:(OGALog *)log {
    if (self = [super init]) {
        _metricsService = metricsService;
        _expirationTrackersSentByAdLocalIdentifiers = [[NSMutableDictionary alloc] init];
        _log = log;
    }

    return self;
}

#pragma mark - Methods

- (void)sendExpirationTrackerEventForAd:(OGAAd *)ad {
    if (!ad.localIdentifier) {
        [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelWarning
                                             adConfiguration:ad.adConfiguration
                                                     logType:OguryLogTypeInternal
                                                     message:@"Tried to send expiration tracker event without a local identifier"
                                                        tags:nil]];
        return;
    }

    @synchronized(self) {
        if (![self.expirationTrackersSentByAdLocalIdentifiers[ad.localIdentifier] boolValue]) {
            self.expirationTrackersSentByAdLocalIdentifiers[ad.localIdentifier] = @(YES);

            [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelWarning
                                                 adConfiguration:ad.adConfiguration
                                                         logType:OguryLogTypeInternal
                                                         message:@"Sending EXPIRED track"
                                                            tags:nil]];

            [self.metricsService sendEvent:[[OGATrackEvent alloc] initWithAd:ad event:OGAMetricsEventExpired]];
        }
    }
}

@end
