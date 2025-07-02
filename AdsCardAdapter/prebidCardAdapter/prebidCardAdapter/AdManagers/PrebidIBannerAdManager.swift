//
//  PrebidInterstitialAdManager.swift
//  PrebidCardAdapter
//
//  Created by Jerome TONNELIER on 12/06/2025.
//

import AdsCardAdapter
import AdsCardLibrary
import PrebidMobile
import SwiftUI

class PrebidBannerAdManager: PrebidAdManager {
    var ad: BannerView?
    
    override
    public init(adType: PrebidAdType,
                adConfiguration: AdsCardLibrary.AdConfiguration = .init(adUnitId: ""),
                cardConfiguration: CardConfiguration = .init(),
                viewController: UIViewController?,
                adDelegate: AdLifeCycleDelegate? = nil) {
        super.init(adType: adType,
                   adConfiguration: adConfiguration,
                   cardConfiguration: cardConfiguration,
                   viewController: viewController,
                   adDelegate: adDelegate)
        bannerSizes = [
            BannerSize(size: .init(width: 320, height: 50), image: Image(systemName: "inset.filled.bottomthird.rectangle")),
            BannerSize(size: .init(width: 300, height: 250), image: Image(systemName: "inset.filled.rectangle")),
        ]
        actualSize = self.bannerSizes?.first!
        if let bannerSize = self.bannerSizes?[adConfiguration.bannerSize] {
            actualSize = bannerSize
        }
    }
    
    override func updateBannerSize(_ size: AdsCardLibrary.BannerSize) {
        if size != actualSize {
            resetAd()
        }
        super.updateBannerSize(size)
    }
    
    override func instanciateAd() async {
        let _: Void = await withCheckedContinuation { continuation in
            Task { @MainActor in
                ad = BannerView(frame: .init(),
                                configID: adConfiguration.adUnitId,
                                adSize: actualSize?.size ?? .zero)
                ad?.delegate = proxy
                continuation.resume()
            }
        }
    }
    
    override func resetAd() {
        ad = nil
    }
    
    override func load() async {
        await super.load()
        await instanciateAd()
        guard let ad else { return }
        if let str = ortbValue() {
            await ad.setImpORTBConfig(str)
        }
        await ad.loadAd()
    }
    
    override func show() {
        guard let ad else { return }
        append(.bannerReady(ad))
    }
    
    override class func decode(from container: AdCardContainer) throws(AdCardContainerError) -> any AdManager {
        guard let adType = PrebidAdType(rawValue: container.adType) else { throw .invalidAdType }
        return PrebidBannerAdManager(adType: adType,
                                     adConfiguration: .init(adUnitId: container.adInformations.adUnitId,
                                                            campaignId: container.adInformations.campaignId,
                                                            creativeId: container.adInformations.creativeId,
                                                            dspCreativeId: container.adInformations.dspCreativeId,
                                                            dspRegion: container.adInformations.dspRegion,
                                                            bannerSize: container.adInformations.bannerSize),
                                     cardConfiguration: .init(oguryTestModeEnabled: container.adInformations.settings.oguryTestModeEnabled,
                                                              rtbTestModeEnabled: container.adInformations.settings.rtbTestModeEnabled,
                                                              qaLabel: container.adInformations.settings.qaLabel),
                                     viewController: nil,
                                     adDelegate: nil)
    }
}
