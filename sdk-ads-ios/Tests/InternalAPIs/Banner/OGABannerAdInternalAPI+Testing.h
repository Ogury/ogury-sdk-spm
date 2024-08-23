//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGABannerAdInternalAPI.h"
#import "OGAAdSequence.h"
#import "OguryBannerAdDelegate.h"
#import "OGAInternal.h"

@class OGAMonitoringDispatcher;

NS_ASSUME_NONNULL_BEGIN

@interface OGABannerAdInternalAPI (Testing) <OguryBannerAdDelegate>

@property(nonatomic, strong) OGAAdSequence *sequence;
@property(nonatomic, strong) OGAAdConfiguration *configuration;
@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) OguryAdsBannerSize *size;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                      bannerView:(UIView *_Nullable)bannerView
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       adManager:(OGAAdManager *)adManager;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                      bannerView:(UIView *_Nullable)bannerView
                            size:(OguryAdsBannerSize *)size
              delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                       adManager:(OGAAdManager *)adManager
              notificationCenter:(NSNotificationCenter *)notificationCenter
            monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                        internal:(OGAInternal *)internal
                       mediation:(OguryMediation *_Nullable)mediation
                             log:(OGALog *)log;

- (void)showBannerIfLoaded;

- (void)didMoveToWindow;

- (BOOL)haveParentViewcontroller;

@end

NS_ASSUME_NONNULL_END
