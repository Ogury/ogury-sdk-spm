//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGAUnloadAdAction.h"
#import "OGAAdContainer.h"

@implementation OGAUnloadAdAction

#pragma mark - Constants

NSString *const OGAUnloadAdActionName = @"unload";

#pragma mark - Initialization

- (instancetype)initWithNextAd:(OGANextAd *_Nullable)nextAd {
    if (self = [super init]) {
        _name = OGAUnloadAdActionName;
        _nextAd = nextAd;
    }

    return self;
}

#pragma mark - Methods

- (BOOL)performAction:(OGAAdContainer *)adContainer error:(OguryAdError **)error {
    return [adContainer performAction:self.name error:error];
}

@end
