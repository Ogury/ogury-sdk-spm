//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAOpenSKOverlayAction.h"
#import "OGAAdContainer.h"

@implementation OGAOpenSKOverlayAction

#pragma mark - Constants

NSString *const OGAOpenSKOverlayActionName = @"openSKOverlay";

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        _name = OGAOpenSKOverlayActionName;
    }
    return self;
}

#pragma mark - Methods

- (BOOL)performAction:(OGAAdContainer *)adContainer error:(OguryError **)error {
    return [adContainer performAction:self.name error:error];
}

@end
