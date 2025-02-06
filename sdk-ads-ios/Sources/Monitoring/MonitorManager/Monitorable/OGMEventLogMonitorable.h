//
//  OGMEventLogMonitorable.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 06/11/2024.
//  Copyright © 2024 Ogury Ltd. All rights reserved.
//

#ifndef OGMEventLogMonitorable_h
#define OGMEventLogMonitorable_h
#import <Foundation/Foundation.h>
@class OGAAdConfiguration;

@protocol OGMEventLogMonitorable <NSObject, NSCoding>

@property(nonatomic, retain) OGAAdConfiguration *adConfiguration;

@end

#endif /* OGMEventLogMonitorable_h */
