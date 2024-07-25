//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryAbstractLogMessage.h>
#import <OguryCore/OguryEventEntry.h>
#import <OguryCore/OguryStringFormattable.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAEventBusLogMessage : OguryAbstractLogMessage <OguryStringFormattable>

#pragma mark - Properties

@property(nonatomic, strong) OguryEventEntry *eventEntry;

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level eventEntry:(OguryEventEntry *)eventEntry message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
