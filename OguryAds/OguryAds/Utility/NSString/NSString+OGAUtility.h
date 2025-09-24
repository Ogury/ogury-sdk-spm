//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (OGAUtility)

+ (BOOL)ogaString:(NSString *_Nullable)string isEqualToString:(NSString *_Nullable)anotherString;

+ (BOOL)ogaIsNilOrEmpty:(NSString *_Nullable)string;

@end

NS_ASSUME_NONNULL_END
