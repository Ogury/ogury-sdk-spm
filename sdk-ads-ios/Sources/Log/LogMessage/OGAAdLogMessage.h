//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OguryCore/OguryAbstractLogMessage.h>
#import "OGAAdConfiguration.h"
#import <OguryCore/OguryStringFormattable.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAAdLogMessage : OguryAbstractLogMessage <OguryStringFormattable>

#pragma mark - Properties

@property(nonatomic, strong, readonly) OGAAdConfiguration *adConfiguration;

#pragma mark - Initialization

- (instancetype)initWithLevel:(OguryLogLevel)level
              adConfiguration:(OGAAdConfiguration *)adConfiguration
                      message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
