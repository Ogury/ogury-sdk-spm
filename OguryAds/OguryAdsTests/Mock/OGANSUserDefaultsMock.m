//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGANSUserDefaultsMock.h"

@interface OGANSUserDefaultsMock ()

@property BOOL isLocked;

@end

@implementation OGANSUserDefaultsMock

- (id)init {
    if (self = [super init]) {
        _dict = [NSMutableDictionary dictionary];
        _isLocked = NO;
    }
    return self;
}

- (nullable NSString *)dataForKey:(NSString *)defaultName {
    return [self.dict valueForKey:defaultName];
}

- (void)setObject:(nullable id)value forKey:(NSString *)defaultName {
    if (!self.isLocked) {
        [self.dict setObject:value forKey:defaultName];
    }
}

- (nullable id)objectForKey:(NSString *)defaultName {
    if (!self.isLocked) {
        return [self.dict valueForKey:defaultName];
    }
    return [self.dict valueForKey:defaultName];
}

- (NSString *)stringForKey:(NSString *)defaultName {
    if (!self.isLocked) {
        return [self.dict valueForKey:defaultName];
    }
    return [self.dict valueForKey:defaultName];
}

- (void)removeObjectForKey:(NSString *)defaultName {
    [self.dict removeObjectForKey:defaultName];
}

- (NSDictionary<NSString *, id> *)dictionaryRepresentation {
    return self.dict;
}

- (void)lockUserDefault {
    self.isLocked = YES;
}

- (void)unlockUserDefault {
    self.isLocked = NO;
}

- (BOOL)synchronize {
    return YES;
}

@end
