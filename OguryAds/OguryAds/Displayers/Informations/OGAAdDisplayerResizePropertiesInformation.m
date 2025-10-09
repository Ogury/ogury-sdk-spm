//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAdDisplayerResizePropertiesInformation.h"

@implementation OGAAdDisplayerResizePropertiesInformation

#pragma mark - Initialization

- (instancetype)initWithWidth:(int)width height:(int)height xOffset:(int)xOffset yOffset:(int)yOffset {
    if (self = [super init]) {
        _width = width;
        _height = height;
        _xOffset = xOffset;
        _yOffset = yOffset;
    }

    return self;
}

#pragma mark - Methods

- (NSString *)toJavascriptCommand {
    return [NSString stringWithFormat:@"ogySdkMraidGateway.updateResizeProperties({width: %ld, height: %ld, offsetX: %ld, offsetY: %ld, customClosePosition: \"right\", allowOffscreen: false})",
                                      (long)self.width,
                                      (long)self.height,
                                      (long)self.xOffset,
                                      (long)self.yOffset];
}

@end
