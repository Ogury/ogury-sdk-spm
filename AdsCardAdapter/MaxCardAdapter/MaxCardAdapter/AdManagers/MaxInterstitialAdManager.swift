//
//  MaxInterstitialAdManager.swift
//  MaxCardAdapter
//
//  Created by Jerome TONNELIER on 22/04/2025.
//

import AdsCardLibrary
import AdsCardAdapter
import SwiftUI
import Combine
import AppLovinSDK

class MaxInterstitialAdManager: MaxAdManager {
    var ad: MAInterstitialAd!

    override func resetAd() {
        ad = nil
    }
    
    override func instanciateAd() {
        guard ad == nil else { return }
        ad = .init(adUnitIdentifier: adConfiguration.adUnitId)
        ad.delegate = proxy
    }
    
    override func load() {
        super.load()
        instanciateAd()
        ad.load()
    }
    
    override func show() {
        super.show()
        instanciateAd()
        guard ad.isReady else {
            append(.adDidFailToDisplay(MaxError.adNotReady))
            return
        }
        ad.show()
    }
}
