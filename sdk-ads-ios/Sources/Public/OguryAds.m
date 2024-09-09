//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OguryAds.h"

#import "OGAInternal+Private.h"

#pragma clang diagnostic push

@interface OguryAds ()

@property(nonatomic, strong) OGAInternal *internal;
@property(nonatomic, copy) SetUpCompletionBlock setupBlock;

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

- (NSString *)sdkVersion {
    return [self.internal getVersion];
}

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
- (void)setupWithAssetKey:(NSString *)assetKey completionHandler:(SetUpCompletionBlock)completionHandler {
    [self.internal startWithAssetKey:assetKey completionHandler:completionHandler];
}

- (void)setupWithAssetKey:(NSString *)assetKey {
    [self.internal startWithAssetKey:assetKey completionHandler:nil];
}

@end

#pragma clang diagnostic pop
