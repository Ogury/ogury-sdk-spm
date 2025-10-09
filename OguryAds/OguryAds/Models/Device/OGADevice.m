//
//  Device.m
//  PresageSDK
//
//  Created by Valeriu POPA on 9/4/18.
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGADevice.h"

#import <UIKit/UIKit.h>
#import <sys/utsname.h>

#import "OGAConfigurationUtils.h"

@implementation OGADevice

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = [OGADevice machineCode];
        self.osVersion = UIDevice.currentDevice.systemVersion;
        self.screen = [[OGAScreen alloc] init];
        self.phoneArch = [OGAConfigurationUtils cpuArchitecture];
    }
    return self;
}

+ (NSString *)machineCode {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)mapped {
    NSMutableDictionary *valuesMapped = [NSMutableDictionary dictionary];
    valuesMapped[@"os_version"] = self.osVersion;
    valuesMapped[@"os"] = @"iOS";
    return valuesMapped;
}

@end
