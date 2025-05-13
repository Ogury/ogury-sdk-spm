//
//  MaxBannerAdManager.swift
//  MaxCardAdapter
//
//  Created by Jerome TONNELIER on 22/04/2025.
//

import AdsCardLibrary
import AdsCardAdapter
import SwiftUI
import Combine
import AppLovinSDK

class MaxBannerAdManager: MaxAdManager {
    var ad: MAAdView!
    
    override func resetAd() {
        ad = nil
    }
    
    override func instanciateAd() async {
        guard ad == nil else { return }
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.ad = .init(adUnitIdentifier: self.adConfiguration.adUnitId, adFormat: adType == .default(.smallBanner) ? .banner : .mrec)
            self.ad.delegate = self.proxy
            self.ad.frame = .init(origin: .zero, size: sizeForAd())
        }
    }
    
    private func sizeForAd() -> CGSize {
        .init(width: adType == .default(.smallBanner) ? 320 : 300,
              height: adType == .default(.smallBanner) ? 50 : 250,)
    }
    
    override func load() {
        super.load()
        Task { @MainActor [weak self] in
            await self?.instanciateAd()
            self?.ad.loadAd()
        }
    }
    
    override func show() {
        super.show()
        Task { @MainActor [weak self] in
            guard let self else { return }
            await self.instanciateAd()
            self.append(.bannerReady(self.ad))
        }
    }
    
    override func close() {
        ad?.removeFromSuperview()
        ad.delegate = nil
        ad =  nil
    }
    
    override class func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        guard let adType = MaxAdType(rawValue: container.adType) else { throw .invalidAdType }
        return MaxBannerAdManager(adType: adType,
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
