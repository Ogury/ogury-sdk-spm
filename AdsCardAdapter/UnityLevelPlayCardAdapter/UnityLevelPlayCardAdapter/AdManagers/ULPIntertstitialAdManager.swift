//
//  ULPIntertstitialAdManager.swift
//  UnityLevelPlayCardAdapter
//
//  Created by Jerome TONNELIER on 07/05/2025.
//

import UIKit
import IronSource
import AdsCardAdapter
import AdsCardLibrary

class ULPIntertstitialAdManager: ULPAdManager {
    var ad: LPMInterstitialAd!
    
    override func instanciateAd() async {
        guard ad == nil else { return }
        ad = .init(adUnitId: adType.adUnit)
        ad.setDelegate(proxy)
    }
    
    override func resetAd() {
        ad = nil
    }
    
    override func load() async {
        await super.load()
        ad.loadAd()
    }
    
    override func show() {
        guard let viewController else { return }
        ad.showAd(viewController: viewController, placementName: nil)
    }
    
    override class func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        guard let adType = AdType(rawValue: container.adType) else { throw .invalidAdType }
        return ULPIntertstitialAdManager(adType: adType,
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
