//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAThumbnailAdInternalAPI.h"
#import "NSDictionary+OGABase64.h"
#import "OGAAdConfiguration.h"
#import "OGAAdManager.h"
#import "OGAAnotherAdOfSameTypeAlreadyDisplayedChecker.h"
#import "OGAEXTScope.h"
#import "OGAInternetConnectionChecker.h"
#import "OGALog.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAThumbnailAdConstants.h"
#import "OGAAdSequenceCoordinator.h"
#import "OGAAdController.h"
#import "OGAInternal.h"

@interface OGAThumbnailAdInternalAPI ()

@property(nonatomic, strong) OGAAdSequence *sequence;
@property(nonatomic, strong) OGAAdConfiguration *configuration;
@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) OGAInternetConnectionChecker *internetConnectionChecker;
@property(nonatomic, strong) OGAAnotherAdOfSameTypeAlreadyDisplayedChecker *anotherAdOfSameTypeAlreadyDisplayedChecker;
@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic, weak) UIViewController *viewController;
@property(nonatomic, strong) OGAInternal *internal;

@end

@implementation OGAThumbnailAdInternalAPI

static OguryRectCorner const OguryAdsThumbnailDefaultConer = OguryRectCornerBottomRight;

#pragma mark - Initialization

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       mediation:(OguryMediation *_Nullable)mediation {
    return [self initWithAdUnitId:adUnitId
                                delegateDispatcher:delegateDispatcher
                                         adManager:[OGAAdManager sharedManager]
                         internetConnectionChecker:[OGAInternetConnectionChecker shared]
        anotherAdOfSameTypeAlreadyDisplayedChecker:[OGAAnotherAdOfSameTypeAlreadyDisplayedChecker shared]
                              monitoringDispatcher:[OGAMonitoringDispatcher shared]
                                          internal:[OGAInternal shared]
                                         mediation:mediation
                                               log:[OGALog shared]];
}

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                            delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                                     adManager:(OGAAdManager *)adManager
                     internetConnectionChecker:(OGAInternetConnectionChecker *)internetConnectionChecker
    anotherAdOfSameTypeAlreadyDisplayedChecker:(OGAAnotherAdOfSameTypeAlreadyDisplayedChecker *)anotherAdOfSameTypeAlreadyDisplayedChecker
                          monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                                      internal:(OGAInternal *)internal
                                     mediation:(OguryMediation *_Nullable)mediation
                                           log:(OGALog *)log {
    if (self = [super init]) {
        _delegateDispatcher = delegateDispatcher;
        _adManager = adManager;
        _internetConnectionChecker = internetConnectionChecker;
        _anotherAdOfSameTypeAlreadyDisplayedChecker = anotherAdOfSameTypeAlreadyDisplayedChecker;
        _monitoringDispatcher = monitoringDispatcher;
        _log = log;
        _internal = internal;

        @weakify(self) _configuration = [[OGAAdConfiguration alloc] initWithType:OguryAdsTypeThumbnailAd
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

- (BOOL)isExpanded {
    return [self.adManager isExpanded:self.sequence];
}

#pragma mark - Methods
- (void)load {
    CGSize defaultThumbnailSize = CGSizeMake(OGAThumbnailDefaultWidth, OGAThumbnailDefaultHeight);
    [self loadWithMaxSize:defaultThumbnailSize];
}

- (void)loadWithMaxSize:(CGSize)thumbnailSize {
    [self loadWithCampaignId:nil creativeId:nil thumbnailSize:thumbnailSize];
}

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId thumbnailSize:(CGSize)thumbnailSize {
    [self loadWithCampaignId:campaignId creativeId:nil thumbnailSize:thumbnailSize];
}

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId thumbnailSize:(CGSize)thumbnailSize {
    [self loadWithCampaignId:campaignId creativeId:creativeId dspCreativeId:nil dspRegion:nil thumbnailSize:thumbnailSize];
}

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId {
    [self loadWithCampaignId:campaignId creativeId:nil];
}

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId creativeId:(NSString *_Nullable)creativeId {
    [self loadWithCampaignId:campaignId creativeId:creativeId dspCreativeId:nil dspRegion:nil];
}

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId
                creativeId:(NSString *_Nullable)creativeId
             dspCreativeId:(NSString *_Nullable)dspCreativeId
                 dspRegion:(NSString *_Nullable)dspRegion {
    CGSize defaultThumbnailSize = CGSizeMake(OGAThumbnailDefaultWidth, OGAThumbnailDefaultHeight);
    [self loadWithCampaignId:campaignId creativeId:creativeId dspCreativeId:dspCreativeId dspRegion:dspRegion thumbnailSize:defaultThumbnailSize];
}

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId
                creativeId:(NSString *_Nullable)creativeId
             dspCreativeId:(NSString *_Nullable)dspCreativeId
                 dspRegion:(NSString *_Nullable)dspRegion
             thumbnailSize:(CGSize)thumbnailSize {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:self.configuration
                                                 logType:OguryLogTypeInternal
                                                 message:@"loadWithCampaignId... called:"
                                                    tags:@[
                                                        [OguryLogTag tagWithKey:@"DspCreative"
                                                                          value:dspCreativeId == nil ? @"" : dspCreativeId],
                                                        [OguryLogTag tagWithKey:@"DspRegion"
                                                                          value:dspRegion == nil ? @"" : dspRegion],
                                                        [OguryLogTag tagWithKey:@"Size"
                                                                          value:[NSString stringWithFormat:@"w:%f h:%f", thumbnailSize.width, thumbnailSize.height]]
                                                    ]]];
    self.configuration.size = thumbnailSize;
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

- (BOOL)isLoaded {
    return [self.adManager isLoaded:self.sequence];
}

- (void)show {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:self.configuration
                                                 logType:OguryLogTypeInternal
                                                 message:@"show"
                                                    tags:nil]];

    OguryOffset offset = OguryOffsetMake(OGAThumbnailDefaultXOffset, OGAThumbnailDefaultYOffset);
    [self showWithOguryRectCorner:OguryAdsThumbnailDefaultConer margin:offset];
}

