//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OguryConfiguration.h"
#import "OGWMonitoringInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryConfiguration (Private)

#pragma mark - Properties

@property (nonatomic, strong, readonly) OGWMonitoringInfo *monitoringInfo;

#pragma mark - Initialization

- (instancetype)initWithAssetKey:(NSString *)assetKey monitoringInfo:(OGWMonitoringInfo *)monitoringInfo;

@end

NS_ASSUME_NONNULL_END
