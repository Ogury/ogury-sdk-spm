//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OGAAdDisplayerUpdateCurrentPositionInformation.h"

@interface OGAAdDisplayerUpdateCurrentPositionInformation ()

@property(nonatomic, assign) CGSize size;
@property(nonatomic, assign) CGPoint position;

@end

@implementation OGAAdDisplayerUpdateCurrentPositionInformation

- (instancetype)initWithPosition:(CGPoint)position size:(CGSize)size {
    if (self = [super init]) {
        _position = position;
        _size = size;
    }
    return self;
}

#pragma mark - Methods

- (NSString *)toJavascriptCommand {
    return [NSString stringWithFormat:@"ogySdkMraidGateway.updateCurrentPosition({x: %ld, y: %ld, width: %ld, height: %ld})", (long)self.position.x, (long)self.position.y, (long)self.size.width, (long)self.size.height];
}

@end