- (void)show:(CGPoint)position {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:self.configuration
                                                 logType:OguryLogTypeInternal
                                                 message:@"show"
                                                    tags:@[ [OguryLogTag tagWithKey:@"Position" value:[NSString stringWithFormat:@"x:%f y:%f", position.x, position.y]] ]]];

    [self showWithOguryRectCorner:OguryRectCornerTopLeft margin:OguryOffsetMake(position.x, position.y)];
}

- (void)showWithOguryRectCorner:(OguryRectCorner)rectCorner margin:(OguryOffset)offset {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:self.configuration
                                                 logType:OguryLogTypeInternal
                                                 message:@"show"
                                                    tags:@[
                                                        [OguryLogTag tagWithKey:@"Corner"
                                                                          value:[NSString stringWithFormat:@"%ld", (long)rectCorner]],
                                                        [OguryLogTag tagWithKey:@"Offset"
                                                                          value:[NSString stringWithFormat:@"x:%f y:%f", offset.x, offset.y]]
                                                    ]]];

    if (self.sequence == nil) {
        self.sequence = [[OGAAdSequence alloc] initWithAdConfiguration:self.configuration];
    }
    self.sequence.configuration.corner = rectCorner;
    self.sequence.configuration.offset = offset;
    if (@available(iOS 13.0, *)) {
        if (self.scene) {
            self.sequence.configuration.scene = self.scene;
        }
    }
    [self.adManager show:self.sequence additionalConditions:@[ self.anotherAdOfSameTypeAlreadyDisplayedChecker ]];
}

- (void)setBlacklistViewControllers:(NSArray<NSString *> *_Nullable)viewControllers {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:self.configuration
                                                 logType:OguryLogTypeInternal
                                                 message:@"blacklist controllers"
                                                    tags:@[ [OguryLogTag tagWithKey:@"Controllers" value:viewControllers] ]]];

    self.configuration.blackListViewControllers = viewControllers;
    if (self.sequence) {
        self.sequence.configuration.blackListViewControllers = viewControllers;
    }
}

- (void)setWhitelistBundleIdentifiers:(NSArray<NSString *> *_Nullable)bundleIdentifiers {
    [self.log log:[[OGAAdLogMessage alloc] initWithLevel:OguryLogLevelDebug
                                         adConfiguration:self.configuration
                                                 logType:OguryLogTypeInternal
                                                 message:@"whitelist bundles"
                                                    tags:@[ [OguryLogTag tagWithKey:@"bundleIdentifiers" value:bundleIdentifiers] ]]];

    self.configuration.whitelistBundleIdentifiers = bundleIdentifiers;
    if (self.sequence) {
        self.sequence.configuration.whitelistBundleIdentifiers = bundleIdentifiers;
    }
}

- (void)setLogOrigin:(NSString *)origin {
    [self.configuration setLogOrigin:origin];
}

- (OGAAdConfiguration *)adConfiguration {
    return self.configuration;
}

@end
