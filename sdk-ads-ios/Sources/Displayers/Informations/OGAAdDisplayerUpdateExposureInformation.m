//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdDisplayerUpdateExposureInformation.h"
#import "OGAAdExposure.h"
#import "OGAAdExposure+MRAID.h"

@implementation OGAAdDisplayerUpdateExposureInformation

#pragma mark - Initialization

- (instancetype)initWithExposure:(OGAAdExposure *)adExposure {
    if (self = [super init]) {
        _adExposure = adExposure;
    }

    return self;
}

#pragma mark - Methods

- (NSString *)toJavascriptCommand {
    return [self.adExposure toMRAIDCommand];
}

@end
