//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "OGAAdDisplayerSystemCloseInformation.h"

@implementation OGAAdDisplayerSystemCloseInformation

- (NSString *)toJavascriptCommand {
    return [NSString stringWithFormat:@"ogySdkMraidGateway.callEventListeners(\"ogyOnCloseSystem\", {})"];
}

@end
