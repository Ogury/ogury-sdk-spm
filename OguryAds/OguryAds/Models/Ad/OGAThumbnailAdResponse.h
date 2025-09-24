//
//  OGAThumbnailAdResponse.h
//  OguryAds
//
//  Created by Mihai-Cristian SAVA on 9/5/19.
//  Copyright © 2019 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAJSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAThumbnailAdResponse : OGAJSONModel

@property(nonatomic, strong) NSString *width;
@property(nonatomic, strong) NSString *draggable;
@property(nonatomic, strong) NSNumber *disableMultiActivity;
@property(nonatomic, strong) NSString *height;

@end

NS_ASSUME_NONNULL_END
