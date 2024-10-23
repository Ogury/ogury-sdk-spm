//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAConditionChecker.h"

@interface OGAAssetKeyChecker : NSObject <OGAConditionChecker>
@property(nonatomic) OguryAdErrorType type;
- (instancetype)initFrom:(OguryAdErrorType)type;
@end
