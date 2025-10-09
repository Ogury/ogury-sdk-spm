//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGACloseSKAction.h"
#import "OGAAdContainer.h"

@implementation OGACloseSKAction

#pragma mark - Constants

NSString *const OGACloseSKActionName = @"closeStoreKit";
NSString *const OGACloseSKToFullscreenActionName = @"closeStoreKitToFullscreen";

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        _name = OGACloseSKActionName;
    }
    return self;
}

#pragma mark - Methods

- (BOOL)performAction:(OGAAdContainer *)adContainer error:(OguryAdError **)error {
    if (adContainer.previousStateType == OGAAdContainerStateTypeFullScreenOverlay) {
        return [adContainer performAction:OGACloseSKToFullscreenActionName error:error];
    }
    return [adContainer performAction:self.name error:error];
}

@end
