//
//  Copyright © 2021 Ogury. All rights reserved.
//

#import "UIWindowScene+OGAActiveScene.h"

@implementation UIWindowScene (OGAActiveScene)

+ (UIWindowScene *_Nullable)getOGAActiveScene {
    for (UIWindowScene *windowScene in UIApplication.sharedApplication.connectedScenes) {
        if (windowScene.activationState == UISceneActivationStateForegroundActive) {
            return windowScene;
        }
    }
    return nil;
}

@end
