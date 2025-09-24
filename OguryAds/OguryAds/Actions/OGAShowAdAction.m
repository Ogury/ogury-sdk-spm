//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import "OGAShowAdAction.h"
#import "OGAAdContainer.h"

#pragma mark - Constants

NSString *const OGAShowAdActionName = @"show";

@implementation OGAShowAdAction

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        _name = OGAShowAdActionName;
    }

    return self;
}

#pragma mark - Methods

- (BOOL)performAction:(nonnull OGAAdContainer *)adContainer error:(OguryAdError *_Nullable *_Nullable)error {
    return [adContainer performAction:self.name error:error];
}

@end
