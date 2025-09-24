//
//  OGAAdQualityAlgorithm.m
//  OguryAds
//
//  Created by Jerome TONNELIER on 26/08/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import "OGAAdQualityAlgorithm.h"

OguryAdQualityAlgorithm const OguryAdQualityAlgorithmUniformColorRect = @"UNIFORM_COLOR_RECT";
NSString *const OguryAdQualityAlgorithmKey = @"algo";

@implementation OGAAdQualityResult
@synthesize algo, success, error, threshold, duration, devianceMax;
@end
