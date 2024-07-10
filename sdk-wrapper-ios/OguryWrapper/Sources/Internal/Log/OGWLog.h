//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryLogLevel.h>

@class OguryConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface OGWLog : NSObject

#pragma mark - Methods

+ (instancetype)shared;

- (void)setLogLevel:(OguryLogLevel)logLevel;

- (void)log:(OguryLogLevel)logLevel message:(NSString *)message;

- (void)logFormat:(OguryLogLevel)logLevel format:(NSString *)format, ...;

- (void)logError:(NSError *)error message:(NSString *)message;

- (void)logErrorFormat:(NSError *)error format:(NSString *)format, ...;

- (void)logAssetKey:(OguryLogLevel)logLevel assetKey:(NSString *)assetKey message:(NSString *)message;

- (void)logAssetKeyFormat:(OguryLogLevel)logLevel assetKey:(NSString *)assetKey format:(NSString *)format, ...;

- (void)logAssetKeyError:(NSError *)error assetKey:(NSString *)assetKey message:(NSString *)message;

- (void)logAssetKeyErrorFormat:(NSError *)error assetKey:(NSString *)assetKey format:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
