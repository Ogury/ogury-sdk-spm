//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAdLogMessage.h"

@implementation OGAAdLogMessage

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level
              adConfiguration:(OGAAdConfiguration *)adConfiguration
                      message:(NSString *)message {
    if (self = [super initWithLevel:level logType:OguryLogTypeInternal message:message]) {
        _adConfiguration = adConfiguration;
    }
    return self;
}

#pragma mark - OguryStringFormattable

- (NSString *)formattedString {
    return [NSString stringWithFormat:@"[%@][%@][%@] %@",
                                      [self.adConfiguration getAdTypeString],
                                      self.adConfiguration.adUnitId,
                                      self.adConfiguration.campaignId ?: @"",
                                      self.message];
}

@end
