//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (OGWUtility)

+ (BOOL)ogwString:(NSString * _Nullable)string isEqualToString:(NSString * _Nullable)anotherString;

+ (BOOL)ogwIsNilOrEmpty:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
