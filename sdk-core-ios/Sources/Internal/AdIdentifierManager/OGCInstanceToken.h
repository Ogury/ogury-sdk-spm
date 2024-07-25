//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGCInstanceToken : NSObject <NSSecureCoding>

#pragma mark - Properties

@property (nonatomic, copy, readonly) NSString *instanceTokenID;
@property (nonatomic, readonly) NSInteger iosVersion;

#pragma mark - Initialization

- (id)initWithInstanceToken:(NSString *)instanceTokenID;

#pragma mark - Properties

- (void)updateIOSVersionWith:(NSProcessInfo *)processInfo;
- (BOOL)requireIOS14MigrationWith:(NSProcessInfo *)processInfo;

@end

NS_ASSUME_NONNULL_END
