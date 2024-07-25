//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGAExpirationContext.h"

@interface OGAExpirationContext ()
@property(nonatomic, strong) NSDate *startDate;
@end

@implementation OGAExpirationContext

- (instancetype)initFrom:(OGAdExpirationSource)expirationSource withExpirationTime:(NSNumber *)expirationTime {
    if (self = [super init]) {
        self.expirationSource = expirationSource;
        self.expirationTime = expirationTime;
        self.startDate = [NSDate date];
    }
    return self;
}

- (NSNumber *)timeSpan {
    return @([[NSDate date] timeIntervalSinceDate:self.startDate]);
}

@end
