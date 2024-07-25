//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OGAAdDisplayerUpdateCurrentAppOrientationInformation.h"

@implementation OGAAdDisplayerUpdateCurrentAppOrientationInformation

- (instancetype)initWithOrientation:(NSString *)orientation locked:(BOOL)locked {
    if (self = [super init]) {
        _orientation = orientation;
        _locked = locked;
    }
    return self;
}

#pragma mark - Methods

- (NSString *)toJavascriptCommand {
    return [NSString stringWithFormat:@"ogySdkMraidGateway.updateCurrentAppOrientation({orientation: \"%@\", locked: %@})", self.orientation, self.locked ? @"true" : @"false"];
}

@end
