//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OguryCoreErrorType) {
    OguryCoreErrorTypeNoInternetConnection = 0
};

NS_ASSUME_NONNULL_BEGIN

@interface OguryError : NSError

@end

NS_ASSUME_NONNULL_END
