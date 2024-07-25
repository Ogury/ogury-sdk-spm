//
//  Copyright © 2020 Ogury Ltd. All rights reserved.
//

#import "UIApplication+Orientation.h"
#import "OGADeviceOrientationConstants.h"

@implementation UIApplication (Orientation)

- (NSString *)OGAOrientationString {
    return [UIApplication orientationStringForApplication:self];
}

+ (NSString *_Nullable)orientationStringForApplication:(UIApplication *)application {
    if (@available(iOS 13.0, *)) {
        // Use window scene to get interface orientation
        UIWindowScene *mainWindowScene;
        for (UIWindowScene *windowScene in application.connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                mainWindowScene = windowScene;
                break;
            }
        }

        UIInterfaceOrientation interfaceOrientation;

        if (mainWindowScene) {
            interfaceOrientation = mainWindowScene.interfaceOrientation;
        } else {
            // Fallback to status bar orientation (deprecated in iOS 13)
            interfaceOrientation = application.statusBarOrientation;
        }

        switch (interfaceOrientation) {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                return OGAOrientationStringPortrait;

            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                return OGAOrientationStringLandscape;

            default:
                return nil;
        }
    } else {
        return nil;
    }
}

@end
