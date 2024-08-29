//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAssetKeyManager.h"
#import "OguryAdsError.h"
#import "OGALog.h"
#import "OGAUserDefaultsStore.h"
#import "OguryAdsError+Internal.h"

@interface OGAAssetKeyManager ()

@property(nonatomic, assign) BOOL assetKeyHasBeenSet;
@property(nonatomic, copy, readwrite, nullable) NSString *assetKey;
@property(nonatomic, strong) OGALog *log;
@property(nonatomic) OgurySDKState sdkState;
@property(nonatomic, strong) OGAUserDefaultsStore *userDefaultsStore;

@end

@implementation OGAAssetKeyManager

NSString *const OGAssetKeyStoreKey = @"OGAssetKeyStoreKey";

#pragma mark - Initialization

- (instancetype)init {
    return [self init:[OGALog shared] userDefaultsStore:[OGAUserDefaultsStore shared]];
}

- (instancetype)init:(OGALog *)log
    userDefaultsStore:(OGAUserDefaultsStore *)userDefaultsStore {
    if (self = [super init]) {
        _assetKeyHasBeenSet = NO;
        _log = log;
        _sdkState = OgurySDKStateIdle;
        _userDefaultsStore = userDefaultsStore;
    }
    return self;
}

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static OGAAssetKeyManager *instance = nil;

    dispatch_once(&onceToken, ^{
        NSLog(@"%p", &onceToken);
        instance = [[self alloc] init];
    });

    return instance;
}

#pragma mark - Methods

- (NSString *)assetKey {
    return _assetKey != NULL ? _assetKey : [self.userDefaultsStore stringForKey:OGAssetKeyStoreKey];
    ;
}

- (void)setSdkState:(OgurySDKState)sdkState {
    _sdkState = sdkState;
    if ([self.delegate respondsToSelector:@selector(didSDKStatusChange)]) {
        [self.delegate didSDKStatusChange];
    }
}

- (BOOL)configureAssetKey:(NSString *)assetKey {
    if (!self.assetKeyHasBeenSet) {
        self.sdkState = OgurySDKStateStarting;
        self.assetKey = assetKey;
        [self.userDefaultsStore setObject:assetKey forKey:OGAssetKeyStoreKey];
        self.assetKeyHasBeenSet = YES;
        return YES;
    }
    return NO;
}

/// the SDK should be reset if a previous set has been done and the assetKey id different
- (BOOL)shouldResetSDKFor:(NSString *)assetKey {
    return self.assetKeyHasBeenSet && ![assetKey isEqual:self.assetKey];
}

- (void)sdkIsReady {
    // check previous state because Profig can be synced without calling the start method
    if (self.sdkState == OgurySDKStateStarting) {
        self.sdkState = OgurySDKStateReady;
    }
}

- (void)sdkStartFailed {
    self.sdkState = OgurySDKStateError;
}

- (BOOL)checkAssetKeyIsValid:(OguryError *_Nullable *_Nullable)error origin:(OguryInternalAdsErrorOrigin)origin {
    if (!self.assetKeyHasBeenSet) {
        if (error) {
            *error = [OguryAdsError sdkNotInitializedFrom:origin stackTrace:@"AssetKey not found"];
        }

        [self.log log:OguryLogLevelError message:@"[setup] Asset key has not been set"];
        self.sdkState = OgurySDKStateError;
        return NO;
    }

    if (!self.assetKey || [self.assetKey isEqualToString:@""]) {
        if (error) {
            *error = [OguryAdsError sdkNotInitializedFrom:origin stackTrace:@"invalid AssetKey"];
        }
        self.sdkState = OgurySDKStateError;
        return NO;
    }

    return YES;
}

- (void)reset {
    self.assetKey = nil;
    self.assetKeyHasBeenSet = NO;
    self.sdkState = OgurySDKStateIdle;
}

@end
