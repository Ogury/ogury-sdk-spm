//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAForceCloseAdAction.h"
#import "OGAAdContainer.h"

@implementation OGAForceCloseAdAction

#pragma mark - Constants

NSString *const OGAForceCloseAdActionName = @"forceClose";

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        _name = OGAForceCloseAdActionName;
    }

    return self;
}

#pragma mark - Methods

- (BOOL)performAction:(OGAAdContainer *)adContainer error:(OguryAdError **)error {
    return [adContainer performAction:self.name error:error];
}

@end
