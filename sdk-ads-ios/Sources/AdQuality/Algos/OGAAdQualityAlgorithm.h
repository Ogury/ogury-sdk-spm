//
//  OGAAdQualityAlgorithm.h
//  OguryAds
//
//  Created by Jerome TONNELIER on 26/08/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGAAdConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *OguryAdQualityAlgorithm NS_TYPED_EXTENSIBLE_ENUM;
extern OguryAdQualityAlgorithm const OguryAdQualityAlgorithmUniformColorRect;
extern NSString *const OguryAdQualityAlgorithmKey;

@interface OGAAdQualityResult : NSObject
@property(nonatomic, retain) OguryAdQualityAlgorithm algo;
@property(nonatomic) BOOL success;
@property(nonatomic, retain) NSError *_Nullable error;
@property(nonatomic, retain) NSNumber *threshold;
@property(nonatomic, retain) NSNumber *duration;
@property(nonatomic, retain) NSNumber *devianceMax;
@end

typedef void (^AdQualityAlgorithmCompletionBlock)(OGAAdQualityResult *_Nullable result);

@protocol OGAAdQualityAlgorithm <NSObject>
@property(nonatomic, retain) OguryAdQualityAlgorithm algo;
@property(nonatomic, retain) NSArray<NSString *> *allowedFormats;
@property(nonatomic, retain) NSNumber *duration;
@property(nonatomic) BOOL isCancelled;
- (BOOL)computationEnabledFor:(OGAAdConfiguration *)adConfiguration;
- (void)performAdQualityCheckOn:(UIView *)view adConfiguration:(OGAAdConfiguration *)adConfiguration completion:(AdQualityAlgorithmCompletionBlock)completion;
@end

NS_ASSUME_NONNULL_END
