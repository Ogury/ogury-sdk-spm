//
//  OguryError+OGWWrapper.h
//  OguryWrapper
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryError.h>
#import "OGWWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryError (OGWWrapper)

+ (instancetype)createModuleMissingError;
+ (instancetype)createModuleFailedToStartError:(NSString *)errorMessage;

@end

NS_ASSUME_NONNULL_END
