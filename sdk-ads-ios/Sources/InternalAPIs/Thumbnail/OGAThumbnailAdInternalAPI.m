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

static OguryRectCorner const OguryAdsThumbnailDefaultConer = OguryBottomRight;

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

- (id<OguryAdsThumbnailAdDelegate>)delegate {
    return self.delegateDispatcher.delegate;
}

- (void)setDelegate:(id<OguryAdsThumbnailAdDelegate>)delegate {
    self.delegateDispatcher.delegate = delegate;
}

- (void)load {
    CGSize defaultThumbnailSize = CGSizeMake(OGAThumbnailDefaultWidth, OGAThumbnailDefaultHeight);
    [self load:defaultThumbnailSize];
}

- (void)load:(CGSize)thumbnailSize {
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
    [self.log logAdFormat:OguryLogLevelDebug forAdConfiguration:self.configuration format:@" loadWithCampaignId called: [campaignId:%@][creativeId:%@][dspCreativeId:%@][dspRegion:%@][thumbnailSize:%dx%d]", campaignId, creativeId, dspCreativeId, dspRegion, thumbnailSize.height, thumbnailSize.width];
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
    [self.log logAdFormat:OguryLogLevelDebug forAdConfiguration:self.configuration format:@"Show called"];

    OguryOffset offset = OguryOffsetMake(OGAThumbnailDefaultXOffset, OGAThumbnailDefaultYOffset);
    [self showWithOguryRectCorner:OguryAdsThumbnailDefaultConer margin:offset];
}

- (void)show:(CGPoint)position {
    [self.log logAdFormat:OguryLogLevelDebug forAdConfiguration:self.configuration format:@"Show called [position:%d x %d]", position.x, position.y];

    [self showWithOguryRectCorner:OguryTopLeft margin:OguryOffsetMake(position.x, position.y)];
}

- (void)showWithOguryRectCorner:(OguryRectCorner)rectCorner margin:(OguryOffset)offset {
    [self.log logAdFormat:OguryLogLevelDebug forAdConfiguration:self.configuration format:@"showWithOguryRectCorner:margin: called [rectCorner:%@][offset:%d x %d]", @(rectCorner), offset.x, offset.y];

    if (self.sequence == nil) {
        self.sequence = [[OGAAdSequence alloc] initWithAdConfiguration:self.configuration];
    }
    self.sequence.configuration.corner = rectCorner;
    self.sequence.configuration.offset = offset;

    [self.adManager show:self.sequence additionalConditions:@[ self.anotherAdOfSameTypeAlreadyDisplayedChecker ]];
}

- (void)showInScene:(UIWindowScene *)scene API_AVAILABLE(ios(13.0)) {
    [self.log logAdFormat:OguryLogLevelDebug forAdConfiguration:self.configuration format:@"showInScene called"];

    OguryOffset offset = OguryOffsetMake(OGAThumbnailDefaultXOffset, OGAThumbnailDefaultYOffset);
    [self showInScene:scene withOguryRectCorner:OguryAdsThumbnailDefaultConer margin:offset];
}

- (void)showInScene:(UIWindowScene *)scene atPosition:(CGPoint)position API_AVAILABLE(ios(13.0)) {
    [self.log logAdFormat:OguryLogLevelDebug forAdConfiguration:self.configuration format:@"showInScene:atPosition called [position:%@]", NSStringFromCGPoint(position)];

    [self showInScene:scene withOguryRectCorner:OguryTopLeft margin:OguryOffsetMake(position.x, position.y)];
}

- (void)showInScene:(UIWindowScene *)scene withOguryRectCorner:(OguryRectCorner)rectCorner margin:(OguryOffset)offset API_AVAILABLE(ios(13.0)) {
    [self.log logAdFormat:OguryLogLevelDebug
        forAdConfiguration:self.configuration
                    format:@" showInScene:withOguryRectCorner:margin called [rectCorner:%@][offset:%d x %d]", @(rectCorner), offset.x, offset.y];

    self.sequence.configuration.scene = scene;
    [self showWithOguryRectCorner:rectCorner margin:offset];
}

- (void)setBlacklistViewControllers:(NSArray<NSString *> *_Nullable)viewControllers {
    [self.log logAdFormat:OguryLogLevelDebug forAdConfiguration:self.configuration format:@"setBlacklistViewControllers: called [viewControllers:%@]", viewControllers];

    self.configuration.blackListViewControllers = viewControllers;
    if (self.sequence) {
        self.sequence.configuration.blackListViewControllers = viewControllers;
    }
}

- (void)setWhitelistBundleIdentifiers:(NSArray<NSString *> *_Nullable)bundleIdentifiers {
    [self.log logAdFormat:OguryLogLevelDebug forAdConfiguration:self.configuration format:@"[thumbnail] setWhitelistBundleIdentifiers: called [bundleIdentifiers:%@]", bundleIdentifiers];

    self.configuration.whitelistBundleIdentifiers = bundleIdentifiers;
    if (self.sequence) {
        self.sequence.configuration.whitelistBundleIdentifiers = bundleIdentifiers;
    }
}

@end
