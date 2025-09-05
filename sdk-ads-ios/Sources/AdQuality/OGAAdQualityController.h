//
//  OGAAdQualityController.h
//  OguryAds
//
//  Created by Jerome TONNELIER on 25/08/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGAAdQualityAlgorithm.h"
#import "OGAAdConfiguration.h"
#import "OGAAdQualityConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdQualityController : NSObject
typedef void (^AdQualityCompletionBlock)(NSArray<OGAAdQualityResult *> *results);
+ (instancetype)shared;
// from config reset
- (void)reset;
- (void)setUpFrom:(OGAAdQualityConfiguration *)configuration;
- (void)performAdQualityChecksOn:(UIView *)view adConfiguration:(OGAAdConfiguration *)adConfiguration completion:(AdQualityCompletionBlock _Nullable)completion;
- (void)performAdQualityChecksOn:(UIView *)view adConfiguration:(OGAAdConfiguration *)adConfiguration;
@end

NS_ASSUME_NONNULL_END
