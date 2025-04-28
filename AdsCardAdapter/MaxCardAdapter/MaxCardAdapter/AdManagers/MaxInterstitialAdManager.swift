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
    
    override func instanciateAd() async {
        guard ad == nil else { return }
        ad = .init(adUnitIdentifier: adConfiguration.adUnitId)
        ad.delegate = proxy
    }
    
    override func load() async {
        await super.load()
        await instanciateAd()
        ad.load()
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
    
    override class func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        guard let adType = MaxAdType(rawValue: container.adType) else { throw .invalidAdType }
        return MaxInterstitialAdManager(adType: adType,
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
