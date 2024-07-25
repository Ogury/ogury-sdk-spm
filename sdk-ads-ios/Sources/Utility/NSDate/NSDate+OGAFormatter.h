//
//  NSDate+NSDate_Formetter.h
//  PresageSDK
//
//  Created by Valeriu POPA on 10/25/18.
//  Copyright © 2018 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (OGAFormatter)
- (NSString *)oguryAdsUtcFormattedString;
+ (NSNumber *)timestampInMilliseconds;
@end
