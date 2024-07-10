//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OguryAds.h"

#import "OGAInternal+Private.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface OguryAds ()

@property(nonatomic, strong) OGAInternal *internal;
@property(nonatomic, copy) SetupCompletionBlock setupBlock;

@end

@implementation OguryAds

#pragma mark - Class methods

+ (instancetype)shared {
    static OguryAds *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[OguryAds alloc] init];
    });
    return instance;
}

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithInternal:[OGAInternal shared]];
}

- (instancetype)initWithInternal:(OGAInternal *)internal {
    if (self = [super init]) {
        _internal = internal;
    }
    return self;
}

#pragma mark - Methods

- (NSString *)sdkVersion {
    return [self.internal getVersion];
}

- (void)setupWithAssetKey:(NSString *)assetKey
         andMediationName:(NSString *)mediationName {
    [self.internal startWithAssetKey:assetKey persistentEventBus:nil broadcastEventBus:nil];
}

- (void)setupWithAssetKey:(NSString *)assetKey
            mediationName:(NSString *)mediationName
     andCompletionHandler:(SetupCompletionBlock)completionHandler {
    [self.internal startWithAssetKey:assetKey persistentEventBus:nil broadcastEventBus:nil];
    if (completionHandler) {
        completionHandler(nil);
    }
}

- (void)setupWithAssetKey:(NSString *)assetKey
     andCompletionHandler:(SetupCompletionBlock)completionHandler {
    [self.internal startWithAssetKey:assetKey persistentEventBus:nil broadcastEventBus:nil];
    if (completionHandler) {
        completionHandler(nil);
    }
}

- (void)setupWithAssetKey:(NSString *)assetKey {
    [self.internal startWithAssetKey:assetKey persistentEventBus:nil broadcastEventBus:nil];
}

- (void)defineSDKType:(NSUInteger)sdkType {
    [self.internal defineSDKType:sdkType];
}

- (void)defineMediationName:(NSString *)mediationName {
    [self.internal defineMediationName:mediationName];
}

- (void)resetSDK {
    [self.internal resetSDK];
}

@end

#pragma clang diagnostic pop
