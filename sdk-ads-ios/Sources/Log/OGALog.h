//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryLogLevel.h>
#import "OGAAdConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGALog : NSObject

#pragma mark - Methods

+ (instancetype)shared;

- (void)setLogLevel:(OguryLogLevel)logLevel;

- (void)log:(OguryLogLevel)logLevel message:(NSString *)message;

- (void)logFormat:(OguryLogLevel)logLevel format:(NSString *)format, ...;

- (void)logError:(NSError *)error message:(NSString *)message;

- (void)logErrorFormat:(NSError *)error format:(NSString *)format, ...;

- (void)logAd:(OguryLogLevel)logLevel forAdConfiguration:(OGAAdConfiguration *)adConfiguration message:(NSString *)message;

- (void)logAdFormat:(OguryLogLevel)logLevel forAdConfiguration:(OGAAdConfiguration *)adConfiguration format:(NSString *)format, ...;

- (void)logAdError:(NSError *)error
    forAdConfiguration:(OGAAdConfiguration *)adConfiguration
               message:(NSString *)message;

- (void)logAdErrorFormat:(NSError *)error
      forAdConfiguration:(OGAAdConfiguration *)adConfiguration
                  format:(NSString *)format, ...;

- (void)logMraid:(OguryLogLevel)logLevel
    forAdConfiguration:(OGAAdConfiguration *)adConfiguration
             webViewId:(NSString *)webViewId
               message:(NSString *)message;

- (void)logMraidFormat:(OguryLogLevel)logLevel
    forAdConfiguration:(OGAAdConfiguration *)adConfiguration
             webViewId:(NSString *)webViewId
                format:(NSString *)format, ...;

- (void)logMraidError:(NSError *)error
    forAdConfiguration:(OGAAdConfiguration *)adConfiguration
             webViewId:(NSString *)webViewId
               message:(NSString *)message;

- (void)logMraidErrorFormat:(NSError *)error
         forAdConfiguration:(OGAAdConfiguration *)adConfiguration
                  webViewId:(NSString *)webViewId
                     format:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
