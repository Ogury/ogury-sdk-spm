//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OGAMraidCommandsHandlerDelegate.h"

@class OGAMraidBaseWebView;
@class OGAJavascriptCommandExecutor;
@class OGAMraidCommand;

NS_ASSUME_NONNULL_BEGIN

@interface OGAMraidCommandsHandler : NSObject

#pragma mark - Properties

@property(nonatomic, weak) id<OGAMraidCommandsHandlerDelegate> delegate;
@property(nonatomic, weak) OGAMraidBaseWebView *mraidWebView;
@property(nonatomic, strong) OGAJavascriptCommandExecutor *commandExecutor;

#pragma mark - Initialization

- (instancetype)initWithDelegate:(id<OGAMraidCommandsHandlerDelegate>)delegate mraidWebView:(OGAMraidBaseWebView *)mraidWebView;

#pragma mark - Methods

- (void)handleMraidCommand:(OGAMraidCommand *)command;

- (void)closeAd:(OGAMraidCommand *)command;

- (void)sendLoadCommands;

@end

NS_ASSUME_NONNULL_END
