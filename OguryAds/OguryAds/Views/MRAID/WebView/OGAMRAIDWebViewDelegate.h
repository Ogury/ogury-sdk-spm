//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OGAMRAIDWebViewDelegate <NSObject>

#pragma mark - Methods

- (void)webViewReady:(NSString *)adID;

- (void)webViewNotReady:(NSString *)adID;

@end
