//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryEventSubscriber.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryEventSubscriberMock : NSObject <OguryEventSubscriber>

#pragma mark - Properties

@property (nonatomic, copy) NSString *event;

@property (nonatomic) BOOL hasHandledEvent;

@property (nonatomic) eventHandlerBlock eventHandler;

#pragma mark - Initialization

- (instancetype)initWithEvent:(NSString *)event andHandler:(_Nullable eventHandlerBlock)eventHandler;

@end

NS_ASSUME_NONNULL_END
