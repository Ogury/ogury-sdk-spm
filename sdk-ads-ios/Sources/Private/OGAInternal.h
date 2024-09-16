//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryLog.h>
#import <OguryAds/OguryAds.h>
#import <OguryAds/OGALogType.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAInternal : NSObject

#pragma mark - Class methods

+ (instancetype)shared;

#pragma mark - methods

- (void)startWithAssetKey:(NSString *)assetKey completionHandler:(SetUpCompletionBlock __nullable)completionHandler;
- (void)startWithAssetKey:(NSString *)assetKey;
- (void)setLogLevel:(OguryLogLevel)logLevel;
- (void)addLogger:(id<OguryAdsLogger>)logger;
- (NSString *)getVersion;
- (NSString *)getBuildVersion;
- (void)defineSDKType:(NSUInteger)sdkType;
- (void)defineMediationName:(NSString *)mediationName;
- (BOOL)sdkInitialized;

@end

NS_ASSUME_NONNULL_END
