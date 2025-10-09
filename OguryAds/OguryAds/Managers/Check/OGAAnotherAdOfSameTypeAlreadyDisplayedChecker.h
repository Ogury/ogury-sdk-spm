//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAConditionChecker.h"

@interface OGAAnotherAdOfSameTypeAlreadyDisplayedChecker : NSObject <OGAConditionChecker>

#pragma mark - Initialization

+ (instancetype)shared;

@end
