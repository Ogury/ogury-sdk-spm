//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAConfigurationUtils.h"
#import "OGALog.h"
#import "OGAReachability.h"
#import <UIKit/UIKit.h>
#import <mach-o/arch.h>

#if __has_include(<UnityFramework.framework>)
#define __HAS_UNITY__
#endif

#if __has_include(<Cordova.framework>)
#define __HAS_CORDOVA__
#endif

#if __has_include(<Mono.framework>)
#define __HAS_XAMARIN__
#endif

#if __has_include(<AIR.framework>)
#define __HAS_AIR__
#endif

@implementation OGAConfigurationUtils

static NSString *const OGAConfigurationUtilsZeroTimer = @"+00:00";
static NSString *const OGAConfigurationUtilsDateFormat = @"Z";
static NSInteger const OGAConfigurationUtilsIdiomiPad = 132;
static NSInteger const OGAConfigurationUtilsIdiomiOS = 163;
static NSString *const OGAConfigurationUtilsSDK = @"ads";
static NSString *const OGAConfigurationUtilsDeviceOS = @"ios";
static NSString *const OGAConfigurationUtilsManufacturer = @"Apple";

+ (NSString *)cpuArchitecture {
    const NXArchInfo *info = NXGetAllArchInfos();
    NSString *cpuArchitecture = [NSString stringWithUTF8String:info->description];
    return cpuArchitecture ? cpuArchitecture : @"";
}

+ (double)screenDensity {
    double multiplier = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? OGAConfigurationUtilsIdiomiPad : OGAConfigurationUtilsIdiomiOS;
    return [self screenScale] * multiplier;
}

+ (NSUInteger)screenScale {
    return UIScreen.mainScreen.nativeScale;
}

+ (NSString *)timeZone {
    NSMutableString *muStringTimeZone = [NSMutableString stringWithString:OGAConfigurationUtilsZeroTimer];
    @try {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = OGAConfigurationUtilsDateFormat;
        NSString *stringTimezone = [dateFormatter stringFromDate:[NSDate date]];
        muStringTimeZone = [NSMutableString stringWithString:stringTimezone];
        [muStringTimeZone insertString:@":" atIndex:3];
    } @catch (NSException *exception) {
        [[OGALog shared] logFormat:OguryLogLevelDebug format:@"Timezone formatter exception %@", exception.description];
    }
    return muStringTimeZone;
}

+ (NSString *)countryCode {
    return NSLocale.currentLocale.countryCode ?: @"";
}

+ (NSString *)languageCode {
    return NSLocale.currentLocale.languageCode ?: @"";
}

+ (NSString *)getSDKType {
    return OGAConfigurationUtilsSDK;
}

+ (NSString *)getDeviceOS {
    return OGAConfigurationUtilsDeviceOS;
}

+ (NSString *)getDeviceOSVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (BOOL)isConnectedToInternet {
    return [[OGAReachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable;
}

+ (NSString *)currentNetwork {
    return [[OGAReachability reachabilityForInternetConnection] currentReachabilityNetwork];
}

+ (NSString *)currentCellularNetwork {
    return [[OGAReachability reachabilityForInternetConnection] currentReachabilityCellularNetwork];
}

+ (NSString *)getAppMarketingVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

+ (NSString *)getAppBuildVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
}

+ (NSString *)getAppBundleIdentifer {
    return [NSBundle mainBundle].bundleIdentifier;
}

+ (NSString *)getManufacturer {
    return OGAConfigurationUtilsManufacturer;
}

+ (NSString *)getVendorId {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (BOOL)isiOSAppOnMac {
    if (@available(iOS 14.0, *)) {
        return [NSProcessInfo processInfo].isiOSAppOnMac;
    }
    return NO;
}

@end
