//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryLogLevel.h>
#import <OguryAds/OguryAds.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^StartCompletionBlock)(BOOL success, OguryError *_Nullable error);

@interface OGAInternal : NSObject

#pragma mark - Class methods

+ (instancetype)shared;

#pragma mark - methods

- (void)startWith:(NSString *)assetKey completionHandler:(StartCompletionBlock)completionHandler;
- (void)setLogLevel:(OguryLogLevel)logLevel;
- (NSString *)getVersion;
- (NSString *)getBuildVersion;
- (void)defineSDKType:(NSUInteger)sdkType;
- (void)defineMediationName:(NSString *)mediationName;
- (BOOL)sdkInitialized;

@end

NS_ASSUME_NONNULL_END
