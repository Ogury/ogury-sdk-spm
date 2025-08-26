//
//  OGAAdQualityAlgorythm.m
//  OguryAds
//
//  Created by Jerome TONNELIER on 26/08/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import "OGAAdQualityAlgorythm.h"

OguryAdQualityAlgorythm const OguryAdQualityAlgorythmUniformColorRect = @"UNIFORM_COLOR_RECT";
NSString * const OguryAdQualityAlgorythmKey = @"algo";

@implementation OGAAdQualityResult
@synthesize algo, sucess, error, threshold, duration;
@end
