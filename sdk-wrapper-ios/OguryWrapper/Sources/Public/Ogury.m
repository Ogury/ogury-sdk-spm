//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "Ogury.h"
#import "OGWLog.h"
#import "OGWWrapper.h"
#import <OguryCore/OGCInternal.h>

@implementation Ogury

+ (void)startWithConfiguration:(OguryConfiguration *)configuration completionHandler:(StartCompletionBlock)completionHandler {
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

+ (void)setPrivacyData:(NSString *)key boolean:(BOOL)value {
   [[OGCInternal shared] setPrivacyData:key boolean:value];
}

+ (void)setPrivacyData:(NSString *)key integer:(NSInteger)value {
   [[OGCInternal shared] setPrivacyData:key integer:value];
}

+ (void)setPrivacyData:(NSString *)key string:(NSString *)value {
   [[OGCInternal shared] setPrivacyData:key string:value];
}

@end
