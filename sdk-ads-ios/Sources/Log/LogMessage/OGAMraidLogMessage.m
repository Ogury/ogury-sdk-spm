//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGAMraidLogMessage.h"
#import "OGALog.h"

@implementation OGAMraidLogMessage

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level
              adConfiguration:(OGAAdConfiguration *)adConfiguration
                    webviewId:(NSString *)webViewId
                      message:(NSString *)message
                         tags:(NSArray<OguryLogTag *> *_Nullable)tags {
    if (self = [super initWithLevel:level
                    adConfiguration:adConfiguration
                            logType:OguryLogTypeMraid
                            message:message
                               tags:tags]) {
        _webviewId = webViewId;
        self.tags = [self.tags arrayByAddingObject:[OguryLogTag tagWithKey:@"WebViewId" value:webViewId]];
    }
    return self;
}

- (instancetype)initWithLevel:(OguryLogLevel)level
              adConfiguration:(OGAAdConfiguration *)adConfiguration
                    webviewId:(NSString *)webViewId
                        error:(NSError *)error
                      message:(NSString *_Nullable)message
                         tags:(NSArray<OguryLogTag *> *_Nullable)tags {
    return [self initWithLevel:level
               adConfiguration:adConfiguration
                     webviewId:webViewId
                       message:message == nil ? logErrorMessage(error) : [logErrorMessage(error) stringByAppendingFormat:@" - %@", message]
                          tags:tags];
}

@end
