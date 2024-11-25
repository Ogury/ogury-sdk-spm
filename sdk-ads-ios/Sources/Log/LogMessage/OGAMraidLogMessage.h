//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryAbstractLogMessage.h>
#import "OGAAdLogMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class OGAAdConfiguration;

@interface OGAMraidLogMessage : OGAAdLogMessage

#pragma mark - Properties

@property(nonatomic, strong, readonly) NSString *webviewId;

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level
              adConfiguration:(OGAAdConfiguration *)adConfiguration
                    webviewId:(NSString *)webViewId
                      message:(NSString *)message
                         tags:(NSArray<OguryLogTag *> *_Nullable)tags;

- (instancetype)initWithLevel:(OguryLogLevel)level
              adConfiguration:(OGAAdConfiguration *)adConfiguration
                    webviewId:(NSString *)webViewId
                        error:(NSError *)error
                      message:(NSString *_Nullable)message
                         tags:(NSArray<OguryLogTag *> *_Nullable)tags;

@end

NS_ASSUME_NONNULL_END
