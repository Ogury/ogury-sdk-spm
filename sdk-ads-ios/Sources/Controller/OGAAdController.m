//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdController.h"
#import "OGAAdManager.h"
#import "OGAAdContainer.h"
#import "OGAShowAdAction.h"
#import "OGACloseAdAction.h"
#import "OGAUnloadAdAction.h"
#import "OGAForceCloseAdAction.h"
#import "OGAMonitoringDispatcher.h"
#import "OGALog.h"
#import "OGAMetricsService.h"
#import "OGATrackEvent.h"
#import "OGAAdExpirationManager.h"
#import "OGAProfigConstants.h"

@interface OGAAdController () <OGAAdDisplayerDelegate, OGAAdContainerDelegate>

#pragma mark - Properties

@property(nonatomic, strong) id<OGAAdDisplayer> displayer;
@property(nonatomic, strong) OGAAdConfiguration *configuration;
@property(nonatomic, strong) OGAAdContainer *container;
@property(nonatomic, strong) OGAMetricsService *metricsService;
@property(nonatomic, strong, nullable) OGANextAd *nextAd;
@property(nonatomic, strong) OGAAdExpirationManager *adExpirationManager;
@property(nonatomic, assign, readwrite) BOOL isExpanded;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;

@end

@implementation OGAAdController

#pragma mark - Initialization

- (instancetype)initWithAd:(OGAAd *)ad configuration:(OGAAdConfiguration *)configuration displayer:(id<OGAAdDisplayer>)displayer container:(OGAAdContainer *)container {
    return [self initWithAd:ad
               configuration:configuration
                   displayer:displayer
                   container:container
              metricsService:[OGAMetricsService shared]
         adExpirationManager:[OGAAdExpirationManager shared]
        monitoringDispatcher:[OGAMonitoringDispatcher shared]
                         log:[OGALog shared]];
}

- (instancetype)initWithAd:(OGAAd *)ad
             configuration:(OGAAdConfiguration *)configuration
                 displayer:(id<OGAAdDisplayer>)displayer
                 container:(OGAAdContainer *)container
            metricsService:(OGAMetricsService *)metricsService
       adExpirationManager:(OGAAdExpirationManager *)adExpirationManager
      monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                       log:(OGALog *)log {
    if (self = [super init]) {
        _ad = ad;
        _configuration = configuration;
        _displayer = displayer;
        _displayer.delegate = self;
        _container = container;
        _container.delegate = self;
        _metricsService = metricsService;
        _createdAt = [NSDate date];
        _adExpirationManager = adExpirationManager;
        _monitoringDispatcher = monitoringDispatcher;
        _log = log;
    }

    return self;
}

#pragma mark - Properties

- (BOOL)isLoaded {
    return [self.displayer isLoaded];
}

- (BOOL)isKilled {
    return [self.displayer isKilled];
}

- (BOOL)isExpired {
    NSNumber *expirationTime = self.expirationContext.expirationTime ?: @(OGAADExpirationTimeDefault);

    if ([[NSDate date] compare:[self.createdAt dateByAddingTimeInterval:expirationTime.doubleValue]] == NSOrderedDescending) {
        [self.adExpirationManager sendExpirationTrackerEventForAd:self.ad];
        return YES;
    };

    return NO;
}

- (BOOL)isDisplayed {
    return !self.isClosed && self.container.stateType != OGAAdContainerStateTypeInitial;
}

- (BOOL)isOverlay {
    return [self isStateTypeOverlay:self.container.stateType];
}

- (BOOL)isFullScreenOverlay {
    return self.container.stateType == OGAAdContainerStateTypeFullScreenOverlay;
}

- (BOOL)isClosed {
    return self.container.stateType == OGAAdContainerStateTypeClosed;
}

#pragma mark - Methods

- (BOOL)show:(OguryAdError *_Nullable *_Nullable)error {
    // adController transition succeed
    [self.monitoringDispatcher sendShowEvent:OGAShowEventDisplaying
                             adConfiguration:self.ad.adConfiguration];

    return [self performAction:[[OGAShowAdAction alloc] init] error:error];
}

