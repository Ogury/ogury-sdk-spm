//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AdSupport/AdSupport.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGCASIdentifierManagerMock : ASIdentifierManager

@property (nonatomic, strong, nullable) NSUUID *customIDFA;

@end

NS_ASSUME_NONNULL_END
