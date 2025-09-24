//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OGAMRAIDWebViewCommandDelegate <NSObject>

- (void)executeCommandForMultiBrowser:(NSString *)command;

@end

NS_ASSUME_NONNULL_END
