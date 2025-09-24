//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAThumbnailAdInternalAPI.h"
#import "OGAAdSequence.h"
#import "OGAInternetConnectionChecker.h"
#import "OGAAnotherAdOfSameTypeAlreadyDisplayedChecker.h"
#import "OGAMonitoringDispatcher.h"
#import "OGAInternal.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAThumbnailAdInternalAPI (Testing)

@property(nonatomic, strong, nullable) OGAAdSequence *sequence;
@property(nonatomic, strong) OGAAdConfiguration *configuration;
@property(nonatomic, strong) OGAAdManager *adManager;

@property(nonatomic, weak) UIViewController *viewController;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                            delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                                     adManager:(OGAAdManager *)adManager
                     internetConnectionChecker:(OGAInternetConnectionChecker *)internetConnectionChecker
    anotherAdOfSameTypeAlreadyDisplayedChecker:(OGAAnotherAdOfSameTypeAlreadyDisplayedChecker *)anotherAdOfSameTypeAlreadyDisplayedChecker
                          monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                                      internal:(OGAInternal *)internal
                                     mediation:(OguryMediation *_Nullable)mediation
                                           log:(OGALog *)log;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId;

- (void)loadWithCampaignId:(NSString *_Nullable)campaignId thumbnailSize:(CGSize)thumbnailSize;

@end

NS_ASSUME_NONNULL_END
