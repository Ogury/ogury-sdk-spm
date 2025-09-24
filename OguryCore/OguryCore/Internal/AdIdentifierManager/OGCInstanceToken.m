//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "OGCInstanceToken.h"
#import "NSString+OGCHash.h"

#pragma mark - Constants

static NSString * const OGAIOSVersionKey = @"IOS_VERSION";
static NSString * const OGAInstanceTokenIDKey = @"INSTANCE_TOKEN_ID";

@interface OGCInstanceToken()

#pragma mark - Properties

@property (readwrite) NSString *instanceTokenID;
@property (readwrite) NSInteger iosVersion;

@end

@implementation OGCInstanceToken

#pragma mark - Initialization

- (id)initWithInstanceToken:(NSString *)instanceTokenID {
    return [self initWithInstanceToken:instanceTokenID andProcessInfo:[NSProcessInfo processInfo]];
}

- (id)initWithInstanceToken:(NSString *)instanceTokenID andProcessInfo:(NSProcessInfo *)processInfo {
    if (self = [super init]) {
        _instanceTokenID = instanceTokenID;
        _iosVersion = [processInfo operatingSystemVersion].majorVersion;
    }
    return self;
}

#pragma mark - Methods
- (BOOL)requireIOS14MigrationWith:(NSProcessInfo *)processInfo {
    return self.iosVersion < 14 && [processInfo operatingSystemVersion].majorVersion >= 14;
}

- (void)updateIOSVersionWith:(NSProcessInfo *)processInfo {
    self.iosVersion = [processInfo operatingSystemVersion].majorVersion;
}
#pragma mark - NSSecureCoding

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeFloat:self.iosVersion forKey:OGAIOSVersionKey];
    [coder encodeObject:self.instanceTokenID forKey:OGAInstanceTokenIDKey];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        _iosVersion = [coder decodeFloatForKey:OGAIOSVersionKey];
        _instanceTokenID = [coder decodeObjectForKey:OGAInstanceTokenIDKey];
    }

    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
