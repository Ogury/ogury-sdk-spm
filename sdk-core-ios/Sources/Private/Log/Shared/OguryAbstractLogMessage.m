//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OguryAbstractLogMessage.h"
#import "OGCLogFormatter.h"

@implementation OguryAbstractLogMessage

#pragma mark - Initialization
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [[[self class] alloc] initWithLevel:self.level
                                       logType:self.logType
                                        origin:self.origin
                                           sdk:self.sdk
                                   messageDate:self.messageDate
                                       message:self.message
                                          tags:self.tags];
}

@end
