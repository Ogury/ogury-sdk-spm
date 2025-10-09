//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OGAWebViewUserAgentServiceDelegate;

@interface OGAWebViewUserAgentService : NSObject

#pragma mark - Properties

@property(nonatomic, copy, readonly, nullable) NSString *webViewUserAgent;
@property(nonatomic, weak) id<OGAWebViewUserAgentServiceDelegate> delegate;

#pragma mark - Methods

+ (instancetype)shared;

- (void)syncWebViewUserAgent;
- (void)syncWebViewUserAgentAndDispatchDelegate;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
