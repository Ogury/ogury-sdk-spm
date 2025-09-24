//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGABaseAdContainerState+Testing.h"

@implementation OGABaseAdContainerState (Testing)

- (void)overrideDisplayer:(id<OGAAdDisplayer>)displayer {
    self.displayer = displayer;
}

@end
