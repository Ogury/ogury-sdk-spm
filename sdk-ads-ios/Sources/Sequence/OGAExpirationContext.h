//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    OGAdExpirationSourceProfig,
    OGAdExpirationSourceAd,
} OGAdExpirationSource;

@interface OGAExpirationContext : NSObject

@property(nonatomic, strong) NSNumber *expirationTime;
@property(nonatomic) OGAdExpirationSource expirationSource;
@property(nonatomic, readonly) NSNumber *timeSpan;

- (instancetype)initFrom:(OGAdExpirationSource)expirationSource withExpirationTime:(NSNumber *)expirationTime;

@end

NS_ASSUME_NONNULL_END
