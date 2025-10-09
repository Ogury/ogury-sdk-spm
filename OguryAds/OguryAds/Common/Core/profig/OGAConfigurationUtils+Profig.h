//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAConfigurationUtils.h"

@class OGAProfigFullResponse;

NS_ASSUME_NONNULL_BEGIN

@interface OGAConfigurationUtils (OGAConfigurationUtils)

typedef enum : NSUInteger {
    OGAProfigExternalErrorNoInternet = 0,
    OGAProfigExternalErrorAlreadyLoading = 1,
    OGAProfigExternalErrorSetupFailed = 2,
    OGAProfigExternalErrorBundleNotMatching = 3
} OGAProfigExternalError;

+ (NSMutableDictionary *)profigParams;
+ (NSError *)errorForOGAProfigError:(OGAProfigExternalError)error;
+ (NSError *)errorForServerProfigError:(OGAProfigFullResponse *)response;

@end

NS_ASSUME_NONNULL_END
