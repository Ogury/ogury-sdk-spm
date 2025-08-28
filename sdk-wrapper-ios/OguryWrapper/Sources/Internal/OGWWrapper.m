//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGWWrapper.h"
#import "OGWLog.h"
#import "OGWModulesManager.h"
#import "OguryError+OGWWrapper.h"
#import "OGWSetLogLevelNotificationManager.h"
#import <OguryAds/OGAInternal.h>
#import <OguryAds/OGASdkConsumer.h>

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
@property(nonatomic, strong) NSMutableArray<StartCompletionBlock> *startCompletionBlocks;
@property(nonatomic) BOOL isStarting;

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
      _startCompletionBlocks = [NSMutableArray new];
      _isStarting = NO;
       [[OGAInternal shared] setSdkConsumer: [[OGASdkConsumer alloc] initWithName:@"sdk" version:[Ogury sdkVersion]] ];
   }
   return self;
}

- (void)startWith:(NSString *)assetKey completionHandler:(StartCompletionBlock _Nullable)completionHandler {
   @synchronized(self) {
      if (completionHandler != NULL) {
         [self.startCompletionBlocks addObject:completionHandler];
      }
      if (self.isStarting) {
         return;
      }
      self.isStarting = YES;
      
      
      int numberOfModulesPresent = 0;
      __block NSMutableString *errorMessage = [NSMutableString string];
      __block NSMutableString *modulesMessage = [NSMutableString string];
      
      dispatch_group_t startGroup = dispatch_group_create();
      
      for (OGWModule *module in self.modulesManager.modules) {
         if (module.isPresent) {
            dispatch_group_enter(startGroup);
            [self.log log:OguryLogLevelDebug message:[NSString stringWithFormat:@"Module [%@] initialization...", module.className]];
            [module startWith:assetKey completionHandler:^(BOOL success, OguryError * _Nullable error) {
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
         [self.log log:OguryLogLevelDebug
                    logType:OguryLogTypePublisher
                    message:@"No Ogury module found in your application. Make sure you have the -ObjC flag in your OTHER_LINKER_FLAGS build setting."];
         if (self.startCompletionBlocks.count > 0) {
            OguryError *moduleMissingError = [OguryError createModuleMissingError];
            for (StartCompletionBlock completionBlock in self.startCompletionBlocks) {
               completionBlock(false, moduleMissingError);
            }
            [self.startCompletionBlocks removeAllObjects];
         }
         self.isStarting = NO;
         return ;
      }
      dispatch_group_notify(startGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         if (errorMessage && errorMessage.length > 0) {
             [self.log log:OguryLogLevelError
                   logType:OguryLogTypePublisher
                   message:[NSString stringWithFormat:@"Error found during the Ogury Start() call :%@", errorMessage]];
            if (self.startCompletionBlocks.count > 0) {
               OguryError *failedToStartError = [OguryError createModuleFailedToStartError:errorMessage];
               for (StartCompletionBlock completionBlock in self.startCompletionBlocks) {
                  completionBlock(false, failedToStartError);
               }
               [self.startCompletionBlocks removeAllObjects];
            }
            self.isStarting = NO;
            return;
         }
         if (modulesMessage && modulesMessage.length > 0) {
             [self.log log:OguryLogLevelDebug message:[NSString stringWithFormat:@"Ogury Start() ended succesfully for modules :%@", modulesMessage]];
         }
         if (self.startCompletionBlocks.count > 0) {
            for (StartCompletionBlock completionBlock in self.startCompletionBlocks) {
               completionBlock(true, NULL);
            }
            [self.startCompletionBlocks removeAllObjects];
         }
         self.isStarting = NO;
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
       [self.log log:OguryLogLevelDebug
                    logType:OguryLogTypePublisher
                    message:@"SetLogLevel - No Ogury module found in your application. Make sure you have the -ObjC flag in your OTHER_LINKER_FLAGS build setting."];
   }
}

- (void)registerAttributionForSKAdNetwork {
   NSInteger convertionValue = [self.userDefault integerForKey:ogcConvertionValueKey];
   if (convertionValue > ogcMaxNumberOfConvertionValue) {
       [self.log log:OguryLogLevelDebug
                    message:@"Number of conversion Value maximun, It's not possible to register for SKAdNetwork anymore"];
      return;
   }
   if (@available(iOS 15.4, *)) {
      [SKAdNetwork updatePostbackConversionValue:convertionValue
                               completionHandler:^(NSError *_Nullable error) {
                                 if (error != NULL) {
                                     [self.log log:OguryLogLevelDebug message:@"Error during updatePostbackConversionValue"];
                                 } else {
                                     [self.log log:OguryLogLevelDebug message:@"updatePostbackConversionValue Success"];
                                 }
                               }];
   } else if (@available(iOS 14.0, *)) {
      [SKAdNetwork updateConversionValue:convertionValue];
       [self.log log:OguryLogLevelDebug message:@"updateConversionValue Success"];
   }
   convertionValue++;
   [self.userDefault setInteger:convertionValue forKey:ogcConvertionValueKey];
}

@end
