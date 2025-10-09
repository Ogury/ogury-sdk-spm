//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdDisplayerUpdateManualExposureInformation.h"

@implementation OGAAdDisplayerUpdateManualExposureInformation

#pragma mark - Initialization

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super init]) {
        _size = size;
    }

    return self;
}

#pragma mark - Methods

- (NSString *)toJavascriptCommand {
    return [NSString stringWithFormat:@"ogySdkMraidGateway.updateExposure({exposedPercentage: 100.0, visibleRectangle: {x: 0, y: 0, width: %ld, height: %ld}})", (long)self.size.width, (long)self.size.height];
}

@end
