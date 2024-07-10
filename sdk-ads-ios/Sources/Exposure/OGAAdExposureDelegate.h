//
// Copyright (c) 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OGAAdExposure;

@protocol OGAAdExposureDelegate <NSObject>
@optional
- (void)exposureDidChange:(OGAAdExposure *)exposure;
@end
