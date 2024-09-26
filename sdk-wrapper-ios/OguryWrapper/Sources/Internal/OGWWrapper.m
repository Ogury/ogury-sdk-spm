//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGWWrapper.h"
#import "OGWLog.h"
#import "OGWModulesManager.h"
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

@property(nonatomic, strong) OGWModulesManager *modulesManager;
@property(nonatomic, strong) OGWSetLogLevelNotificationManager *logNotificationManager;
@property(nonatomic, strong) NSUserDefaults *userDefault;
@property(nonatomic, strong) OGWLog *log;

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
   return [self initWithModules:[OGWModulesManager shared]
          logNotificationManager:[[OGWSetLogLevelNotificationManager alloc] init]
                     userDefault:[NSUserDefaults standardUserDefaults]
                            log:[OGWLog shared]];
}

- (instancetype)initWithModules:(OGWModulesManager *)modules
         logNotificationManager:(OGWSetLogLevelNotificationManager *)logNotificationManager
                    userDefault:(NSUserDefaults *)userDefault
                            log:(OGWLog *)log {
   if (self = [super init]) {
      _modulesManager = modules;
      _logNotificationManager = logNotificationManager;
      [logNotificationManager registerToNotification];
      _userDefault = userDefault;
      _log = log;
   }
   return self;
}

- (void)startWithConfiguration:(OguryConfiguration *)configuration completionHandler:(StartCompletionBlock)completionHandler {
    int numberOfModulesPresent = 0;
    __block NSMutableString *errorMessage = [NSMutableString string];
    __block NSMutableString *modulesMessage = [NSMutableString string];
    
    dispatch_group_t startGroup = dispatch_group_create();
    
    for (OGWModule *module in self.modulesManager.modules) {
        if (module.isPresent) {
            dispatch_group_enter(startGroup);
            [self.log logAssetKeyFormat:OguryLogLevelDebug assetKey:configuration.assetKey format:@"Module [%@] initialization...", module.className];
            [module startWithAssetKey:configuration.assetKey completionHandler:^(BOOL success, OguryError * _Nullable error) {
                if (error && !success) {
                    @synchronized (errorMessage) {
                        [errorMessage appendString:[NSString stringWithFormat:@"\n%@", error.localizedDescription]];
                    }
                } else {
                    @synchronized (modulesMessage) {
                        [modulesMessage appendString:[NSString stringWithFormat:@"\n%@", module.className]];
                    }
                }
                dispatch_group_leave(startGroup);
            }];
            numberOfModulesPresent++;
        }
    }
    if (numberOfModulesPresent == 0) {
        [self.log logAssetKey:OguryLogLevelError assetKey:configuration.assetKey message:@"No Ogury module found in your application."];
        if (completionHandler) {
            OguryError *noSDKModuleFound = [OguryError createNoSDKModuleFoundError];
            completionHandler(false, noSDKModuleFound);
        }
    } else {
        dispatch_group_notify(startGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (errorMessage && errorMessage.length > 0) {
                [self.log logAssetKeyFormat:OguryLogLevelError assetKey:configuration.assetKey format:@"Error found during the Ogury Start() call :%@", errorMessage];
                if (completionHandler) {
                    OguryError *failedStartingError = [OguryError createFailedStartingOguryModuleError:errorMessage];
                    completionHandler(false, failedStartingError);
                }
            } else {
                if (modulesMessage && modulesMessage.length > 0) {
                    [self.log logAssetKeyFormat:OguryLogLevelDebug assetKey:configuration.assetKey format:@"Ogury Start() ended succesfully for modules :%@", modulesMessage];
                }
                if (completionHandler) {
                    completionHandler(true, nil);
                }
            }
        });
    }
}

- (void)setLogLevel:(OguryLogLevel)logLevel {
   int numberOfModulesPresent = 0;
   for (OGWModule *module in self.modulesManager.modules) {
      if (module.isPresent) {
         [module setLogLevel:logLevel];
         numberOfModulesPresent++;
      }
   }
   if (numberOfModulesPresent == 0) {
      [self.log logAssetKey:OguryLogLevelError assetKey:@"" message:@"SetLogLevel - No Ogury module found in your application. Make sure you have the -ObjC flag in your OTHER_LINKER_FLAGS build setting."];
   }
}

- (void)registerAttributionForSKAdNetwork {
   NSInteger convertionValue = [self.userDefault integerForKey:ogcConvertionValueKey];
   if (convertionValue > ogcMaxNumberOfConvertionValue) {
      [self.log logAssetKey:OguryLogLevelInfo assetKey:@"" message:@"Number of conversion Value maximun, It's not possible to register for SKAdNetwork anymore"];
      return;
   }
   if (@available(iOS 15.4, *)) {
      [SKAdNetwork updatePostbackConversionValue:convertionValue
                               completionHandler:^(NSError *_Nullable error) {
                                 if (error != NULL) {
                                    [self.log logAssetKey:OguryLogLevelError assetKey:@"" message:@"Error during updatePostbackConversionValue"];
                                 } else {
                                    [self.log logAssetKey:OguryLogLevelDebug assetKey:@"" message:@"updatePostbackConversionValue Success"];
                                 }
                               }];
   } else if (@available(iOS 14.0, *)) {
      [SKAdNetwork updateConversionValue:convertionValue];
      [self.log logAssetKey:OguryLogLevelDebug assetKey:@"" message:@"updateConversionValue Success"];
   }
   convertionValue++;
   [self.userDefault setInteger:convertionValue forKey:ogcConvertionValueKey];
}

@end
