//
//  OGALogDetail.m
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 05/11/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import "OGALogDetail.h"

@implementation OGALogDetail
@synthesize origin;
- (instancetype)initWithOrigin:(NSString *)origin {
    if (self = [super init]) {
        self.origin = origin;
    }
    return self;
}
@end
