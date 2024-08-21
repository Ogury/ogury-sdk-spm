//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OgurySdk/OguryConfiguration.h>
#import <OgurySdk/OguryConfigurationBuilder.h>
#import <OguryCore/OguryLogLevel.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SetupCompletionBlock)(BOOL success, OguryError * _Nullable error);

@interface Ogury : NSObject

+ (void)startWithConfiguration:(OguryConfiguration *)configuration;

+ (void)startWithConfiguration:(OguryConfiguration *)configuration completionHandler:(SetupCompletionBlock _Nullable)completionHandler;

+ (void)setLogLevel:(OguryLogLevel)logLevel;

+ (NSString *)getSdkVersion;

+ (void)registerAttributionForSKAdNetwork;

+ (void)storePrivacyData:(NSString *)key boolean:(BOOL)value;

+ (void)storePrivacyData:(NSString *)key integer:(NSInteger)value;

+ (void)storePrivacyData:(NSString *)key string:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
