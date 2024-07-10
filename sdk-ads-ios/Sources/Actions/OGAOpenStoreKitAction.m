//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGAOpenStoreKitAction.h"
#import "OGAAdContainer.h"

@implementation OGAOpenStoreKitAction

#pragma mark - Constants

NSString *const OGAOpenStoreKitActionName = @"openStoreKit";

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        _name = OGAOpenStoreKitActionName;
    }
    return self;
}

#pragma mark - Methods

- (BOOL)performAction:(OGAAdContainer *)adContainer error:(OguryError **)error {
    return [adContainer performAction:self.name error:error];
}

@end
