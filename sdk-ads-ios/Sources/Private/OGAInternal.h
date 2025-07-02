//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryLog.h>
#import <OguryAds/OguryAds.h>
#import <OguryAds/OGAAdLogMessage.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^StartCompletionBlock)(BOOL success, OguryError *_Nullable error);

@interface OGAInternal : NSObject

#pragma mark - Class methods

+ (instancetype)shared;

#pragma mark - methods

- (void)startWith:(NSString *)assetKey completionHandler:(StartCompletionBlock)completionHandler;
- (void)setLogLevel:(OguryLogLevel)logLevel;
- (void)addLogger:(id<OguryLogger>)logger;
- (void)removeLogger:(id<OguryLogger>)logger;
- (NSString *)getVersion;
- (NSString *)getBuildVersion;
- (void)defineSDKType:(NSUInteger)sdkType;
- (void)defineMediationName:(NSString *)mediationName;
- (BOOL)sdkInitialized;

@end

NS_ASSUME_NONNULL_END
