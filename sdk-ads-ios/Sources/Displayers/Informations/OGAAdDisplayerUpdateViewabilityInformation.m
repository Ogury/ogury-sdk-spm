//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdDisplayerUpdateViewabilityInformation.h"

@implementation OGAAdDisplayerUpdateViewabilityInformation

#pragma mark - Initialization

- (instancetype)initWithViewability:(BOOL)isViewable {
    if (self = [super init]) {
        _isViewable = isViewable;
    }

    return self;
}

#pragma mark - Methods

- (NSString *)toJavascriptCommand {
    return [NSString stringWithFormat:@"ogySdkMraidGateway.updateViewability(%@)", self.isViewable ? @"true" : @"false"];
}

@end
