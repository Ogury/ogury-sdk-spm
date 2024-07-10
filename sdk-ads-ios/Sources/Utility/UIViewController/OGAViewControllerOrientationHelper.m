//
//  Copyright © 2022 Ogury Ltd. All rights reserved.
//

#import "OGAViewControllerOrientationHelper.h"

@interface OGAViewControllerOrientationHelper ()
@property(nonatomic, assign) NSBundle *bundle;
- (UIInterfaceOrientationMask)maskFromRawInterfaceOrientationString:(NSString *)string;
@end

@implementation OGAViewControllerOrientationHelper

- (instancetype)initWithBundle:(NSBundle *)bundle {
    _bundle = bundle;
    return [super init];
}

- (instancetype)init {
    return [self initWithBundle:[NSBundle mainBundle]];
}

/// Converts an UIInterfaceOrientation to UIInterfaceOrientationMask
/// - Parameter orientationMask: the UIInterfaceOrientation to convert
- (UIInterfaceOrientationMask)orientationMaskFromRawValue:(NSNumber *)rawValue {
    switch ([rawValue unsignedIntValue]) {
        case UIInterfaceOrientationMaskPortrait:
            return UIInterfaceOrientationMaskPortrait;
        case UIInterfaceOrientationMaskLandscape:
            return UIInterfaceOrientationMaskLandscape;
        case UIInterfaceOrientationMaskLandscapeLeft:
            return UIInterfaceOrientationMaskLandscapeLeft;
        case UIInterfaceOrientationMaskLandscapeRight:
            return UIInterfaceOrientationMaskLandscapeRight;
        case UIInterfaceOrientationMaskPortraitUpsideDown:
            return UIInterfaceOrientationMaskPortraitUpsideDown;
        case UIInterfaceOrientationMaskAllButUpsideDown:
            return UIInterfaceOrientationMaskAllButUpsideDown;
        default:
            return UIInterfaceOrientationMaskAll;
    }
}

/// returns UIInterfaceOrientationMask from an NSNumber init with an unsignedfInteger UIInterfaceOrientationMask raw value
/// - Parameter rawValue: an NSNumber init with an unsignedfInteger UIInterfaceOrientationMask raw value
- (UIInterfaceOrientationMask)orientationMaskFromInterfaceOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationUnknown:
            return UIInterfaceOrientationMaskAll;
        case UIInterfaceOrientationPortrait:
            return UIInterfaceOrientationMaskPortrait;
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationMaskPortraitUpsideDown;
        case UIInterfaceOrientationLandscapeLeft:
            return UIInterfaceOrientationMaskLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return UIInterfaceOrientationMaskLandscapeRight;
    }
}

/// Converts an UIInterfaceOrientationMask to UIInterfaceOrientation
/// - Parameter orientationMask: the UIInterfaceOrientationMask to convert
- (UIInterfaceOrientation)orientationFromInterfaceOrientationMask:(UIInterfaceOrientationMask)orientationMask {
    switch (orientationMask) {
        case UIInterfaceOrientationMaskPortrait:
            return UIInterfaceOrientationPortrait;

        case UIInterfaceOrientationMaskLandscapeLeft:
            return UIInterfaceOrientationLandscapeLeft;

        case UIInterfaceOrientationMaskLandscapeRight:
            return UIInterfaceOrientationLandscapeRight;

        case UIInterfaceOrientationMaskPortraitUpsideDown:
            return UIInterfaceOrientationPortraitUpsideDown;

        case UIInterfaceOrientationMaskLandscape:
            return UIInterfaceOrientationLandscapeLeft;

        case UIInterfaceOrientationMaskAll:
            return UIInterfaceOrientationLandscapeLeft &
                UIInterfaceOrientationLandscapeRight &
                UIInterfaceOrientationPortrait &
                UIInterfaceOrientationPortraitUpsideDown;

        case UIInterfaceOrientationMaskAllButUpsideDown:
            return UIInterfaceOrientationLandscapeLeft &
                UIInterfaceOrientationLandscapeRight &
                UIInterfaceOrientationPortrait;
    }
}

/// returns UIInterfaceOrientation from an NSNumber init with an unsignedfInteger UIInterfaceOrientation raw value
/// - Parameter rawValue: an NSNumber init with an unsignedfInteger UIInterfaceOrientation raw value
- (UIInterfaceOrientation)orientationFromRawValue:(NSNumber *)rawValue {
    switch ([rawValue unsignedIntValue]) {
        case UIInterfaceOrientationPortrait:
            return UIInterfaceOrientationPortrait;

        case UIInterfaceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationPortraitUpsideDown;

        case UIInterfaceOrientationLandscapeLeft:
            return UIInterfaceOrientationLandscapeLeft;

        case UIInterfaceOrientationLandscapeRight:
            return UIInterfaceOrientationLandscapeRight;

        default:
            return UIInterfaceOrientationUnknown;
    }
}

/// Returns a UIInterfaceOrientationMask from a raw String as UIInterfaceOrientation
/// Returns UIInterfaceOrientationMaskAll if the string is not recognized
/// - Parameter string: an UIInterfaceOrientation as String
- (UIInterfaceOrientationMask)maskFromRawInterfaceOrientationString:(NSString *)string {
    if ([string isEqualToString:@"UIInterfaceOrientationPortrait"]) {
        return UIInterfaceOrientationMaskPortrait;
    } else if ([string isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]) {
        return UIInterfaceOrientationMaskLandscapeLeft;
    } else if ([string isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
        return UIInterfaceOrientationMaskLandscapeRight;
    } else if ([string isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"]) {
        return UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    return UIInterfaceOrientationMaskAll;
}

/// Checks if an orientation passed as parameter is supported by application info.plist
/// - Parameter orientation: the orientation to check
- (BOOL)orientationIsSupportedByApplication:(UIInterfaceOrientationMask)orientation {
    NSArray<NSString *> *supportedOrientations = [_bundle objectForInfoDictionaryKey:@"UISupportedInterfaceOrientations"];
    BOOL orientationIsSupported = NO;
    for (int index = 0; index < supportedOrientations.count; index++) {
        if (([self maskFromRawInterfaceOrientationString:supportedOrientations[index]] & orientation) != 0 && orientationIsSupported == NO) {
            orientationIsSupported = YES;
        }
    }
    return orientationIsSupported;
}
- (NSString *)stringFrom:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationUnknown:
            return @"";

        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"portrait";

        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return @"landscape";
    }
}

@end
