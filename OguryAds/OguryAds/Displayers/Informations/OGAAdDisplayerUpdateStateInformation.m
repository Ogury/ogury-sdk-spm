//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAdDisplayerUpdateStateInformation.h"
#import "OGAMraidUtils.h"

@implementation OGAAdDisplayerUpdateStateInformation

- (instancetype)initWithMraidState:(OGAMRAIDState)mraidState {
    if (self = [super init]) {
        _rawMraidState = mraidState;
        _mraidState = [OGAMraidUtils getMraidStringFromState:mraidState];
    }
    return self;
}

#pragma mark - Methods

- (NSString *)toJavascriptCommand {
    return [NSString stringWithFormat:@"ogySdkMraidGateway.updateState(\"%@\")", self.mraidState];
}

@end
