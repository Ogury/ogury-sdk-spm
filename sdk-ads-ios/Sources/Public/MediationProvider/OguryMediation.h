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
@property(nonatomic, retain) NSString *_Nullable adapterVersion;

- (instancetype)initWithName:(NSString *_Nonnull)name
                     version:(NSString *_Nonnull)sdkVersion;

- (instancetype)initWithName:(NSString *_Nonnull)name
                     version:(NSString *_Nonnull)sdkVersion
              adapterVersion:(NSString *_Nullable)adapterVersion;
@end

NS_ASSUME_NONNULL_END
