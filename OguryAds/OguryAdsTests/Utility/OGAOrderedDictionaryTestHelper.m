//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#import "OGAOrderedDictionaryTestHelper.h"

@implementation OGAOrderedDictionaryTestHelper

+ (BOOL)testDictionary:(OGAMutableOrderedDictionary *)dict against:(NSString *)jsonString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingFragmentsAllowed error:nil];
    NSString *objectString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [[jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:
                                                                                                               [objectString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

@end
