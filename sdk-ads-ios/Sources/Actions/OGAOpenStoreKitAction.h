//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAOpenStoreKitAction : NSObject <OGAAdAction>

#pragma mark - Constants

extern NSString *const OGAOpenStoreKitActionName;

#pragma mark - Properties

@property(nonatomic, strong) NSString *name;

#pragma mark - Initialization

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
