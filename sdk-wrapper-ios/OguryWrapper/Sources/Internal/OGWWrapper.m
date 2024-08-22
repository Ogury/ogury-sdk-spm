//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGWWrapper.h"
#import "OGWLog.h"
#import "OGWModules.h"
#import "OguryError+OGWWrapper.h"
#import "OGWSetLogLevelNotificationManager.h"

#if __has_include(<StoreKit/StoreKit.h>) || __has_include("StoreKit.h")
#define OGCStoreKitInstalled
#endif

#ifdef OGCStoreKitInstalled
#import <StoreKit/StoreKit.h>
#endif

static NSString *_Nonnull ogcConvertionValueKey = @"OGC_CONVERSION_VALUE";
static int ogcMaxNumberOfConvertionValue = 63;

@interface OGWWrapper ()

@property(nonatomic, strong) OGWModules *modules;
@property(nonatomic, strong) OGWSetLogLevelNotificationManager *logNotificationManager;
@property(nonatomic, strong) NSUserDefaults *userDefault;

@end

@implementation OGWWrapper

+ (instancetype)shared {
   static OGWWrapper *instance = nil;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
     instance = [[self alloc] init];
   });
   return instance;
}

- (instancetype)init {
   return [self initWithModules:[OGWModules shared]
         logNotificationManager:[[OGWSetLogLevelNotificationManager alloc] init]
                    userDefault:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithModules:(OGWModules *)modules
         logNotificationManager:(OGWSetLogLevelNotificationManager *)logNotificationManager
                    userDefault:(NSUserDefaults *)userDefault {
   if (self = [super init]) {
      _modules = modules;
      _logNotificationManager = logNotificationManager;
      [logNotificationManager registerToNotification];
      _userDefault = userDefault;
   }
   return self;
}

- (void)startWithConfiguration:(OguryConfiguration *)configuration completionHandler:(SetupCompletionBlock)completionHandler {
    int numberOfModulesPresent = 0;
    NSString *errorMessage = @"";
    for (OGWModule *module in self.modules.modules) {
        if (module.isPresent) {
            [[OGWLog shared] logAssetKeyFormat:OguryLogLevelDebug assetKey:configuration.assetKey format:@"Module [%@] initialization...", module.className];
            [module startWithAssetKey:configuration.assetKey completionHandler:^(BOOL success, OguryError * _Nullable error) {
                if(error && !success) {
                    [errorMessage stringByAppendingString:error.localizedDescription];
                }
            }];
            numberOfModulesPresent++;
        }
    }
    if (numberOfModulesPresent == 0) {
        [[OGWLog shared] logAssetKey:OguryLogLevelError assetKey:configuration.assetKey message:@"No Ogury module found in your application."];
        OguryError *noSDKModuleFound = [OguryError createNoSDKModuleFoundError];
        if(completionHandler) {
            completionHandler(false, noSDKModuleFound);
        }
    }
}

- (void)setLogLevel:(OguryLogLevel)logLevel {
   int numberOfModulesPresent = 0;
   for (OGWModule *module in self.modules.modules) {
      if (module.isPresent) {
         [module setLogLevel:logLevel];
         numberOfModulesPresent++;
      }
   }
   if (numberOfModulesPresent == 0) {
      [[OGWLog shared] logAssetKey:OguryLogLevelError assetKey:@"" message:@"SetLogLevel - No Ogury module found in your application. Make sure you have the -ObjC flag in your OTHER_LINKER_FLAGS build setting."];
   }
}

- (void)registerAttributionForSKAdNetwork {
   NSInteger convertionValue = [self.userDefault integerForKey:ogcConvertionValueKey];
   if (convertionValue > ogcMaxNumberOfConvertionValue) {
      [[OGWLog shared] logAssetKey:OguryLogLevelInfo assetKey:@"" message:@"Number of conversion Value maximun, It's not possible to register for SKAdNetwork anymore"];
      return;
   }
   if (@available(iOS 15.4, *)) {
      [SKAdNetwork updatePostbackConversionValue:convertionValue
                               completionHandler:^(NSError *_Nullable error) {
                                 if (error != NULL) {
                                    [[OGWLog shared] logAssetKey:OguryLogLevelError assetKey:@"" message:@"Error during updatePostbackConversionValue"];
                                 } else {
                                    [[OGWLog shared] logAssetKey:OguryLogLevelDebug assetKey:@"" message:@"updatePostbackConversionValue Success"];
                                 }
                               }];
   } else if (@available(iOS 14.0, *)) {
      [SKAdNetwork updateConversionValue:convertionValue];
      [[OGWLog shared] logAssetKey:OguryLogLevelDebug assetKey:@"" message:@"updateConversionValue Success"];
   }
   convertionValue++;
   [self.userDefault setInteger:convertionValue forKey:ogcConvertionValueKey];
}

@end
