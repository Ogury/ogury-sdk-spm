//
//  Copyright © 2022 Ogury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OGCUtils.h"

static NSNumber* _Nullable sdkType;

@implementation OGCUtils
+(BOOL)hasFlutterRuntime{
    return NSClassFromString(@"FlutterViewController") != nil;
}

+(BOOL)hasReactNativeRuntime{
    return NSClassFromString(@"RCTBridge") != nil;
}

+(BOOL)hasUnityRuntime {
    return NSClassFromString(@"UnityFramework") != nil;
}

+(BOOL)hasXamarinRuntime{
    return NSClassFromString(@"MonoMethod") != nil || NSClassFromString(@"Xamarin_Forms_Platform_iOS_FormsApplicationDelegate") != nil;
}

+(BOOL)hasCordovaRuntime{
    return NSClassFromString(@"CDVViewController") != nil || NSClassFromString(@"CDVPlugin") != nil;
}

+(BOOL)hasAdobeAirRuntime{
    return NSClassFromString(@"AIRGameController") != nil || NSClassFromString(@"AdobeAIR") != nil;
}

+ (OGCSDKType)frameworkType {
    if (sdkType != nil) {
        return (OGCSDKType)sdkType;
    }
    
    OGCSDKType type = OGCSDKTypeNative;
    if ([self hasUnityRuntime]) {
        type = OGCSDKTypeUnity;
    } else if ([self hasCordovaRuntime]) {
        type = OGCSDKTypeCordova;
    } else if ([self hasXamarinRuntime]) {
        type = OGCSDKTypeXamarin;
    }  else if ([self hasAdobeAirRuntime]) {
        type = OGCSDKTypeAdobeAir;
    } else if ([self hasFlutterRuntime]) {
        type = OGCSDKTypeFlutter;
    } else if ([self hasReactNativeRuntime]) {
        type = OGCSDKTypeReactNat;
    }
    sdkType = @(type);
    return type;
}


@end
