//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OguryConfigurationPrivate.h"

@interface OguryConfiguration ()

@property (nonatomic, copy, readwrite) NSString *assetKey;

@end

@implementation OguryConfiguration

- (instancetype)initWithAssetKey:(NSString *)assetKey {
    if (self = [super init]) {
        _assetKey = assetKey;
    }
    return self;
}

@end
