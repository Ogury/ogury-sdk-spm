//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGAAdManager.h"
#import "OGAConditionChecker.h"

@interface OGAIsKilledChecker : NSObject <OGAConditionChecker>

@property(nonatomic, weak, nullable) OGAAdManager *adManager;

@end
