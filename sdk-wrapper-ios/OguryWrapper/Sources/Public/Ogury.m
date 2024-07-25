//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "Ogury.h"
#import "OGWLog.h"
#import "OGWWrapper.h"

@implementation Ogury

+ (void)startWithConfiguration:(OguryConfiguration *)configuration {
   [[OGWWrapper shared] startWithConfiguration:configuration];
}

+ (void)setLogLevel:(OguryLogLevel)logLevel {
   [[OGWWrapper shared] setLogLevel:logLevel];
   [[OGWLog shared] setLogLevel:logLevel];
}

+ (NSString *)getSdkVersion {
   return SDK_VERSION;
}

+ (void)registerAttributionForSKAdNetwork {
   [[OGWWrapper shared] registerAttributionForSKAdNetwork];
}

@end
