//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGABannerAdViewInternalAPI.h"
#import "NSDictionary+OGABase64.h"
#import "OGAAdManager.h"
#import "OGAInternalAPIConstants.h"
#import "OGALog.h"
#import "OGAMonitoringDispatcher.h"
#import "OguryBannerAdViewDelegateDispatcher.h"
#import "OGAAdSequenceCoordinator.h"
#import "OGAAdController.h"
#import "OGAInternal.h"

#pragma mark - Constants

NSString *const OGABannerAdInternalAPIBannerDidMoveToWindowNotificationName = @"OGABannerAdInternalAPIBannerDidMoveToWindowNotificationName";

@interface OGABannerAdViewInternalAPI () <OguryBannerAdViewDelegate>

#pragma mark - Properties

@property(nonatomic, strong) OGADelegateDispatcher *dispatcherProxy;
@property(nonatomic, strong) OGAAdSequence *sequence;
@property(nonatomic, strong) OGAAdConfiguration *configuration;
@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) OguryBannerAdSize *size;
@property(nonatomic, strong) NSNotificationCenter *notificationCenter;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAInternal *internal;

@end

@implementation OGABannerAdViewInternalAPI

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       mediation:(OguryMediation *_Nullable)mediation {
    [NSException raise:@"DoNotUse" format:@"Do not use this initializer"];
    return nil;
}

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                      bannerView:(UIView *)bannerView
                            size:(OguryBannerAdSize *)size
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       mediation:(OguryMediation *_Nullable)mediation {
    return [self initWithAdUnitId:adUnitId
                       bannerView:bannerView
                             size:size
               delegateDispatcher:delegateDispatcher
                        adManager:[OGAAdManager sharedManager]
               notificationCenter:NSNotificationCenter.defaultCenter
             monitoringDispatcher:[OGAMonitoringDispatcher shared]
                         internal:[OGAInternal shared]
                        mediation:mediation
                              log:[OGALog shared]];
}

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                      bannerView:(UIView *)bannerView
                            size:(OguryBannerAdSize *)size
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       adManager:(OGAAdManager *)adManager
              notificationCenter:(NSNotificationCenter *)notificationCenter
            monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                        internal:(OGAInternal *)internal
                       mediation:(OguryMediation *_Nullable)mediation
                             log:(OGALog *)log {
    if (self = [super init]) {
        _bannerView = bannerView;
        _log = log;
        _monitoringDispatcher = monitoringDispatcher;
        _delegateDispatcher = delegateDispatcher;
        _internal = internal;
        _size = size;

        // Use a proxy to intercept lifecycle messages and resend them to the original delegate dispatcher
        _dispatcherProxy = [[OguryBannerAdViewDelegateDispatcher alloc] init];
        _dispatcherProxy.delegate = self;

        _adManager = adManager;

        _configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeBanner
            adUnitId:adUnitId
            delegateDispatcher:_dispatcherProxy
            viewControllerProvider:^UIViewController *_Nonnull {
                return [self.delegateDispatcher bannerViewController] ?: self.bannerView.window.rootViewController;
            }
            viewProvider:^UIView * {
                return self.bannerView;
            }];
        self.configuration.mediation = mediation;

        _notificationCenter = notificationCenter;
    }

    return self;
}

#pragma mark - Properties

- (NSString *)adUnitId {
    return self.configuration.adUnitId;
}

- (BOOL)isExpanded {
    return [self.adManager isExpanded:self.sequence];
}

- (BOOL)isLoaded {
    return [self.adManager isLoaded:self.sequence];
}

#pragma mark - Methods

- (void)load {
    [self loadWithCampaignId:nil];
}

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId {
    [self loadWithCampaignId:campaignId creativeId:nil];
}

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId
                creativeId:(NSString *_Nullable)creativeId {
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

    CGSize size = [self.size getSize];
    self.bannerView.frame = CGRectMake(self.bannerView.frame.origin.x,
                                       self.bannerView.frame.origin.y,
                                       size.width,
                                       size.height);
    self.configuration.size = size;
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
    CGSize size = [self.size getSize];
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:self.configuration
                                                 logType:OguryLogTypeInternal
                                                 message:@"loadWithAdMarkup:"
                                                    tags:@[
                                                        [OguryLogTag tagWithKey:@"adMarkup"
                                                                          value:adMarkup],
                                                        [OguryLogTag tagWithKey:@"size"
                                                                          value:[NSString stringWithFormat:@"w:%f h:%f", size.height, size.width]]
                                                    ]]];

    self.configuration.size = size;
    self.configuration.campaignId = nil;
    self.configuration.isHeaderBidding = true;
    self.configuration.encodedAdMarkup = adMarkup;
    self.sequence = [self.adManager loadAdConfiguration:self.configuration previousSequence:self.sequence];
}

- (void)destroy {
    [self.adManager close:self.sequence];
}

- (void)didMoveToSuperview {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:self.configuration
                                                 logType:OguryLogTypeInternal
                                                 message:@"Successfully attached to the super view"
                                                    tags:nil]];

    [self showBannerIfLoaded];
}

- (void)didMoveToWindow {
    // we must send notification before show banner to have the right window on exposure calculation
    [self.notificationCenter postNotificationName:OGABannerAdInternalAPIBannerDidMoveToWindowNotificationName object:self.configuration.adUnitId userInfo:nil];

    [self showBannerIfLoaded];
}

- (void)showBannerIfLoaded {
    if ([self isLoaded] && [self haveParentViewcontroller]) {
        [self.adManager show:self.sequence additionalConditions:nil];
    }
}

- (BOOL)haveParentViewcontroller {
    return [self.delegateDispatcher bannerViewController] != nil || self.bannerView.window.rootViewController != nil;
}

#pragma mark - OguryBannerAdViewDelegate
- (void)bannerAdViewDidLoad:(OguryBannerAdView *)bannerAd {
    [self.delegateDispatcher loaded];

    // Banner must be shown as soon as it is loaded
    if ([self haveParentViewcontroller]) {
        [self.adManager show:self.sequence additionalConditions:nil];
    }
}

- (void)bannerAdViewDidClick:(OguryBannerAdView *)bannerAd {
    [self.delegateDispatcher clicked];
}

- (void)bannerAdViewDidClose:(OguryBannerAdView *)bannerAd {
    [self.delegateDispatcher closed];
}

- (void)bannerAdView:(OguryBannerAdView *)bannerAd didFailWithError:(OguryAdError *)error {
    [self.delegateDispatcher failedWithError:error];
}

- (void)bannerAdViewDidTriggerImpression:(OguryBannerAdView *)bannerAd {
    [self.delegateDispatcher adImpression];
}

@end
