//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryEventEntry.h>
#import <OguryCore/OguryEventSubscriber.h>
#import <OguryCore/OguryEventBus.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGABroadcastEventBus : NSObject

#pragma mark - Constants

extern NSString *const OGAChoiceManagerEventBusCMChange;

#pragma mark - Properties

@property(nonatomic, strong) OguryEventBus *coreBroadcastEventBus;

#pragma mark - Methods

- (BOOL)shouldResetProfig:(OguryEventEntry *)eventEntry;
- (void)registerOguryEventSubscriber:(id<OguryEventSubscriber>)oguryEventSubscriber;
- (void)unregisterOguryEventSubscriber:(id<OguryEventSubscriber>)oguryEventSubscriber;

@end

NS_ASSUME_NONNULL_END
