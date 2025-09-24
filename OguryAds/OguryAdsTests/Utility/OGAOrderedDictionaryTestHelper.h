//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAOrderedDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAOrderedDictionaryTestHelper : NSObject
+ (BOOL)testDictionary:(OGAMutableOrderedDictionary *)dict against:(NSString *)jsonString;
@end

NS_ASSUME_NONNULL_END
