//
//  OGASdkConsumer.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 05/02/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGASdkConsumer : NSObject
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *version;
- (instancetype)initWithName:(NSString *_Nonnull)name version:(NSString *_Nonnull)version;
@end

NS_ASSUME_NONNULL_END
