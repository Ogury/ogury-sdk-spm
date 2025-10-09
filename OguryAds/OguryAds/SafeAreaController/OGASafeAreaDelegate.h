//
// Copyright (c) 2021 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol OGASafeAreaDelegate <NSObject>

- (void)safeAreaChanged:(CGRect)frame;

@end
