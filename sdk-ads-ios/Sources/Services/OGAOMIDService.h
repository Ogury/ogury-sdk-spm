//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGAAd.h"
#import "OGAOMIDSession.h"
#import "OGAMraidBaseWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OGAOMIDService : NSObject

#pragma mark - Properties

@property(nonatomic, assign, readonly) BOOL isOMIDActive;
@property(nonatomic, assign, readonly) BOOL isOMIDFrameworkPresent;

#pragma mark - Intialization

+ (instancetype)shared;

#pragma mark - Methods

- (void)activateOMID;

- (OGAOMIDSession *_Nullable)createSessionForAd:(OGAAd *)ad webView:(OGAMraidBaseWebView *)webView;

+ (int)omidVersion;

@end

NS_ASSUME_NONNULL_END
