//
//  NSDateFormatter+NSDateFormatter_Utils.m
//  PresageSDK
//
//  Created by Valeriu POPA on 10/25/18.
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "NSDateFormatter+OGAUtils.h"

@implementation NSDateFormatter (OGAUtils)
+ (NSDateFormatter *)oguryAdsUtcDateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"US"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}
@end
