//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAdManager.h"
#import "OGAConditionChecker.h"

@interface OGAIsLoadedChecker : NSObject <OGAConditionChecker>

@property(nonatomic, weak, nullable) OGAAdManager *adManager;

@end
