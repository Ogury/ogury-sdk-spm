//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGABannerAdViewInternalAPI.h"
#import "OGAAdSequence.h"
#import "OguryBannerAdViewDelegate.h"
#import "OGAInternal.h"

@class OGAMonitoringDispatcher;

NS_ASSUME_NONNULL_BEGIN

@interface OGABannerAdViewInternalAPI (Testing) <OguryBannerAdViewDelegate>

@property(nonatomic, strong) OGAAdSequence *sequence;
@property(nonatomic, strong) OGAAdConfiguration *configuration;
@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) OguryBannerAdSize *size;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                      bannerView:(UIView *_Nullable)bannerView
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       adManager:(OGAAdManager *)adManager;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                      bannerView:(UIView *_Nullable)bannerView
                            size:(OguryBannerAdSize *)size
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       adManager:(OGAAdManager *)adManager
              notificationCenter:(NSNotificationCenter *)notificationCenter
            monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                        internal:(OGAInternal *)internal
                       mediation:(OguryMediation *_Nullable)mediation
                             log:(OGALog *)log;

- (void)didMoveToWindow;

@end

NS_ASSUME_NONNULL_END
