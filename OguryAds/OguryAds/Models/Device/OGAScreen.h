//
//  Device.h
//  PresageSDK
//
//  Created by Valeriu POPA on 9/4/18.
//  Copyright © 2018 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OGAScreen : NSObject

@property(nonatomic, strong) NSNumber *density;
@property(nonatomic, strong) NSNumber *height;
@property(nonatomic, strong) NSNumber *width;

- (instancetype)init;
- (NSDictionary *)mapped;

@end
