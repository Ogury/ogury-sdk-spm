//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#ifndef OGAAdDisplayerOrientationDelegate_h
#define OGAAdDisplayerOrientationDelegate_h
#import <UIKit/UIKit.h>

@protocol OGAAdDisplayerOrientationDelegate <NSObject>

#pragma mark - Methods

- (void)forceOrientation:(UIInterfaceOrientationMask)orientation;
- (void)allowOrientationChange:(BOOL)allowOrientationChange;

@end

#endif /* OGAAdDisplayerOrientationDelegate_h */
