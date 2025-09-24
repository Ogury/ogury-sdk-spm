//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryLogFormatter.h>
#import <OguryCore/OguryAbstractLogMessage.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGCLogFormatter : OguryLogFormatter

- (nullable NSString *)formatLogMessage:(OguryAbstractLogMessage *)logMessage;

@end

NS_ASSUME_NONNULL_END
