//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryPersistentEventBus.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGYModule : NSObject

#pragma mark - Properties

@property(nonatomic, copy, readonly) NSString *className;

@property(nonatomic, assign, readonly) BOOL isPresent;

#pragma mark - Initialization

- (instancetype)initWithClassName:(NSString *)className;

#pragma mark - Methods

- (void)startWithAssetKey:(NSString *)assetKey
       persistentEventBus:(OguryPersistentEventBus *)persistentEventBus
        broadcastEventBus:(OguryEventBus *)broadcastEventBus;

@end

NS_ASSUME_NONNULL_END