- (void)sendLoadedTracker {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                         adConfiguration:self.ad.adConfiguration
                                                 logType:OguryLogTypeInternal
                                                 message:@"Sending LOADED track"
                                                    tags:nil]];

    [self.metricsService sendEvent:[[OGATrackEvent alloc] initWithAd:self.ad event:OGAMetricsEventLoaded]];
}

- (void)forceClose {
    OguryAdError *error = nil;
    if (![self performAction:[[OGAForceCloseAdAction alloc] init] error:&error]) {
        [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelInfo
                                             adConfiguration:self.ad.adConfiguration
                                                     logType:OguryLogTypeInternal
                                                       error:error
                                                     message:@"Force close failed"
                                                        tags:nil]];
    }
}

- (BOOL)isStateTypeOverlay:(OGAAdContainerStateType)stateType {
    return stateType == OGAAdContainerStateTypeOverlay || stateType == OGAAdContainerStateTypeFullScreenOverlay;
}

- (BOOL)hasNextAd {
    return (self.nextAd);
}

#pragma mark - OGAAdDisplayerDelegate

- (void)didLoad {
    [self sendLoadedTracker];
    if ([self.delegate respondsToSelector:@selector(controller:didLoadAd:)]) {
        [self.delegate controller:self didLoadAd:self.ad];
    }
}

- (void)webkitProcessDidTerminate {
    if ([self.delegate respondsToSelector:@selector(controller:webkitProcessDidTerminateForAd:)]) {
        [self.delegate controller:self webkitProcessDidTerminateForAd:self.ad];
    }
}

- (void)didUnLoadFrom:(UnloadOrigin)unloadOrigin {
    if ([self.delegate respondsToSelector:@selector(controller:didUnLoadAd:origin:)]) {
        [self.delegate controller:self didUnLoadAd:self.ad origin:unloadOrigin];
    }
}

- (BOOL)performAction:(id<OGAAdAction>)action error:(OguryAdError **)error {
    if ([action isKindOfClass:[OGAForceCloseAdAction class]]) {
        self.nextAd = [OGANextAd nextAdFalse];
    } else if ([action isKindOfClass:[OGAUnloadAdAction class]]) {
        self.nextAd = ((OGAUnloadAdAction *)action).nextAd;
    } else if ([action isKindOfClass:[OGACloseAdAction class]]) {
        self.nextAd = ((OGACloseAdAction *)action).nextAd;
    }
    return [action performAction:self.container error:error];
}

- (BOOL)adIsDisplayed {
    return self.isDisplayed;
}

#pragma mark - OGAAdContainerDelegate

- (void)didTransitionTo:(id<OGAAdContainerState>)toState from:(id<OGAAdContainerState>)fromState action:(NSString *)action {
    if (toState.type == OGAAdContainerStateTypeClosed && [self.delegate respondsToSelector:@selector(controller:didCloseWithNextAd:)] && ![action isEqualToString:OGAUnloadAdActionName]) {
        [self.delegate controller:self didCloseWithNextAd:self.nextAd];
    } else if (toState.type == OGAAdContainerStateTypeClosed && [self.delegate respondsToSelector:@selector(controller:didUnLoadWithNextAd:)] && [action isEqualToString:OGAUnloadAdActionName]) {
        [self.delegate controller:self didUnLoadWithNextAd:self.nextAd];
    }
    if (fromState.type != toState.type) {
        if ([self isStateTypeOverlay:toState.type] && [self.delegate respondsToSelector:@selector(controller:didOpenOverlayForAd:)]) {
            [self.delegate controller:self didOpenOverlayForAd:self.ad];
        }
        if ([self isStateTypeOverlay:fromState.type] && [self.delegate respondsToSelector:@selector(controller:didCloseOverlayForAd:)]) {
            [self.delegate controller:self didCloseOverlayForAd:self.ad];
        }
    }

    self.isExpanded = toState.isExpanded;
}

- (void)willTransitionTo:(id<OGAAdContainerState>)toState from:(id<OGAAdContainerState>)fromState {
    // noop
}

@end
