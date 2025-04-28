//
//  AdMobIntertstitialManager.swift
//  AdMobCardAdapter
//
//  Created by Jerome TONNELIER on 28/04/2025.
//

import GoogleMobileAds
import AdsCardAdapter
import AdsCardLibrary

class AdMobInterstitialManager: AdMobManager {
    var ad: InterstitialAd?
    
    override func instanciateAd() async {
        // with AdMob, the ad is returned from the load
    }
    
    override func resetAd() {
        ad = nil
    }
    
    override func load() async {
        await super.load()
        do {
            ad = try await InterstitialAd.load(with: adType.adUnit, request: Request())
            ad?.fullScreenContentDelegate = proxy
        } catch {
            append(.adDidFailToLoad(error))
        }
        
    }
    
    override func show() {
        guard let viewController else { return }
        ad?.present(from: viewController)
    }
}
