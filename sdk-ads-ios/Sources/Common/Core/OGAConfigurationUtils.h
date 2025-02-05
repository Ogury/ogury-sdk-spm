//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OGAConfigurationUtils : NSObject

+ (NSString *)timeZone;
+ (NSString *)cpuArchitecture;
+ (double)screenDensity;
+ (NSUInteger)screenScale;
+ (NSString *)countryCode;
+ (NSString *)languageCode;
+ (NSString *)getSDKType;
+ (NSString *)getDeviceOS;
+ (NSString *)getDeviceOSVersion;
+ (BOOL)isConnectedToInternet;
+ (NSString *)currentNetwork;
+ (NSString *)currentCellularNetwork;
+ (NSString *)getAppMarketingVersion;
+ (NSString *)getAppBuildVersion;
+ (NSString *)getManufacturer;
+ (NSString *)getAppBundleIdentifer;
+ (NSString *)getVendorId;
+ (BOOL)isiOSAppOnMac;

@end
