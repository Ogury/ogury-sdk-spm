//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OguryCore/OguryError.h>
#include "OGAAssetKeyManagerDelegate.h"
#import "OguryAdError.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAssetKeyManager : NSObject

typedef NS_ENUM(NSInteger, OgurySDKState) {
    OgurySDKStateIdle,
    OgurySDKStateStarting,
    OgurySDKStateReady,
    OgurySDKStateError
};

#pragma mark - Properties

@property(nonatomic, copy, readonly, nullable) NSString *assetKey;
@property(nonatomic, weak) id<OGAAssetKeyManagerDelegate> delegate;

#pragma mark - Methods

+ (instancetype)shared;

- (BOOL)configureAssetKey:(NSString *_Nullable)assetKey;

- (BOOL)checkAssetKeyIsValid:(OguryError *_Nullable *_Nullable)error type:(OguryAdErrorType)type;

- (void)reset;

/// Return YES if the assetKey has change and was previously set
/// - Parameter assetKey: the assetKey to test against
- (BOOL)shouldResetSDKFor:(NSString *)assetKey;

- (OgurySDKState)sdkState;

- (void)setSdkState:(OgurySDKState)sdkState;

@end

NS_ASSUME_NONNULL_END
