//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdConfiguration.h"
#import "OGAMonitoringConstants.h"
#import "OGAOrderedDictionary.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark OGAMonitoringDispatcher Interface

@interface OGAMonitoringDispatcher : NSObject

+ (instancetype)shared;

- (void)setBlackListedTracks:(NSArray<NSString *> *_Nullable)blackListedTracks;

- (void)setTrackingMask:(OGATrackingMask)trackingMask;

- (void)didReceiveEnvironmentChange:(NSNotification *)notification;

#pragma mark - Load Event

- (void)sendLoadEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration details:(NSDictionary *_Nullable)details;
- (void)sendLoadEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration;

- (void)sendLoadErrorEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration;
- (void)sendLoadErrorEvent:(OGAMonitoringEvent)event
           adConfiguration:(OGAAdConfiguration *)adConfiguration
           customSessionId:(NSString *_Nullable)sessionId;

- (void)sendLoadAdErrorEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration;
- (void)sendLoadErrorEvent:(OGAMonitoringEvent)event
           adConfiguration:(OGAAdConfiguration *)adConfiguration
              errorContent:(OGAOrderedDictionary *_Nullable)errorContent;

- (void)sendLoadErrorEvent:(OGAMonitoringEvent)event
                stackTrace:(NSString *)stacktrace
           adConfiguration:(OGAAdConfiguration *)adConfiguration;

- (void)sendLoadErrorEventParsingFailWithStackTrace:(NSString *)stacktrace
                                    adConfiguration:(OGAAdConfiguration *)adConfiguration;

- (void)sendLoadErrorEventPrecacheFail:(OGAMonitoringPrecacheError)precacheErrorType
                       adConfiguration:(OGAAdConfiguration *)adConfiguration;
- (void)sendLoadErrorEventPrecacheFail:(OGAMonitoringPrecacheError)precacheErrorType
                       adConfiguration:(OGAAdConfiguration *)adConfiguration
                             arguments:(NSArray *_Nullable)args;

#pragma mark - Show Event

- (void)sendShowEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration;

- (void)sendAdQualityEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration details:(OGAOrderedDictionary *_Nonnull)details;

- (void)sendShowEventAllDisplayed:(NSString *)impressionSrc adConfiguration:(OGAAdConfiguration *)adConfiguration;

- (void)sendShowEventShowCalledWithNbAdsToShow:(NSNumber *)nbAdsToShow adConfiguration:(OGAAdConfiguration *)adConfiguration;

- (void)sendShowEventShowCalledWithNbAdsToShow:(NSNumber *)nbAdsToShow adConfiguration:(OGAAdConfiguration *)adConfiguration customSessionId:(NSString *_Nullable)sessionId;

- (void)sendShowEventDisplay:(NSNumber *)nbAdsToExpose adConfiguration:(OGAAdConfiguration *)adConfiguration;

- (void)sendShowEventForImpressionSource:(NSString *)impressionSrc position:(NSNumber *)order adConfiguration:(OGAAdConfiguration *)adConfiguration;

- (void)sendShowEvent:(OGAMonitoringEvent)event impressionSource:(NSString *)impressionSrc adConfiguration:(OGAAdConfiguration *)adConfiguration;

- (void)sendShowEventContainerDisplayedWithImpressionSource:(NSString *)impressionSrc exposure:(NSNumber *)exposure adConfiguration:(OGAAdConfiguration *)adConfiguration;

- (void)sendShowErrorEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration;

- (void)sendShowErrorEvent:(OGAMonitoringEvent)event adConfiguration:(OGAAdConfiguration *)adConfiguration customSessionId:(NSString *_Nullable)sessionId;

- (void)sendShowErrorEventAdExpired:(OGAAdConfiguration *)adConfiguration context:(OGAExpirationContext *)expirationContext;

@end

NS_ASSUME_NONNULL_END
