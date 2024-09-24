//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGACloseAdAction.h"
#import "OGAAdContainer.h"
#import "OguryAdError.h"

@implementation OGACloseAdAction

#pragma mark - Constants

NSString *const OGACloseAdActionName = @"close";

#pragma mark - Initialization

- (instancetype)initWithNextAd:(OGANextAd *_Nullable)nextAd {
    if (self = [super init]) {
        _name = OGACloseAdActionName;
        _nextAd = nextAd;
    }

    return self;
}

#pragma mark - Methods

- (BOOL)performAction:(OGAAdContainer *)adContainer error:(OguryAdError **)error {
    return [adContainer performAction:self.name error:error];
}

@end
