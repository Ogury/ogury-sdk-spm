//
//  Copyright © 2022-present Ogury. All rights reserved.
//

#import "OGWModuleClassMock.h"
#import <Foundation/Foundation.h>

@implementation OGWModuleClassMock

static OGWModuleClassMock *_storedShared = nil;
@synthesize storedLogLevel = OguryLogLevelError;  // default
@synthesize storedAssetKey;
@synthesize storedPersistentEventBus;
@synthesize storedBroadcastEventBus;

+ (instancetype)shared {
   return [self storedShared];
}

- (void)startWithAssetKey:(NSString *_Nullable)assetKey
       persistentEventBus:(OguryPersistentEventBus *_Nullable)persistentEventBus
        broadcastEventBus:(OguryEventBus *_Nullable)broadcastEventBus {
   self.storedAssetKey = assetKey;
   self.storedPersistentEventBus = persistentEventBus;
   self.storedBroadcastEventBus = broadcastEventBus;
}

- (void)setLogLevel:(OguryLogLevel)logLevel {
   self.storedLogLevel = logLevel;
}

// setter & getter

+ (OGWModuleClassMock *)storedShared {
   if (_storedShared == nil) {
      _storedShared = [[OGWModuleClassMock alloc] init];
   }
   return _storedShared;
}

+ (void)setStoredShared:(OGWModuleClassMock *)newStoredShared {
   _storedShared = newStoredShared;
}

@end
