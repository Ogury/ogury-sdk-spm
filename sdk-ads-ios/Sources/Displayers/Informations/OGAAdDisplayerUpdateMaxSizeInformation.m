//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OGAAdDisplayerUpdateMaxSizeInformation.h"

@implementation OGAAdDisplayerUpdateMaxSizeInformation

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super init]) {
        _size = size;
    }
    return self;
}

#pragma mark - Methods

- (NSString *)toJavascriptCommand {
    return [NSString stringWithFormat:@"ogySdkMraidGateway.updateMaxSize({width: %ld, height: %ld})", (long)self.size.width, (long)self.size.height];
}

@end
