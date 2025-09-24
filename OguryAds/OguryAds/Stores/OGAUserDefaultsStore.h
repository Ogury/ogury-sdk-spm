//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAUserDefaultsStore : NSObject

#pragma mark - Methods

+ (instancetype)shared;

- (void)setObject:(id)value forKey:(NSString *)key;

- (NSData *_Nullable)dataForKey:(NSString *)key;

- (NSString *_Nullable)stringForKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)defaultName;

@end

NS_ASSUME_NONNULL_END
