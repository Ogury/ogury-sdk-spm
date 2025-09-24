//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OgurySdk/OguryStartErrorCode.h>
#import <OguryCore/OguryLogLevel.h>
#import <OguryCore/OguryError.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^StartCompletionBlock)(BOOL success, OguryError * _Nullable error);

@interface Ogury : NSObject

+ (void)startWith:(NSString *)assetKey;

+ (void)startWith:(NSString *)assetKey completionHandler:(StartCompletionBlock _Nullable)completionHandler;

+ (void)setLogLevel:(OguryLogLevel)logLevel;

+ (NSString *)sdkVersion;

+ (void)registerAttributionForSKAdNetwork;

+ (void)setPrivacyData:(NSString *)key boolean:(BOOL)value;

+ (void)setPrivacyData:(NSString *)key integer:(NSInteger)value;

+ (void)setPrivacyData:(NSString *)key string:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
