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
            append(.adLoaded(canShow: true))
        } catch {
            append(.adDidFailToLoad(error))
        }
    }
    
    override func show() {
        Task { @MainActor [weak self] in
            guard let viewController = self?.viewController else { return }
            self?.ad?.present(from: viewController)
        }
    }
    
    override class func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        guard let adType = AdMobAdType(rawValue: container.adType) else { throw .invalidAdType }
        return AdMobInterstitialManager(adType: adType,
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
