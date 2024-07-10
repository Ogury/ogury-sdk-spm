//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGAMraidLogMessage.h"

@implementation OGAMraidLogMessage

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level
              adConfiguration:(OGAAdConfiguration *)adConfiguration
                    webviewId:(NSString *)webViewId
                      message:(NSString *)message {
    if (self = [super initWithLevel:level adConfiguration:adConfiguration message:message]) {
        _webviewId = webViewId;
    }
    return self;
}

#pragma mark - OguryStringFormattable

- (NSString *)formattedString {
    return [NSString stringWithFormat:@"[%@][%@][%@][MRAID][%@] %@",
                                      [self.adConfiguration getAdTypeString],
                                      self.adConfiguration.adUnitId,
                                      self.adConfiguration.campaignId ?: @"",
                                      self.webviewId,
                                      self.message];
}

@end
