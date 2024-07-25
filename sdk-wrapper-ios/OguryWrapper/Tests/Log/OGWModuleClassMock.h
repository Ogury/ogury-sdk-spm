//
//  Copyright © 2022-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryLogLevel.h>
#import <OguryCore/OguryPersistentEventBus.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGWModuleClassMock : NSObject

@property(class, nonatomic) OGWModuleClassMock *storedShared;
@property(nonatomic) OguryLogLevel storedLogLevel;
@property(nonatomic, nullable) NSString *storedAssetKey;
@property(nonatomic, nullable) OguryPersistentEventBus *storedPersistentEventBus;
@property(nonatomic, nullable) OguryEventBus *storedBroadcastEventBus;

+ (instancetype)shared;

- (void)startWithAssetKey:(NSString *_Nullable)assetKey persistentEventBus:(OguryPersistentEventBus *_Nullable)persistentEventBus broadcastEventBus:(OguryEventBus *_Nullable)broadcastEventBus;

- (void)setLogLevel:(OguryLogLevel)logLevel;

@end

NS_ASSUME_NONNULL_END
