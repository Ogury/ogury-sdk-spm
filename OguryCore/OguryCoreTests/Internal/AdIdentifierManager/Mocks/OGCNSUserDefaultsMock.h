//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGCNSUserDefaultsMock : NSUserDefaults

@property (nonatomic, strong) NSMutableDictionary *dict;

- (void)lockUserDefault;
- (void)unlockUserDefault;

@end

NS_ASSUME_NONNULL_END
