//
//  AdParser.h
//  PresageSDK
//
//  Created by Valeriu POPA on 10/26/18.
//  Copyright © 2018 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAAd.h"
#import "OGAMonitoringDispatcher.h"

@interface OGAAdParser : NSObject

+ (NSArray *)parseJSONResponse:(NSDictionary *)json
               adConfiguration:(OGAAdConfiguration *)adConfig
          privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration
                         error:(NSError *_Nonnull *_Nonnull)error
          monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher;

+ (OGAAd *)parseAdJSON:(NSDictionary *)adJSON
         adConfiguration:(OGAAdConfiguration *)adConfig
    privacyConfiguration:(OGAAdPrivacyConfiguration *)privacyConfiguration
                   error:(NSError *_Nonnull *_Nonnull)error
    monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher;

@end
