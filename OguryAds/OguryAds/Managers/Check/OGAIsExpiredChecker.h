//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAConditionChecker.h"
#import "OGAAdManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAIsExpiredChecker : NSObject <OGAConditionChecker>

#pragma mark - Properties

@property(nonatomic, weak, nullable) OGAAdManager *adManager;

#pragma mark - Initialization

- (instancetype)initWithAdManager:(OGAAdManager *)adManager;

@end

NS_ASSUME_NONNULL_END
