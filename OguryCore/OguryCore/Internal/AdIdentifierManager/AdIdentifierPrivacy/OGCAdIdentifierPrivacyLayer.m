//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OGCAdIdentifierPrivacyLayer.h"
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>

@interface OGCAdIdentifierPrivacyLayer()

@property (nonatomic, strong) ASIdentifierManager *adIdentifierManager;

@end

@implementation OGCAdIdentifierPrivacyLayer

static NSString * const OGCEmptyIDFA = @"00000000-0000-0000-0000-000000000000";

- (id)initAdIdentifierManager:(ASIdentifierManager *)identifierManager {
    if (self = [super init]) {
        _adIdentifierManager = identifierManager;
    }
    
    return self;
}

- (id)init {
    return [self initAdIdentifierManager:[ASIdentifierManager sharedManager]];
}

- (NSString *)adIdentifier {
    return self.adIdentifierManager.advertisingIdentifier.UUIDString.lowercaseString;
}

- (NSString *)vendorIdentifier {
    return [[[[UIDevice currentDevice] identifierForVendor] UUIDString] lowercaseString];
}

- (BOOL)isEmptyIDFA {
    return [[self adIdentifier] isEqualToString:OGCEmptyIDFA];
}

- (NSString *)generateToken {
    return [NSUUID UUID].UUIDString.lowercaseString;
}

@end

