//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGATokenGenerator.h"
#import "OGAInternal.h"
#import "OGAAssetKeyManager.h"
#import "OGADeviceService.h"
#import "OGAProfigManager.h"
#import "OGAProfigDao.h"
#import "OGAOMIDService.h"
#import "OGADevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGATokenGenerator (Testing)

@property(nonatomic, strong) OGAAssetKeyManager *assetKeyManager;
@property(nonatomic, strong) OGAInternal *internal;
@property(nonatomic, strong) OGADeviceService *deviceService;

- (instancetype)init:(OGAAssetKeyManager *)assetKeyManager
            internal:(OGAInternal *)internal
       deviceService:(OGADeviceService *)deviceService
       profigManager:(OGAProfigManager *)profigManager
           profigDao:(OGAProfigDao *)profigDao
         omidService:(OGAOMIDService *)omidService;

- (NSString *)generateBidderToken;

- (NSDictionary *)collectBidderTokenData;

- (OGADevice *)currentDevice;

@end

NS_ASSUME_NONNULL_END
