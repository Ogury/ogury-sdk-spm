//
//  Copyright © 2020-present Ogury. All rights reserved.
//

#import "NSString+OGCHash.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSString (OGCHash)

- (NSString *)oguryCoreSha256HashWithSalt:(NSString *)salt {
    NSString *saltedString = [self stringByAppendingString:salt];
    NSData *data = [saltedString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *sha256Data = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([data bytes], (CC_LONG)[data length], [sha256Data mutableBytes]);
    return [sha256Data base64EncodedStringWithOptions:0];
}

+ (NSString *)oguryCoreRandomSaltOfSize:(int)length {
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [alphabet characterAtIndex:arc4random() % [alphabet length]]];
    }
    return randomString;
}

@end
