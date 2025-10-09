//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAJSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAProfigResponseError : OGAJSONModel

@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *message;

@end

NS_ASSUME_NONNULL_END
