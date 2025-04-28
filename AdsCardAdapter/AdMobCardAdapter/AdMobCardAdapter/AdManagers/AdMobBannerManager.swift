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
            ad?.adUnitID = adType.adUnit
            ad?.rootViewController = viewController
        }
    }
    
    override func resetAd() {
        ad = nil
    }
    
    override func load() async {
        await super.load()
        await ad?.load(.init())
    }
    
    override func show() {
        guard let ad else { return }
        append(.bannerReady(ad))
    }
}
