//
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAConditionChecker.h"
#import "OGAAdManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdEnabledChecker : NSObject <OGAConditionChecker>
@property(nonatomic) OguryInternalAdsErrorOrigin origin;
- (instancetype)initFrom:(OguryInternalAdsErrorOrigin)origin;
@end

NS_ASSUME_NONNULL_END
