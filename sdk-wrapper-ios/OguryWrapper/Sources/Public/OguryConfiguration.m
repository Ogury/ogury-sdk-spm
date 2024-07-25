//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OguryConfigurationPrivate.h"

@interface OguryConfiguration ()

@property (nonatomic, copy, readwrite) NSString *assetKey;
@property (nonatomic, strong, readwrite) OGWMonitoringInfo *monitoringInfo;

@end

@implementation OguryConfiguration

- (instancetype)initWithAssetKey:(NSString *)assetKey monitoringInfo:(OGWMonitoringInfo *)monitoringInfo {
    if (self = [super init]) {
        _assetKey = assetKey;
        _monitoringInfo = monitoringInfo;
    }
    return self;
}

@end
