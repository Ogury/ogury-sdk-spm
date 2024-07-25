//
//  Copyright © 2021 Ogury Ltd. All rights reserved.
//

#import "OGAAdLandingPagePrefetcher.h"
#import "OGAMraidAdWebView.h"

@interface OGAAdLandingPagePrefetcher ()

#pragma mark - Properties

@property(nonatomic, strong) NSMutableDictionary<NSString *, UIView *> *landingPages;

@end

@implementation OGAAdLandingPagePrefetcher

#pragma mark - Methods

+ (OGAAdLandingPagePrefetcher *)shared {
    static OGAAdLandingPagePrefetcher *instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        _landingPages = [[NSMutableDictionary alloc] init];
    }

    return self;
}

#pragma mark - Methods

- (void)prefetchLandingPageForAd:(OGAAd *)ad {
#warning FIXME : review this feature after GA
    /*
    // If landing page URL is present, we should pre-load the landing page
    OGAMraidBaseView *landingPage = [[OGAMraidBaseView alloc] initWithAd:ad];

    [landingPage setupMKWebView];

    // Start loading landing page
    [landingPage loadWithURL:ad.landingPagePrefetchURL];

    @synchronized (self.landingPages) {
        self.landingPages[ad.identifier] = landingPage;
    }
     */
}

- (UIView *)landingPageForAd:(OGAAd *)ad {
    @synchronized(self.landingPages) {
        return self.landingPages[ad.identifier];
    }
}

- (void)clearLandingPageForAd:(OGAAd *)ad {
    @synchronized(self.landingPages) {
        self.landingPages[ad.identifier] = nil;
    }
}

@end
