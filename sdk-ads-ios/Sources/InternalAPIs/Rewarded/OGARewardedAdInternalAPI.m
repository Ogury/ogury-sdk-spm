//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGARewardedAdInternalAPI.h"
#import "NSDictionary+OGABase64.h"
#import "OGAAdManager.h"
#import "OGAAnotherAdInFullScreenOverlayStateChecker.h"
#import "OGAEXTScope.h"
#import "OGAInternalAPIConstants.h"
#import "OGAInternetConnectionChecker.h"
#import "OGALog.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAAdSequenceCoordinator.h"
#import "OGAAdController.h"
#import "OGAInternal.h"

@interface OGARewardedAdInternalAPI ()

#pragma mark - Properties

@property(nonatomic, strong) OGAAdSequence *sequence;
@property(nonatomic, strong) OGAAdConfiguration *configuration;
@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) OGAInternetConnectionChecker *internetConnectionChecker;
@property(nonatomic, strong) OGAAnotherAdInFullScreenOverlayStateChecker *anotherAdInFullScreenOverlayStateChecker;
@property(nonatomic, strong) OGADelegateDispatcher *delegateDispatcher;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAInternal *internal;

@property(nonatomic, weak) UIViewController *viewController;

@end

@implementation OGARewardedAdInternalAPI

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       mediation:(OguryMediation *_Nullable)mediation {
    return [self initWithAdUnitId:adUnitId
                              delegateDispatcher:delegateDispatcher
                                       adManager:[OGAAdManager sharedManager]
                       internetConnectionChecker:[OGAInternetConnectionChecker shared]
        anotherAdInFullScreenOverlayStateChecker:[OGAAnotherAdInFullScreenOverlayStateChecker shared]
                            monitoringDispatcher:[OGAMonitoringDispatcher shared]
                                        internal:[OGAInternal shared]
                                       mediation:mediation
                                             log:[OGALog shared]];
}

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                          delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                                   adManager:(OGAAdManager *)adManager
                   internetConnectionChecker:(OGAInternetConnectionChecker *)internetConnectionChecker
    anotherAdInFullScreenOverlayStateChecker:(OGAAnotherAdInFullScreenOverlayStateChecker *)anotherAdInOverlayStateChecker
                        monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                                    internal:(OGAInternal *)internal
                                   mediation:(OguryMediation *_Nullable)mediation
                                         log:(OGALog *)log {
    if (self = [super init]) {
        _delegateDispatcher = delegateDispatcher;
        _adManager = adManager;
        _internetConnectionChecker = internetConnectionChecker;
        _anotherAdInFullScreenOverlayStateChecker = anotherAdInOverlayStateChecker;
        _monitoringDispatcher = monitoringDispatcher;
        _log = log;
        _internal = internal;
        @weakify(self) _configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeOptinVideo
                                                                        adUnitId:adUnitId
                                                              delegateDispatcher:_delegateDispatcher
                                                          viewControllerProvider:^UIViewController * {
                                                              @strongify(self) return self.viewController;
                                                          }];
        self.configuration.mediation = mediation;
    }

    return self;
}

#pragma mark - Properties

- (NSString *)adUnitId {
    return self.configuration.adUnitId;
}

- (NSString *)userId {
    return self.configuration.userId;
}

- (void)setUserId:(NSString *)userId {
    self.configuration.userId = userId;
}

#pragma mark - Methods

- (void)load {
    [self loadWithCampaignId:nil];
}

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId {
    [self loadWithCampaignId:campaignId creativeId:nil];
}

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId {
    [self loadWithCampaignId:campaignId
                  creativeId:creativeId
               dspCreativeId:nil
                   dspRegion:nil];
}

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId
                creativeId:(NSString *_Nullable)creativeId
             dspCreativeId:(NSString *_Nullable)dspCreativeId
                 dspRegion:(NSString *_Nullable)dspRegion {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:self.configuration
                                                 logType:OguryLogTypeInternal
                                                 message:@"loadWithCampaignId... called:"
                                                    tags:@[
                                                        [OguryLogTag tagWithKey:@"DspCreative"
                                                                          value:dspCreativeId == nil ? @"" : dspCreativeId],
                                                        [OguryLogTag tagWithKey:@"DspRegion"
                                                                          value:dspRegion == nil ? @"" : dspRegion]
                                                    ]]];
    self.configuration.campaignId = campaignId;
    self.configuration.creativeId = creativeId;
    if (dspCreativeId && dspRegion) {
        self.configuration.adDsp = [[OGAAdDsp alloc] initWithCreativeId:dspCreativeId
                                                                 region:dspRegion];
    }

    // if the force reload campaign/creative/dsp changed, then we make a new complete reload
    // development only
    if ([self.sequence.configuration configurationHasChanged:campaignId
                                                  creativeId:creativeId
                                               dspCreativeId:dspCreativeId
                                                   dspRegion:dspRegion]) {
        self.sequence = nil;
    } else if (self.sequence != nil &&
               (self.sequence.status == OGAAdSequenceStatusLoaded || self.sequence.status == OGAAdSequenceStatusLoading)) {
        // if there was a previous sequence, we retrieve all monitoring information to continue to use it
        self.configuration.monitoringDetails = self.sequence.monitoringAdConfiguration.monitoringDetails;
    }
    self.sequence = [self.adManager loadAdConfiguration:self.configuration previousSequence:self.sequence];
}

- (void)loadWithAdMarkup:(NSString *)adMarkup {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:self.configuration
                                                 logType:OguryLogTypeInternal
                                                 message:@"loadWithAdMarkup:"
                                                    tags:@[ [OguryLogTag tagWithKey:@"adMarkup" value:adMarkup] ]]];

    self.configuration.campaignId = nil;
    self.configuration.isHeaderBidding = true;
    self.configuration.encodedAdMarkup = adMarkup;
    self.sequence = [self.adManager loadAdConfiguration:self.configuration previousSequence:self.sequence];
}

- (BOOL)isLoaded {
    return [self.adManager isLoaded:self.sequence];
}

- (void)showAdInViewController:(UIViewController *)viewController {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:self.configuration
                                                 logType:OguryLogTypeInternal
                                                 message:@"showAdInViewController:viewController called"
                                                    tags:nil]];

    self.viewController = viewController;

    if (self.sequence == nil) {
        self.sequence = [[OGAAdSequence alloc] initWithAdConfiguration:self.configuration];
    }

    [self.adManager show:self.sequence additionalConditions:@[ self.anotherAdInFullScreenOverlayStateChecker ]];
}

@end
