//
//  Copyright © 2020 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryEventEntry.h>
#import <OguryCore/OguryEventSubscriber.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OguryAdsEventSubscriberDelegate <NSObject>

- (void)hasReceivedEventWith:(OguryEventEntry *)eventEntry;

@end

@interface OGAEventSubscriber : NSObject <OguryEventSubscriber>

@property(nonatomic, weak) id<OguryAdsEventSubscriberDelegate> delegate;

- (instancetype)initWithEvent:(NSString *)event;

@end

NS_ASSUME_NONNULL_END
