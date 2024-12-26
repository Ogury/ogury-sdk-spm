/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 */

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>

#import <CoreFoundation/CoreFoundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "OGAReachability.h"

#pragma mark IPv6 Support

NSString *kOGAReachabilityChangedNotification = @"kOGAReachabilityChangedNotification";

#pragma mark - Supporting functions

#define kOGYShouldPrintReachabilityFlags 0

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char *comment) {
#if kOGYShouldPrintReachabilityFlags

    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN) ? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable) ? 'R' : '-',

          (flags & kSCNetworkReachabilityFlagsTransientConnection) ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired) ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand) ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress) ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect) ? 'd' : '-',
          comment);
#endif
}

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
#pragma unused(target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject *)info isKindOfClass:[OGAReachability class]], @"info was wrong class in ReachabilityCallback");

    OGAReachability *noteObject = (__bridge OGAReachability *)info;
    // Post a notification to notify the client that the network internetReachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName:kOGAReachabilityChangedNotification object:noteObject];
}

#pragma mark - Reachability implementation

@implementation OGAReachability {
    SCNetworkReachabilityRef _reachabilityRef;
}

+ (instancetype)reachabilityWithHostName:(NSString *)hostName {
    OGAReachability *returnValue = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (reachability != NULL) {
        returnValue = [[self alloc] init];
        if (returnValue != NULL) {
            returnValue->_reachabilityRef = reachability;
        } else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}

+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);

    OGAReachability *returnValue = NULL;

    if (reachability != NULL) {
        returnValue = [[self alloc] init];
        if (returnValue != NULL) {
            returnValue->_reachabilityRef = reachability;
        } else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}

+ (instancetype)reachabilityForInternetConnection {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;

    return [self reachabilityWithAddress:(const struct sockaddr *)&zeroAddress];
}

#pragma mark reachabilityForLocalWiFi

#pragma mark - Start and stop notifier

- (BOOL)startNotifier {
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};

    if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            returnValue = YES;
        }
    }

    return returnValue;
}

- (void)stopNotifier {
    if (_reachabilityRef != NULL) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

- (void)dealloc {
    [self stopNotifier];
    if (_reachabilityRef != NULL) {
        CFRelease(_reachabilityRef);
    }
}

#pragma mark - Network Flag Handling

- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
    PrintReachabilityFlags(flags, "networkStatusForFlags");
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        // The target host is not reachable.
        return NotReachable;
    }

    NetworkStatus returnValue = NotReachable;

    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = ReachableViaWiFi;
    }

    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */

        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = ReachableViaWiFi;
        }
    }

    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = ReachableViaWWAN;
    }

    return returnValue;
}

- (BOOL)connectionRequired {
    NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;

    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }

    return NO;
}

- (NetworkStatus)   currentReachabilityStatus {
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    NetworkStatus returnValue = NotReachable;
    SCNetworkReachabilityFlags flags;

    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        returnValue = [self networkStatusForFlags:flags];
    }

    return returnValue;
}

- (NSString *)currentReachabilityCellularNetwork {
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSDictionary<NSString *, NSString *> *radioAccessTechnologies = networkInfo.serviceCurrentRadioAccessTechnology;
    if (!radioAccessTechnologies || radioAccessTechnologies.count == 0) {
        return @"no network";
    }
    
    NSDictionary<NSString *, NSString *> *networkGenerationMap = @{
        CTRadioAccessTechnologyGPRS: @"2G",
        CTRadioAccessTechnologyEdge: @"2G",
        CTRadioAccessTechnologyCDMA1x: @"2G",
        CTRadioAccessTechnologyWCDMA: @"3G",
        CTRadioAccessTechnologyHSDPA: @"3G",
        CTRadioAccessTechnologyHSUPA: @"3G",
        CTRadioAccessTechnologyCDMAEVDORev0: @"3G",
        CTRadioAccessTechnologyCDMAEVDORevA: @"3G",
        CTRadioAccessTechnologyCDMAEVDORevB: @"3G",
        CTRadioAccessTechnologyeHRPD: @"3G",
        CTRadioAccessTechnologyLTE: @"4G"
    };
    
    if (@available(iOS 14.1, *)) {
        networkGenerationMap = @{
            CTRadioAccessTechnologyNRNSA: @"5G",
            CTRadioAccessTechnologyNR: @"5G"
        };
    }
    
    if (@available(iOS 13.0, *)) {
        NSString *dataServiceIdentifier = networkInfo.dataServiceIdentifier;
        if (dataServiceIdentifier && radioAccessTechnologies[dataServiceIdentifier]) {
            NSString *activeRadioTechnology = radioAccessTechnologies[dataServiceIdentifier];
            return [networkGenerationMap objectForKey:activeRadioTechnology];
        }
    }
    
    return @"no network";
}

- (NSString *)currentReachabilityNetwork {
    NetworkStatus status = [self currentReachabilityStatus];

    switch (status) {
        case ReachableViaWiFi:
            return @"WIFI";
        case ReachableViaWWAN:
            return [self currentReachabilityCellularNetwork];
        default:
            return @"no network";
    }
}

@end
