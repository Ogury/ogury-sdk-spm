//
//  NSDate+NSDate_Formetter.m
//  PresageSDK
//
//  Created by Valeriu POPA on 10/25/18.
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "NSDate+OGAFormatter.h"
#import "NSDateFormatter+OGAUtils.h"

@implementation NSDate (OGAFormatter)

- (NSString *)oguryAdsUtcFormattedString {
    return [[NSDateFormatter oguryAdsUtcDateFormatter] stringFromDate:self];
}

+ (NSNumber *)timestampInMilliseconds {
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    return @(@(timestamp * 1000).longValue);
}

@end
