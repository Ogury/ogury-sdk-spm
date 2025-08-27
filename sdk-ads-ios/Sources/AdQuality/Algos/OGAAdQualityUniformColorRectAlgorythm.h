//
//  OGAAdQualityUniformColorRectAlgorythm.h
//  OguryAds
//
//  Created by Jerome TONNELIER on 26/08/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdQualityAlgorythm.h"

NS_ASSUME_NONNULL_BEGIN

/// OGAAdQualityUniformColorRectAlgorythm will grab a snapshot of `rectSize` centered in the view
/// and check pixel by pixel the standard deviance from a reference pixel (random position)
@interface OGAAdQualityUniformColorRectAlgorythm<OGAAdQualityAlgorythm> : NSObject
/// the size of the centered rect to analyze
@property(nonatomic) CGSize rectSize;
/// the threshold before considering a pixek is different
@property(nonatomic, retain) NSNumber *threshold;
/// start delay before grabing a snapshot, in milliseconds
@property(nonatomic, retain) NSNumber *startDelay;
@property(nonatomic, retain) NSNumber *duration;
@property(nonatomic, retain) OguryAdQualityAlgorythm algo;
@property(nonatomic, retain) NSArray<NSString *> *allowedFormats;

- (instancetype)initWithSize:(CGSize)size
                   threshold:(NSNumber *)threshold
                  startDelay:(NSNumber *)delay
              allowedFormats:(NSArray<NSString *> *)allowedFormats;
- (void)performAdQualityCheckOn:(UIView *)view adConfiguration:(OGAAdConfiguration *)adConfiguration completion:(AdQualityAlgorythmCompletionBlock)completion;
@end

NS_ASSUME_NONNULL_END
