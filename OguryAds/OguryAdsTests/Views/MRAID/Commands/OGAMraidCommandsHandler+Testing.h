//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGAMraidCommandsHandler.h"
#import "OGALog.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAMraidCommandsHandler (Testing)

#pragma mark - Properties

@property(nonatomic, strong) UIApplication *application;

#pragma mark - Initialization

- (instancetype)initWithDelegate:(id<OGAMraidCommandsHandlerDelegate>)delegate mraidWebView:(OGAMraidAdWebView *)mraidWebView application:(UIApplication *)application log:(OGALog *)log;

#pragma mark - Methods

- (void)useCustomClose:(OGAMraidCommand *)command;

- (void)adEvent:(OGAMraidCommand *)command;

- (void)openURL:(OGAMraidCommand *)command;

- (void)bunaZiua:(OGAMraidCommand *)command;

- (void)sendLoadCommands;

@end

NS_ASSUME_NONNULL_END
