//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGCUtils.h"

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

#if __has_include(<Flutter/Flutter.h>)
#define __HAS_FLUTTER__
#endif

#if __has_include(<React/RCTBridgeModule.h>)
#define __HAS_REACT_NATIVE__
#endif

@implementation OGCUtils

+ (OGCSDKType)frameworkType {
    OGCSDKType type = OGCSDKTypeNative;
#ifdef __HAS_UNITY__
    type = OGCSDKTypeUnity;
#endif
#ifdef __HAS_CORDOVA__
    type = OGCSDKTypeCordova;
#endif
#ifdef __HAS_XAMARIN__
    type = OGCSDKTypeXamarin;
#endif
#ifdef __HAS_AIR__
    type = OGCSDKTypeAdobeAir;
#endif
#ifdef __HAS_FLUTTER__
    type = OGCSDKTypeFlutter;
#endif
#ifdef __HAS_REACT_NATIVE__
    type = OGCSDKTypeReactNat;
#endif
    return type;
}


@end
