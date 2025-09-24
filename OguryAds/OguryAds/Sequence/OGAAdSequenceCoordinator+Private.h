//
//  OGAAdSequenceCoordinator+Private.h
//  OguryAdsSDK
//
//  Created by Jerome TONNELIER on 03/01/2025.
//  Copyright © 2025 Ogury Ltd. All rights reserved.
//

#ifndef OGAAdSequenceCoordinator_Private_h
#define OGAAdSequenceCoordinator_Private_h

#import "OGAAdSequenceCoordinator.h"
#import <WebKit/WebKit.h>

@interface OGAAdSequenceCoordinator (Private)
- (void)simulateWebviewTerminated;
- (WKWebView *)adWebview;
@end

#endif /* OGAAdSequenceCoordinator_Private_h */
