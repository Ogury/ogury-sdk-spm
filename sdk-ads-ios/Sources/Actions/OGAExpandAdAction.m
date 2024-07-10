//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAExpandAdAction.h"
#import "OGAAdContainer.h"

@implementation OGAExpandAdAction

#pragma mark - Constants

NSString *const OGAExpandAdActionName = @"expand";

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        _name = OGAExpandAdActionName;
    }
    return self;
}

#pragma mark - Methods

- (BOOL)performAction:(OGAAdContainer *)adContainer error:(OguryError **)error {
    return [adContainer performAction:self.name error:error];
}

@end
