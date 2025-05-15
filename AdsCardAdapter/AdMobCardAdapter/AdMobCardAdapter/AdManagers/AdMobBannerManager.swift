//
//  AdMobIntertstitialManager.swift
//  AdMobCardAdapter
//
//  Created by Jerome TONNELIER on 28/04/2025.
//

import GoogleMobileAds
import AdsCardAdapter
import AdsCardLibrary

class AdMobBannerManager: AdMobManager {
    var ad: BannerView?
    
    override func instanciateAd() async {
        Task { @MainActor in
            guard ad == nil else { return }
            ad = .init(adSize: adFormat == .smallBanner ? AdSizeBanner : AdSizeMediumRectangle)
            ad?.delegate = proxy
            ad?.adUnitID = adType.adUnit
            ad?.rootViewController = viewController
        }
    }
    
    override func resetAd() {
        ad = nil
    }
    
    override func close() {
        ad = nil
        append(.adClosed)
    }
    
    override public func cardDidAppear() {
        if let ad {
            append(.bannerReady(ad))
        }
    }
    
    override func load() async {
        await super.load()
        await instanciateAd()
        await ad?.load(.init())
    }
    
    override func show() {
        guard let ad else { return }
        append(.bannerReady(ad))
    }
    
    override class func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        guard let adType = AdMobAdType(rawValue: container.adType) else { throw .invalidAdType }
        return AdMobBannerManager(adType: adType,
                                  adConfiguration: .init(adUnitId: container.adInformations.adUnitId,
                                                         campaignId: container.adInformations.campaignId,
                                                         creativeId: container.adInformations.creativeId,
                                                         dspCreativeId: container.adInformations.dspCreativeId,
                                                         dspRegion: container.adInformations.dspRegion),
                                  cardConfiguration: .init(oguryTestModeEnabled: container.adInformations.settings.oguryTestModeEnabled,
                                                           rtbTestModeEnabled: container.adInformations.settings.rtbTestModeEnabled,
                                                           qaLabel: container.adInformations.settings.qaLabel),
                                  viewController: nil,
                                  adDelegate: nil)
    }
}
