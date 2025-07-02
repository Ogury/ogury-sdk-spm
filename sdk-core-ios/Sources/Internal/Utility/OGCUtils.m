//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGCUtils.h"
#import "OGCInternal.h"

#if __has_include(<UnityFramework.framework>)
#define __HAS_UNITY__
#endif

#if __has_include(<Cordova.framework>)
#define __HAS_CORDOVA__
#endif

#if __has_include(<Mono.framework>)
#define __HAS_XAMARIN__
#endif

#if __has_include(<AIR.framework>)
#define __HAS_AIR__
#endif

@implementation OGCUtils

+ (OGCSDKType)getFrameworkType {
    OGCSDKType type = OGCSDKTypeNative;
#ifdef __HAS_UNITY__
    type = OGASDKTypeUnity;
#endif
#ifdef __HAS_CORDOVA__
    type = OGASDKTypeCordova;
#endif
#ifdef __HAS_XAMARIN__
    type = OGASDKTypeXamarin;
#endif
#ifdef __HAS_AIR__
    type = OGASDKTypeAdobeAir;
#endif
    return type;
}


@end
