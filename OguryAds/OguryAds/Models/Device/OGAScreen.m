//
//  Copyright © 2018 Ogury Ltd. All rights reserved.
//

#import "OGAScreen.h"

#import <UIKit/UIKit.h>

@implementation OGAScreen

- (instancetype)init {
    self = [super init];
    if (self) {
        CGSize screenSize = UIScreen.mainScreen.bounds.size;
        _height = @(screenSize.height);
        _width = @(screenSize.width);
        _density = @(UIScreen.mainScreen.scale);
    }

    return self;
}

- (NSDictionary *)mapped {
    NSMutableDictionary *valuesMapped = [NSMutableDictionary dictionary];
    valuesMapped[@"density"] = self.density;
    valuesMapped[@"height"] = self.height;
    valuesMapped[@"width"] = self.width;

    return valuesMapped;
}

@end
