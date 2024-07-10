//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGACloseSKAction : NSObject <OGAAdAction>

#pragma mark - Constants

extern NSString *const OGACloseSKActionName;
extern NSString *const OGACloseSKToFullscreenActionName;

#pragma mark - Properties

@property(nonatomic, strong) NSString *name;

#pragma mark - Initialization

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
