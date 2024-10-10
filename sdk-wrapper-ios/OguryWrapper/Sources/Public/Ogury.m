//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "Ogury.h"
#import "OGWLog.h"
#import "OGWWrapper.h"
#import <OguryCore/OGCInternal.h>

@implementation Ogury

+ (void)startWith:(NSString *)assetKey {
    [self startWith:assetKey completionHandler:nil];
}

+ (void)startWith:(NSString *)assetKey completionHandler:(StartCompletionBlock _Nullable)completionHandler {
    [[OGWWrapper shared] startWith:assetKey completionHandler:completionHandler];
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
