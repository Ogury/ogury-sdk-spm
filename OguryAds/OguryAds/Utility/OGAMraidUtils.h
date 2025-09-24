//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OGAAdConfiguration.h"
#import "OGAMRAIDState.h"

NS_ASSUME_NONNULL_BEGIN

@class OGAAd;

@interface OGAMraidUtils : NSObject

+ (NSString *)getMraidStringFromState:(OGAMRAIDState)mraidState;

+ (NSString *)closeButtonBase64;
+ (UIImage *_Nullable)decodeBase64ToImage:(NSString *)strEncodeData;

@end

NS_ASSUME_NONNULL_END
