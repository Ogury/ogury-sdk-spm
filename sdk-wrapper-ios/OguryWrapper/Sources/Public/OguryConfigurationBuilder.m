//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OguryConfigurationPrivate.h"
#import "OguryConfigurationBuilder.h"

@interface OguryConfigurationBuilder ()

@property (nonatomic, copy) NSString *assetKey;

@property (nonatomic, strong) OGWMonitoringInfo *monitoringInfo;

@end

@implementation OguryConfigurationBuilder

#pragma mark - Initialization

- (instancetype)initWithAssetKey:(NSString *)assetKey {
    if (self = [super init]) {
        _assetKey = assetKey;
        _monitoringInfo = [[OGWMonitoringInfo alloc] init];
    }
    return self;
}

#pragma mark - Methods

- (void)putMonitoringInfo:(NSString *)monitoringInfoKey value:(NSString *)value {
    [self.monitoringInfo putValue:value key:monitoringInfoKey];
}

- (OguryConfiguration *)build {
    return [[OguryConfiguration alloc] initWithAssetKey:self.assetKey
                                         monitoringInfo:self.monitoringInfo];
}

@end
