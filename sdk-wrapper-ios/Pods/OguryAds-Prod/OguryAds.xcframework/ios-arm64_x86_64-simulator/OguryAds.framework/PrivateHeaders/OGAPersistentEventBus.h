//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryCore.h>
#import <OguryCore/OguryPersistentEventBus.h>
#import <OguryCore/OguryEventEntry.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAPersistentEventBus : NSObject

#pragma mark - Constants

extern NSString *const OGAAdsChoiceManagerEventBusEvent;

#pragma mark - Properties

@property(nonatomic, strong) OguryPersistentEventBus *corePersistentEventBus;

#pragma mark - Methods

- (BOOL)shouldContinueLoadingAdWith:(OguryEventEntry *)eventEntry;
- (BOOL)hasExpired:(OguryEventEntry *)eventEntry;
- (void)registerOguryEventSubscriber:(id<OguryEventSubscriber>)oguryEventSubscriber;
- (void)unregisterOguryEventSubscriber:(id<OguryEventSubscriber>)oguryEventSubscriber;

@end

NS_ASSUME_NONNULL_END
