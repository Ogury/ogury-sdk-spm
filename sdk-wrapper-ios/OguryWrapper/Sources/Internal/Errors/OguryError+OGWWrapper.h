//
//  OguryError+OGWWrapper.h
//  OguryWrapper
//

#import <Foundation/Foundation.h>
#import "OGWWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryError (OGWWrapper)

+ (instancetype)createFailedStartingOguryModuleError:(NSString *)errorMessage;
+ (instancetype)createNoSDKModuleFoundError;

@end

NS_ASSUME_NONNULL_END
