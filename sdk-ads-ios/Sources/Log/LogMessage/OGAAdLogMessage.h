//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryAbstractLogMessage.h>
#import <OguryCore/OguryLogType.h>
#import "OGAAdConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

extern OguryLogSDK const OguryLogSDKAds;
extern OguryLogType const OguryLogTypeMraid;
extern OguryLogType const OguryLogTypeMonitoring;
extern OguryLogType const OguryLogTypeDelegate;

@interface OGAAdLogMessage : OguryAbstractLogMessage

#pragma mark - Properties

@property(nonatomic, strong, readonly) OGAAdConfiguration *adConfiguration;

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level
              adConfiguration:(OGAAdConfiguration *_Nullable)adConfiguration
                      logType:(OguryLogType)logType
                      message:(NSString *)message
                         tags:(NSArray<OguryLogTag *> *_Nullable)tags;

- (instancetype)initWithLevel:(OguryLogLevel)level
              adConfiguration:(OGAAdConfiguration *_Nullable)adConfiguration
                      logType:(OguryLogType)logType
                        error:(NSError *)error
                         tags:(NSArray<OguryLogTag *> *_Nullable)tags;

@end

NS_ASSUME_NONNULL_END
