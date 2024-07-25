//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAdAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAExpandAdAction : NSObject <OGAAdAction>

#pragma mark - Constants

extern NSString *const OGAExpandAdActionName;

#pragma mark - Properties

@property(nonatomic, strong) NSString *name;

@end

NS_ASSUME_NONNULL_END
