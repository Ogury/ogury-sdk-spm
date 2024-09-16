//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGCURLRequestLogMessage.h"

@implementation OGCURLRequestLogMessage

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level 
                      message:(NSString *)message
                      request:(NSURLRequest *)request {
    if (self = [super initWithLevel:level logType:OguryLogTypeRequests message:message]) {
        _request = request;
    }

    return self;
}

#pragma mark - OguryStringFormattable

- (NSString *)formattedString {
    return [NSString stringWithFormat:@" %@|%@ -- %@",
            [self.request HTTPMethod],
            [self.request.URL description],
            self.message];
}

@end
