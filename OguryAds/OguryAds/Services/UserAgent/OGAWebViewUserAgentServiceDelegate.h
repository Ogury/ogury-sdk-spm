//
//  Copyright © 2023 Ogury Ltd. All rights reserved.
//

#ifndef OGAWebViewUserAgentServiceDelegate_h
#define OGAWebViewUserAgentServiceDelegate_h

// PrinterDelegate.h

#import <Foundation/Foundation.h>

@protocol OGAWebViewUserAgentServiceDelegate <NSObject>

- (void)receivedWebViewUserAgent:(NSString *)userAgent;
- (void)maxWebViewUserAgentRetryReached;

@end

#endif /* OGAWebViewUserAgentServiceDelegate_h */
