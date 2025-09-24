//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdDisplayerUpdateScreenSizeInformation.h"

@implementation OGAAdDisplayerUpdateScreenSizeInformation

#pragma mark - Initialization

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super init]) {
        _size = size;
    }

    return self;
}

#pragma mark - Methods

- (NSString *)toJavascriptCommand {
    return [NSString stringWithFormat:@"ogySdkMraidGateway.updateScreenSize({width: %li, height: %li})", (long)self.size.width, (long)self.size.height];
}

@end
