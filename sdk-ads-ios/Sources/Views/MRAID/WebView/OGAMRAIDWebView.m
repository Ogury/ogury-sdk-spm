//
//  Copyright © 2018 Ogury. All rights reserved.
//

#import "OGAMRAIDWebView.h"
#import "OGAAd.h"
#import "OGAAdConfiguration.h"
#import "OGAMonitoringDispatcher.h"

@interface OGAMRAIDWebView ()

@property(nonatomic, strong) OGAMonitoringDispatcher *monitoringDispatcher;
@property(nonatomic, strong) OGAAdLoadStateManager *stateManager;

@end

@implementation OGAMRAIDWebView

#pragma mark - Initialization

- (instancetype)initWithAd:(OGAAd *)ad stateManager:(OGAAdLoadStateManager *)stateManager {
    return [self initWithAd:ad
                stateManager:stateManager
        monitoringDispatcher:[OGAMonitoringDispatcher shared]];
}

- (instancetype)initWithAd:(OGAAd *)ad
              stateManager:(OGAAdLoadStateManager *)stateManager
      monitoringDispatcher:(OGAMonitoringDispatcher *)monitoringDispatcher {
    if ([super initWithAd:ad]) {
        _stateManager = stateManager;
        CGRect screenBounds = UIScreen.mainScreen.bounds;
        CGFloat topPadding = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGFloat bottomPadding = 0;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
            topPadding = window.safeAreaInsets.top;
            bottomPadding = window.safeAreaInsets.bottom;
        }

        CGSize adSize = CGSizeMake(screenBounds.size.width, screenBounds.size.height - topPadding - bottomPadding);
        if (ad.thumbnailAdResponse && [ad.adUnit.type isEqual:OGAAdConfigurationAdTypeThumbnailAd]) {
            adSize = CGSizeMake(ad.thumbnailAdResponse.width.floatValue, ad.thumbnailAdResponse.height.floatValue);
        } else if (ad.bannerAdResponse && ([ad.adUnit.type isEqual:OGAAdConfigurationAdTypeSmallBanner] || [ad.adUnit.type isEqual:OGAAdConfigurationAdTypeMPU])) {
            adSize = ad.adConfiguration.size;
        }
        self.frame = CGRectMake(0, 0, adSize.width, adSize.height);

        _monitoringDispatcher = monitoringDispatcher;
        [self setupMKWebView];
    }

    return self;
}

#pragma mark - Methods

- (void)setupMKWebView {
    [super setupMKWebView];
    if (self.ad.html.length != 0) {
        self.hasLoaded = YES;
        [self.monitoringDispatcher sendLoadEvent:OGALoadEventLoadAdPrecaching adConfiguration:self.ad.adConfiguration];
    }
    [self loadWithContent:self.ad.html];
}

@end
