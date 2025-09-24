//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGAJSONModel.h"

@interface OGAAdUnit : OGAJSONModel

@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSString *adId;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *size;
@property(nonatomic, strong) NSString *appUserId;
@property(nonatomic, strong) NSString *rewardLaunch;
@property(nonatomic, strong) NSString *rewardName;
@property(nonatomic, strong) NSString *rewardValue;

@end
