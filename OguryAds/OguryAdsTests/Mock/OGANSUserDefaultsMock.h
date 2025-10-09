//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGANSUserDefaultsMock : NSUserDefaults

@property(nonatomic, strong) NSMutableDictionary *dict;

- (void)lockUserDefault;
- (void)unlockUserDefault;

@end

NS_ASSUME_NONNULL_END
