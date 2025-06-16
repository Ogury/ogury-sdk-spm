//
//  PrebidInterstitialAdManager.swift
//  PrebidCardAdapter
//
//  Created by Jerome TONNELIER on 12/06/2025.
//

import AdsCardAdapter
import AdsCardLibrary
import PrebidMobile

class PrebidInterstitialAdManager: PrebidAdManager {
    var ad: InterstitialRenderingAdUnit?
    
    override func instanciateAd() async {
        ad = InterstitialRenderingAdUnit(configID: adConfiguration.adUnitId, minSizePercentage: CGSize(width: 30, height: 30))
        ad?.delegate = proxy
        if let campaignId {
            let globalValue =
"""
{
    "imp": {
        "ogury": {
            "ext": {
                "adUnitId": "\(adConfiguration.adUnitId)",
                "assetKey": "\(PrebidAdsCardAdapter.assetKey)",
                "testcampaignid": "\(campaignId)"
            }
        }
    }
}
"""
            ad?.setImpORTBConfig(globalValue)
        }
    }
    
    override func resetAd() {
        ad = nil
    }
    
    override func load() async {
        await super.load()
        await instanciateAd()
        ad?.loadAd()
    }
    
    override func show() {
        Task { @MainActor [weak self] in
            guard let self, let viewController = self.viewController else { return }
            self.ad?.show(from: viewController)
        }
    }
    
    override class func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        guard let adType = PrebidAdType(rawValue: container.adType) else { throw .invalidAdType }
        return PrebidInterstitialAdManager(adType: adType,
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
