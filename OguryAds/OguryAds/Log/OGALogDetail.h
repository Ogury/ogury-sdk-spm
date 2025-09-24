//
//  OGALogDetail.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 05/11/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGALogDetail : NSObject
@property(nonatomic, copy) NSString *origin;
- (instancetype)initWithOrigin:(NSString *)origin;
@end

NS_ASSUME_NONNULL_END
