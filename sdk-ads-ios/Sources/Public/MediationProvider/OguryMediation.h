//
//  OGAMediation.h
//  OguryAds
//
//  Created by Jerome TONNELIER on 22/05/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OguryMediation : NSObject <NSCoding, NSCopying>
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *version;
- (instancetype)initWithName:(NSString *_Nonnull)name version:(NSString *_Nonnull)sdkVersion;
@end

NS_ASSUME_NONNULL_END
