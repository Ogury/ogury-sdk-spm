//
//  Copyright © 2019 Ogury Ltd. All rights reserved.
//

#import "OGAOMIDService.h"
#import <OMSDK_Ogury/OMIDSDK.h>
#import "OGALog.h"
#import "OGAWKWebView.h"

@interface OGAOMIDService ()

@property(nonatomic, strong) OMIDOgurySDK *omidSDK;
@property(nonatomic, strong) OGALog *log;

@end

@implementation OGAOMIDService

#pragma mark - Initialization

+ (instancetype)shared {
    static OGAOMIDService *instance = nil;
    static dispatch_once_t onceToken;
    if ([NSThread isMainThread]) {
        dispatch_once(&onceToken, ^{
            instance = [[self alloc] init];
        });
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            dispatch_once(&onceToken, ^{
                instance = [[self alloc] init];
            });
        });
    }

    return instance;
}

- (instancetype)init {
    return [self initWithOMIDSDK:[OMIDOgurySDK sharedInstance] log:[OGALog shared]];
}

- (instancetype)initWithOMIDSDK:(OMIDOgurySDK *)omidSDK log:(OGALog *)log {
    if (self = [super init]) {
        _omidSDK = omidSDK;
        _log = log;
    }

    return self;
}

#pragma mark - Properties

- (BOOL)isOMIDActive {
    return self.omidSDK.isActive;
}

- (BOOL)isOMIDFrameworkPresent {
    // If one day we decide to properly implements weak dependencies.
    return YES;
}

+ (int)omidVersion {
    return 3;
}

#pragma mark - Methods

- (void)activateOMID {
    [self.log log:OguryLogLevelDebug message:@"[OMID] Activating"];

    [self.omidSDK activate];
}

- (OGAOMIDSession *_Nullable)createSessionForAd:(OGAAd *)ad webView:(OGAMraidBaseWebView *)webView {
    if (!self.isOMIDActive || !ad.omidEnabled || ![webView.webViewId isEqualToString:OGANameMainWebView]) {
        return nil;
    }
    return [[OGAOMIDSession alloc] initWithWebView:webView.wkWebView];
}

@end
