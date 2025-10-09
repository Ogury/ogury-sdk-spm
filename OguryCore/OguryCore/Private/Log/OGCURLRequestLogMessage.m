//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGCURLRequestLogMessage.h"
#import "OguryLogMessage.h"

@implementation OGCURLRequestLogMessage

#pragma mark - Initialization
- (instancetype)initWithLevel:(OguryLogLevel)level sdk:(OguryLogSDK)sdk message:(NSString *)message request:(NSURLRequest *)request {
    
    if (self = [super initWithLevel:level
                            logType:OguryLogTypeRequests
                                sdk:sdk
                            message:message]) {
        _request = request;
        self.tags = @[[OguryLogTag tagWithKey:@"Method" value:request.HTTPMethod],
                      [OguryLogTag tagWithKey:@"URL" value:request.URL.description]];
    }
    
    return self;
}

- (instancetype)initWithLevel:(OguryLogLevel)level
                      message:(NSString *)message
                      request:(NSURLRequest *)request {
    return [self initWithLevel:level sdk:OguryLogSDKCore message:message request:request];
}

@end
