//
//  Copyright © 2019 Ogury Ltd. All rights reserved.
//

#import "OGAAdExposure.h"

@implementation OGAAdExposure

#pragma mark - Methods

+ (OGAAdExposure *)fullExposure {
    OGAAdExposure *adExposure = [[OGAAdExposure alloc] init];
    adExposure.exposurePercentage = 100;
    return adExposure;
}

+ (OGAAdExposure *)zeroExposure {
    OGAAdExposure *adExposure = [[OGAAdExposure alloc] init];
    adExposure.exposurePercentage = 0;
    return adExposure;
}

@end
