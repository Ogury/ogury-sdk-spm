//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OGAViewControllerOrientationHelper : NSObject
- (UIInterfaceOrientationMask)orientationMaskFromRawValue:(NSNumber *)rawValue;
- (UIInterfaceOrientationMask)orientationMaskFromInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (UIInterfaceOrientation)orientationFromInterfaceOrientationMask:(UIInterfaceOrientationMask)orientation;
- (UIInterfaceOrientation)orientationFromRawValue:(NSNumber *)rawValue;
- (BOOL)orientationIsSupportedByApplication:(UIInterfaceOrientationMask)orientation;
- (NSString *)stringFrom:(UIInterfaceOrientation)orientation;
@end

NS_ASSUME_NONNULL_END
