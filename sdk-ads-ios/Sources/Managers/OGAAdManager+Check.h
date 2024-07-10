//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdManager.h"

/**
 * Interface allowing conditions checker to check internal status of the ad manager.
 */
@interface OGAAdManager (Check)

@property(nonatomic, strong, readonly) NSHashTable *sequencesShowing;

@end
