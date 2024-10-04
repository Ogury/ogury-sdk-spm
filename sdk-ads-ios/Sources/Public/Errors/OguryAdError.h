//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <OguryCore/OguryError.h>
#import <OguryAds/OguryLoadErrorCode.h>
#import <OguryAds/OguryShowErrorCode.h>
#import <OguryAds/OguryBidTokenErrorCode.h>

typedef NS_ENUM(NSInteger, OguryAdErrorType) {
    OguryAdErrorTypeLoad = 0,
    OguryAdErrorTypeShow
};

@interface OguryAdError : OguryError
@property(nonatomic) OguryAdErrorType type;
@property(nonatomic, copy, nullable) NSString *additionalInformation;
@end
