//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "OGAUserDefaultsStore.h"

@interface OGAUserDefaultsStore ()

@property(nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation OGAUserDefaultsStore

#pragma mark - Methods

+ (instancetype)shared {
    static OGAUserDefaultsStore *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.userDefaults = NSUserDefaults.standardUserDefaults;
    });

    return instance;
}

- (void)setObject:(id)object forKey:(NSString *)key {
    [self.userDefaults setObject:object forKey:key];
}

- (NSData *_Nullable)dataForKey:(NSString *)key {
    return [self.userDefaults dataForKey:key];
}

- (NSString *_Nullable)stringForKey:(NSString *)key {
    return [self.userDefaults stringForKey:key];
}

- (void)removeObjectForKey:(NSString *)defaultName {
    [self.userDefaults removeObjectForKey:defaultName];
}

@end
