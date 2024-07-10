//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryLog.h>
#import <OguryCore/OguryEventEntry.h>
#import "OGAAdConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface OguryLog (Ads)

- (void)ogaLogAdMessage:(OguryLogLevel)level adConfiguration:(OGAAdConfiguration *)adConfiguration message:(NSString *)message;

- (void)ogaLogMraidMessage:(OguryLogLevel)level adConfiguration:(OGAAdConfiguration *)adConfiguration webViewId:(NSString *)webViewId message:(NSString *)message;

- (void)ogaLogEventBusMessage:(OguryLogLevel)level eventEntry:(OguryEventEntry *)eventEntry message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
