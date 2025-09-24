//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdConfiguration.h"
#import "OGAAssetKeyManager.h"
#import "OGAProfigDao.h"

@class OGAReachability;
@class OGAProfigDao;

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdConfiguration (AdSync)

#pragma mark - Methods
- (NSDictionary *)payloadForAdSyncWithAssetKeyManager:(OGAAssetKeyManager *)assetKeyManager
                                         reachability:(OGAReachability *)reachability
                                    profigPersistence:(OGAProfigDao *)profigPersistence
                               isOmidFrameworkPresent:(BOOL)isOmidFrameworkPresent;

@end

NS_ASSUME_NONNULL_END
