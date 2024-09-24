//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "Ogury.h"
#import "OGWLog.h"
#import "OGWWrapper.h"
#import <OguryCore/OGCInternal.h>

@implementation Ogury

+ (void)startWithConfiguration:(OguryConfiguration *)configuration completionHandler:(SetupCompletionBlock)completionHandler {
    [[OGWWrapper shared] startWithConfiguration:configuration completionHandler:completionHandler];
}

+ (void)startWithConfiguration:(OguryConfiguration *)configuration {
    [self startWithConfiguration:configuration completionHandler:nil];
}

+ (void)setLogLevel:(OguryLogLevel)logLevel {
   [[OGWWrapper shared] setLogLevel:logLevel];
   [[OGWLog shared] setLogLevel:logLevel];
}

+ (NSString *)sdkVersion {
   return SDK_VERSION;
}

+ (void)registerAttributionForSKAdNetwork {
   [[OGWWrapper shared] registerAttributionForSKAdNetwork];
}

+ (void)storePrivacyData:(NSString *)key boolean:(BOOL)value {
   [[OGCInternal shared] storePrivacyData:key boolean:value];
}

+ (void)storePrivacyData:(NSString *)key integer:(NSInteger)value {
   [[OGCInternal shared] storePrivacyData:key integer:value];
}

+ (void)storePrivacyData:(NSString *)key string:(NSString *)value {
   [[OGCInternal shared] storePrivacyData:key string:value];
}

@end
