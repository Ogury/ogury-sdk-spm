//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGCInternal.h"

NS_ASSUME_NONNULL_BEGIN

enum OGCSDKType;

@interface OGCUtils : NSObject

+ (OGCSDKType)frameworkType;

@end

NS_ASSUME_NONNULL_END
