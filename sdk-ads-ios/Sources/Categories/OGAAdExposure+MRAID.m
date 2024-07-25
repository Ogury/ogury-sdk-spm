//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAAdExposure+MRAID.h"

@implementation OGAAdExposure (MRAID)

#pragma mark - Methods

- (NSString *)toMRAIDCommand {
    NSString *occlusionRectString = @"";

    for (NSValue *valueRect in self.occlusionRectangles) {
        if (![occlusionRectString isEqualToString:@""]) {
            occlusionRectString = [occlusionRectString stringByAppendingString:@","];
        }

        CGRect rect = [valueRect CGRectValue];
        NSString *oclusionString = [NSString stringWithFormat:@"{x: %i, y: %i, width: %i, height: %i}",
                                                              @(rect.origin.x).intValue,
                                                              @(rect.origin.y).intValue,
                                                              @(rect.size.width).intValue,
                                                              @(rect.size.height).intValue];
        occlusionRectString = [occlusionRectString stringByAppendingString:oclusionString];
    }

    NSString *visibleRectString;
    if (!CGRectIsEmpty(self.visibleRectangle)) {
        visibleRectString = [NSString stringWithFormat:@"visibleRectangle:{x: %i, y: %i, width: %i, height: %i}",
                                                       @(self.visibleRectangle.origin.x).intValue,
                                                       @(self.visibleRectangle.origin.y).intValue,
                                                       @(self.visibleRectangle.size.width).intValue,
                                                       @(self.visibleRectangle.size.height).intValue];
    } else {
        visibleRectString = @"visibleRectangle: null";
    }

    return [NSString stringWithFormat:@"ogySdkMraidGateway.updateExposure({exposedPercentage:%.1f, %@, occlusionRectangles: [%@]})", self.exposurePercentage, visibleRectString, occlusionRectString];
}

@end
