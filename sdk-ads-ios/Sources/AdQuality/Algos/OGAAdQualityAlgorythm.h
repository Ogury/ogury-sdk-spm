//
//  OGAAdQualityAlgorythm.h
//  OguryAds
//
//  Created by Jerome TONNELIER on 26/08/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGAAdConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *OguryAdQualityAlgorythm NS_TYPED_EXTENSIBLE_ENUM;
extern OguryAdQualityAlgorythm const OguryAdQualityAlgorythmUniformColorRect;
extern NSString * const OguryAdQualityAlgorythmKey;

@interface OGAAdQualityResult: NSObject
@property (nonatomic, retain) OguryAdQualityAlgorythm algo;
@property (nonatomic) BOOL sucess;
@property (nonatomic, retain) NSError *_Nullable error;
@property (nonatomic, retain) NSNumber* threshold;
@property (nonatomic, retain) NSNumber* duration;
@end

typedef void (^AdQualityAlgorythmCompletionBlock)(OGAAdQualityResult *result);

@protocol OGAAdQualityAlgorythm <NSObject>
@property (nonatomic, retain) OguryAdQualityAlgorythm algo;
@property (nonatomic, retain) NSNumber* duration;
- (void)performAdQualityCheckOn:(UIView *)view adConfiguration:(OGAAdConfiguration *)adConfiguration completion:(AdQualityAlgorythmCompletionBlock)completion;
@end

NS_ASSUME_NONNULL_END
