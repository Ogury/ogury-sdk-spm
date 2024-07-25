//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGWAssetKeyLogMessage.h"

@implementation OGWAssetKeyLogMessage

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level assetKey:(NSString *)assetKey message:(NSString *)message {
    if (self = [super initWithLevel:level message:message]) {
        _assetKey = assetKey;
    }

    return self;
}

#pragma mark - OguryStringFormattable

- (NSString *)formattedString {
    return [NSString stringWithFormat:@"[%@][Wrapper] %@", self.assetKey, self.message];
}

@end
