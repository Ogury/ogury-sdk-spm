//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OGCASIdentifierManagerMock.h"

@implementation OGCASIdentifierManagerMock

- (id)init {
    if (self = [super init]) {
        _customIDFA = nil;
    }
    return self;
}

- (NSUUID *)advertisingIdentifier {
    return (self.customIDFA) ? (self.customIDFA) : ([NSUUID UUID]);
}

@end
