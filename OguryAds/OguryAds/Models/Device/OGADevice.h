//
//  Device.h
//  PresageSDK
//
//  Created by Valeriu POPA on 9/4/18.
//  Copyright © 2018 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAScreen.h"

@interface OGADevice : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) OGAScreen *screen;
@property(nonatomic, strong) NSString *osVersion;
@property(nonatomic, strong) NSString *phoneArch;

- (instancetype)init;
- (NSDictionary *)mapped;

@end
