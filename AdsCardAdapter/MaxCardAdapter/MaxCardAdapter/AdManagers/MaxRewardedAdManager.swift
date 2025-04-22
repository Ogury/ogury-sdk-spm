//
//  MaxRewardedAdManager.swift
//  MaxCardAdapter
//
//  Created by Jerome TONNELIER on 22/04/2025.
//


import AdsCardLibrary
import AdsCardAdapter
import SwiftUI
import Combine
import AppLovinSDK

class MaxRewardedAdManager: MaxAdManager {
    var ad: MARewardedAd!
    
    override func resetAd() {
        ad = nil
    }
    
    override func instanciateAd() async {
        guard ad == nil else { return }
        ad = .shared(withAdUnitIdentifier: adConfiguration.adUnitId)
        ad.delegate = proxy
    }
    
    override func load() {
        super.load()
        Task {
            await instanciateAd()
            ad.load()
        }
    }
    
    override func show() {
        super.show()
        Task {
            await instanciateAd()
            guard ad.isReady else {
                append(.adDidFailToDisplay(MaxError.adNotReady))
                return
            }
            ad.show()
        }
    }
}
