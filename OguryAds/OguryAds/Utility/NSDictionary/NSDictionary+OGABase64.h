//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (OGABase64)

- (NSString *)ogaEncodeToBase64;

+ (NSDictionary *_Nullable)ogaDecodeFromBase64:(NSString *)jsonString error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
