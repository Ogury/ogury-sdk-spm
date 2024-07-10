//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryPersistentEventBus.h>
#import <OguryCore/OguryLogLevel.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAInternal : NSObject

#pragma mark - Class methods

+ (instancetype)shared;

#pragma mark - methods

- (void)startWithAssetKey:(NSString *)assetKey
       persistentEventBus:(OguryPersistentEventBus *_Nullable)persistentEventBus
        broadcastEventBus:(OguryEventBus *_Nullable)broadcastEventBus;

- (void)setLogLevel:(OguryLogLevel)logLevel;
- (NSString *)getVersion;
- (NSString *)getBuildVersion;
- (void)defineSDKType:(NSUInteger)sdkType;
- (void)defineMediationName:(NSString *)mediationName;
- (BOOL)sdkInitialized;

@end

NS_ASSUME_NONNULL_END
