//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OguryAbstractLogMessage.h"
#import "OguryEventEntry.h"
#import "OguryStringFormattable.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGCEventLogMessage : OguryAbstractLogMessage <OguryStringFormattable>

#pragma mark - Properties

@property (nonatomic, strong) OguryEventEntry *eventEntry;

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level message:(NSString *)message eventEntry:(OguryEventEntry *)eventEntry;

@end

NS_ASSUME_NONNULL_END
