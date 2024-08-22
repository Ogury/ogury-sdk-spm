//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OguryConfigurationPrivate.h"
#import "OguryConfigurationBuilder.h"

@interface OguryConfigurationBuilder ()

@property (nonatomic, copy) NSString *assetKey;

@end

@implementation OguryConfigurationBuilder

#pragma mark - Initialization

- (instancetype)initWithAssetKey:(NSString *)assetKey {
    if (self = [super init]) {
        _assetKey = assetKey;
    }
    return self;
}

#pragma mark - Methods

- (OguryConfiguration *)build {
    return [[OguryConfiguration alloc] initWithAssetKey:self.assetKey];
}

@end
