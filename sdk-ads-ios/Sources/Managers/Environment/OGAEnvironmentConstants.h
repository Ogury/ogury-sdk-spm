//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Environments
extern NSString *const OGAEnvironmentProdString;
extern NSString *const OGAEnvironmentStagingString;
extern NSString *const OGAEnvironmentDevcString;
extern NSString *const OGAEnvironmentChanged;

typedef enum : NSUInteger {
    OGAEnvironmentProd = 0,
    OGAEnvironmentStaging = 1,
    OGAEnvironmentDevC = 2
} OGAEnvironment;
