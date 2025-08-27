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

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdQualityController : NSObject
typedef void (^AdQualityCompletionBlock)(NSArray<OGAAdQualityResult *> *results);
+ (instancetype)shared;

@property(nonatomic) BOOL isEnabled;
@property(nonatomic, retain) NSArray<id<OGAAdQualityAlgorithm>> *activeAlgorithms;

- (void)performAdQualityChecksOn:(UIView *)view adConfiguration:(OGAAdConfiguration *)adConfiguration completion:(AdQualityCompletionBlock _Nullable)completion;
- (void)performAdQualityChecksOn:(UIView *)view adConfiguration:(OGAAdConfiguration *)adConfiguration;
@end

NS_ASSUME_NONNULL_END
