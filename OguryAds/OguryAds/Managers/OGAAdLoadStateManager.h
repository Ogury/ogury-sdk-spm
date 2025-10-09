//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAMRAIDWebViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class OGAAd;

#pragma mark - LoadedSource ENUM
typedef NS_ENUM(NSUInteger, LoadedSource) {
    LoadedSourceFormat,
    LoadedSourceSDK
};

typedef NS_OPTIONS(NSUInteger, AdLoadingState) {
    AdLoadingStateIdle = (1 << 0),
    AdLoadingStateConnect = (1 << 1),
    AdLoadingStateWebviewReady = (1 << 2),
    AdLoadingStateFormatReady = (1 << 3),
    AdLoadingStateTimeOut = (1 << 4)
};

@protocol OGAAdLoadStateManagerDelegate
- (void)adIsFullyLoaded;
@end

@protocol OGAAdLoadStateManagerErrorDelegate
- (void)loadTimedOut;
@end

@interface OGAAdLoadStateManager : NSObject

@property(nonatomic) BOOL mraidEnvironmentIsUp;
@property(nonatomic) BOOL webViewLoaded;
@property(nonatomic) BOOL formatLoaded;
@property(nonatomic) BOOL webviewReadyToLoad;
@property(nonatomic, weak) id<OGAAdLoadStateManagerDelegate> stateDelegate;
@property(nonatomic, weak) id<OGAAdLoadStateManagerErrorDelegate> commandDelegate;
@property(nonatomic, weak) id<OGAMRAIDWebViewDelegate> webViewDelegate;

- (instancetype)initWithAd:(OGAAd *)ad
                   timeout:(NSNumber *)timeOut
               webDelegate:(id<OGAMRAIDWebViewDelegate>)webDelegate
             errorDelegate:(id<OGAAdLoadStateManagerErrorDelegate>)commandDelegate;
- (BOOL)webViewLoaded:(NSString *)webViewId;
- (void)invalidateTimer;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
