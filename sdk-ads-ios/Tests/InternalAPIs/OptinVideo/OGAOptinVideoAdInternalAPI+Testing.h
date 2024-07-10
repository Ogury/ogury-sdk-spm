//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import "OGAOptinVideoAdInternalAPI.h"

#import "OGAAdSequence.h"
#import "OGAAdManager.h"
#import "OGAAnotherAdInFullScreenOverlayStateChecker.h"
#import "OGAInternetConnectionChecker.h"
#import "OGAInternal.h"

NS_ASSUME_NONNULL_BEGIN

@class OGAMonitoringDispatcher;

@interface OGAOptinVideoAdInternalAPI (Testing)

@property(nonatomic, strong) OGAAdSequence *sequence;
@property(nonatomic, strong) OGAAdConfiguration *configuration;
@property(nonatomic, strong) OGAAdManager *adManager;
@property(nonatomic, strong) OGADelegateDispatcher *delegateDispatcher;

@property(nonatomic, weak) UIViewController *viewController;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
                          delegateDispatcher:(OGADelegateDispatcher *)delegateDispatcher
                                   adManager:(OGAAdManager *)adManager
                   internetConnectionChecker:(OGAInternetConnectionChecker *)internetConnectionChecker
    anotherAdInFullScreenOverlayStateChecker:(OGAAnotherAdInFullScreenOverlayStateChecker *)anotherAdInOverlayStateChecker
                        monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher
                                    internal:(OGAInternal *)internal
                                   mediation:(OguryMediation *_Nullable)mediation
                                         log:(OGALog *)log;

@end

NS_ASSUME_NONNULL_END
