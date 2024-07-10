//
//  Copyright © 2019 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdExposure : NSObject

#pragma mark - Properties

@property(nonatomic, assign) CGRect visibleRectangle;
@property(nonatomic, strong) NSArray<NSValue *> *occlusionRectangles;
/**
 * Percentage values are between 0 and 100.
 */
@property(nonatomic, assign) CGFloat exposurePercentage;

#pragma mark - Methods

+ (OGAAdExposure *)fullExposure;

+ (OGAAdExposure *)zeroExposure;

@end

NS_ASSUME_NONNULL_END
