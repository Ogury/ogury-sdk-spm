//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryEventSubscriber.h>

NS_ASSUME_NONNULL_BEGIN

@interface OguryEventSubscriberMock : NSObject <OguryEventSubscriber>

#pragma mark - Properties

@property(nonatomic, copy) NSString *event;

@property(nonatomic) BOOL hasHandledEvent;

@property(nonatomic, assign) eventHandlerBlock eventHandler;

#pragma mark - Initialization

- (instancetype)initWithEvent:(NSString *)event andHandler:(_Nullable eventHandlerBlock)eventHandler;

@end

NS_ASSUME_NONNULL_END
