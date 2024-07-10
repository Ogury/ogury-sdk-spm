//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import "OGANextAd.h"
#import "NSString+OGAUtility.h"

@implementation OGANextAd

+ (OGAJSONKeyMapper *)keyMapper {
    return [[OGAJSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"showNextAd" : @"showNextAd",
        @"nextAdId" : @"nextAdId",
    }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"showNextAd"]) {
        return false;
    }

    return true;
}

+ (BOOL)shouldShowNextAd:(OGANextAd *)nextAd {
    return !nextAd || nextAd.showNextAd.boolValue;
}

+ (NSString *)nextAdId:(OGANextAd *)nextAd {
    NSString *nextAdId = nextAd.nextAdId;
    if ([NSString ogaIsNilOrEmpty:nextAdId] || [NSString ogaString:@"null" isEqualToString:nextAdId]) {
        return nil;
    } else {
        return nextAdId;
    }
}

+ (OGANextAd *)nextAdTrue {
    OGANextAd *nextAd = [[OGANextAd alloc] init];
    nextAd.showNextAd = @YES;
    return nextAd;
}

+ (OGANextAd *)nextAdFalse {
    OGANextAd *nextAd = [[OGANextAd alloc] init];
    nextAd.showNextAd = @NO;
    return nextAd;
}

@end
