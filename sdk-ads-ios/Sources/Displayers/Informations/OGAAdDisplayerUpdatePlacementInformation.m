//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAdDisplayerUpdatePlacementInformation.h"

@implementation OGAAdDisplayerUpdatePlacementInformation

#pragma mark - Initialization

- (instancetype)initWithPlacement:(OGAAdDisplayerPlacement)placement {
    if (self = [super init]) {
        _placement = placement;
    }

    return self;
}

#pragma mark - Methods

- (NSString *)toJavascriptCommand {
    return [NSString stringWithFormat:@"ogySdkMraidGateway.updatePlacementType(\"%@\")", [OGAAdDisplayerUpdatePlacementInformation stringFromPlacement:self.placement]];
}

+ (NSString *)stringFromPlacement:(OGAAdDisplayerPlacement)placement {
    switch (placement) {
        case OGAAdDisplayerPlacementInline:
            return @"inline";
        case OGAAdDisplayerPlacementInterstitial:
            return @"interstitial";
    }
}

@end
